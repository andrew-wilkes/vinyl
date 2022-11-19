extends Spatial

enum { NONE, MOVING_LEVER, MOVING_HANDLE, MOVING_SWITCH }

enum { WAITING, CAN_PLAY, MOVING_DISC, CAN_EJECT }

enum { NOT_PLAYING, PLAYING }

const LED_COLORS = [Color.green, Color.blue, Color.orange, Color.red]
const GAP_LENGTH = 8
const OUTER_GROOVE = -5.48
const INNER_GROOVE = -28.9

var highlight_material = preload("res://assets/highlight.material")

onready var arm = find_node("arm")
onready var arm_base = find_node("arm-base")
onready var arm_handle = find_node("Handle")
onready var lever: MeshInstance = find_node("Lever")
onready var platter = find_node("Platter")
onready var switch = find_node("Switch")
onready var weight = find_node("Weight")
onready var support = find_node("support")
onready var lever_handle = find_node("LeverHandle")
onready var led = find_node("Led").mesh.surface_get_material(0)
onready var deck = find_node("Deck").mesh.surface_get_material(0)
onready var cart = find_node("Cartridge").mesh.surface_get_material(0)
onready var lever_handle_material = lever_handle.mesh.surface_get_material(0)
onready var switch_material = switch.mesh.surface_get_material(0)
onready var arm_handle_material = arm_handle.mesh.surface_get_material(0)
onready var disc_shader = $Disc.get_surface_material(0).next_pass
onready var needle = find_node("Needle")

var arm_angle = 0
var mode = NONE
var support_pos = 1.0
var lever_pos = 1.0
var arm_transform
var arm_base_transform
var switch_transform
var angle_limit
var has_record = false
var last_slider_value = 0.0
var record_state = WAITING
var side = 0
var target_speed = 33.33
var rpm = 0.0
var switch_pos = 75.0
var area_clear = true
var audio
var play_state = NOT_PLAYING
var album
var timelines = []
var not_updating_track_name = true
var side_playing = 0
var record_loaded = false
export(Theme) var theme

func _ready():
	get_node("%VolSlider").value = g.settings.volume
	audio = Audio.new($Audio)
	set_led_color(0)
	relocate_collision_area($LeverArea, lever_handle)
	relocate_collision_area($HandleArea, arm_handle)
	relocate_collision_area($SwitchArea, switch)
	arm_transform = arm.transform
	arm_base_transform = arm_base.transform
	switch_transform = switch.transform
	$"%EnvControl".setup($WE)
	if g.current_album_id:
		album = g.settings.albums[g.current_album_id]
	if g.current_album_id and not album.title.empty():
		get_node("%Title").text = album.title
		get_node("%Band").text = album.band
		get_node("%Details").show()
		var edge_color = Color.whitesmoke if album.bg[2].empty() else album.bg[2].color
		get_node("%Record").set_textures(album, edge_color)
		if album.images[0]:
			var img_a = g.get_resized_texture(album.images[0]).texture
			$Disc.get_surface_material(0).set_shader_param("label_a", img_a)
		if album.images[1]:
			var img_b = g.get_resized_texture(album.images[1]).texture
			$Disc.get_surface_material(0).set_shader_param("label_b", img_b)
		timelines.append(get_mod_array(album.a_side))
		$Disc.get_surface_material(0).set_shader_param("radius_mod_a", get_data_texture(timelines[0]))
		timelines.append(get_mod_array(album.b_side))
		$Disc.get_surface_material(0).set_shader_param("radius_mod_b", get_data_texture(timelines[1]))
		record_loaded = true
	else:
		get_node("%Details").hide()
	set_deck_color(g.settings.deck_color)
	set_cart_color(g.settings.cart_color)
	get_node("%DeckColor").color = g.settings.deck_color
	get_node("%CartColor").color = g.settings.cart_color
	$c.get_child(0).theme = theme


func get_data_texture(idata):
	var img = Image.new()
	img.create_from_data(idata.size(), 1, false, Image.FORMAT_R8, idata)
	#img.save_png("res://temp.png")
	var texture = ImageTexture.new()
	texture.create_from_image(img, 0)
	return texture


func get_mod_array(tracks):
	var arr = []
	arr.append_array(get_mod_data(2, 0.0))
	for track in tracks:
		# Track length + silence
		arr.append_array(get_mod_data(track.length))
		# Crossover spiral
		arr.append_array(get_mod_data(GAP_LENGTH, 0.0))
	return arr


func get_mod_data(length, value = 255.0):
	var arr = []
	arr.resize(length)
	arr.fill(value)
	return arr


func set_led_color(idx):
	led.set("albedo_color", LED_COLORS[idx])
	target_speed = g.RPMS.values()[idx]


func set_deck_color(color):
	deck.set("albedo_color", color)


func set_cart_color(color):
	cart.set("albedo_color", color)


func relocate_collision_area(src: Spatial, dest: Spatial):
	src.translation = Vector3.ZERO
	remove_child(src)
	dest.add_child(src)
	src.get_child(0).rotation = Vector3.ZERO


func _process(delta):
	if rpm < target_speed:
		rpm += 66 * delta # Take 0.5s to reach 33
	if rpm > target_speed:
		rpm -= 66 * delta
	if rpm > 0:
		var ang = clamp(rpm, 0.0, -target_speed) / 30.0 * delta
		$Disc.rotate_y(ang)
		set_dot_position()
	check_play_state(delta)
	if not_updating_track_name and timelines.size() > 0:
		update_track_name(get_track())
	if mode == MOVING_HANDLE: return
	if Input.is_key_pressed(KEY_1):
		prints(arm_base.rotation, needle.global_translation)
		prints(support.translation.y)
		print(arm.rotation.x)
	# Move support in relation to lever position 0 .. 1
	if lever_pos >= support_pos:
		support_pos = lever_pos
	else:
		support_pos -= delta * 1.0
	# Map the 0 .. 1 value to the y translation of the support arm
	support.translation.y = lerp(-0.055, 0.0, support_pos)
	
	# Get the angle limit for the arm
	angle_limit = lerp(0.0, tan(deg2rad(5.0)), support.translation.y / 0.055)
	if Input.is_key_pressed(KEY_2):
		prints(rad2deg(angle_limit), arm.rotation_degrees)

	# Make arm fall if within angle_limit
	if arm.rotation.x > angle_limit and not arm_limit_y():
		arm.rotate_object_local(Vector3(1, 0, 0), -delta * 0.8)
	if angle_limit > arm.rotation.x:
		arm.transform = arm_transform
		arm.rotate_object_local(Vector3(1, 0, 0), angle_limit)
		set_dot_position()
	if not record_loaded: return
	
	var v = get_node("%HSlider").value
	if v != last_slider_value:
		last_slider_value = v
		get_node("%Record").animate(v)
		match record_state:
			WAITING:
				if v > 64:
					record_state = CAN_PLAY
					get_node("%Play").disabled = not area_clear
					get_node("%Eject").disabled = true
				else:
					get_node("%Play").disabled = true
					get_node("%Eject").disabled = true
			CAN_PLAY:
				if v < 64:
					record_state = WAITING
					get_node("%Play").disabled = true
			CAN_EJECT:
				get_node("%Play").disabled = true
				get_node("%Eject").disabled = not area_clear
		if v > 65: side = 0
		if v > 85: side = 1


# It's possible to manually move the arm to go past the limits
func arm_limit_y():
	return check_y_limit_depending_on_x(false)


func check_play_state(delta):
	area_clear = arm_base.rotation_degrees.y > -0.848
	if has_record and rpm > 0 and needle_on_record():
		var rotation_scale = 1.0
		if play_state == NOT_PLAYING:
			var tr = get_track()
			update_track_name(tr)
			if tr:
				# Start playing
				audio.load_data(tr.path)
				var start_time = 0.0 if tr.position < 10.0 else tr.position
				audio.play(start_time)
				play_state = PLAYING
			else:
				# In crossover
				rotation_scale = 2.67 # Reduce transit time from 8s to 3s
				if arm_base.rotation_degrees.y < INNER_GROOVE:
					rotation_scale *= 8.0
		audio.set_speed(g.RPMS[album.rpm], rpm)
		# Rotate arm
		if arm_base.rotation.y > -0.825:
			arm_base.rotation.y -= delta * 0.455 / timelines[side].size() * audio.player.pitch_scale * rotation_scale
	else:
		if audio.player.playing:
			audio.stop()
			play_state = NOT_PLAYING


func get_track():
	# Return track or null if in gap or outside of track area
	var total_time = timelines[side].size()
	var t_mark = (OUTER_GROOVE - arm_base.rotation_degrees.y) / (OUTER_GROOVE - INNER_GROOVE) * total_time
	if t_mark < 0.0 or t_mark > total_time: return
	var t = 0.0
	for tr in [album.a_side, album.b_side][side]:
		tr.position = t_mark - t
		t += tr.length
		if t_mark < t:
			return tr
		t += GAP_LENGTH
		if t_mark < t:
			return


func needle_on_record():
	if Input.is_key_pressed(KEY_3):
		prints(arm.rotation_degrees.x, arm_base.rotation_degrees.y)
	return arm.rotation_degrees.x <= -1.68 and arm_base.rotation_degrees.y <= -5.48 and arm_base.rotation_degrees.y >= -30.5


func set_dot_position():
	var np = needle.global_translation
	if side_playing > 0: np *= Vector3(-1, 1, -1)
	var pos = Vector2(np.x / 1.55, np.z / 1.55).rotated($Disc.rotation.y)
	if arm.rotation_degrees.x <= -1.68: pos = Vector2.ZERO
	$Disc.get_surface_material(0).set_shader_param("dot_position", pos)


# Limit left - right arm movement
func arm_limit_x(dir):
	var limit = false
	set_dot_position()
	if dir < 0:
		# Inner groove
		if arm_base.rotation_degrees.y < -30.5:
			limit = true
		limit = check_y_limit_depending_on_x(limit)
	else:
		if arm_base.rotation_degrees.y >= 17.3:
			limit = true
	if has_record:
		get_node("%Eject").disabled = arm_base.rotation_degrees.y < -0.848
	elif record_state == CAN_PLAY:
		get_node("%Play").disabled = arm_base.rotation_degrees.y < -0.848
	return limit


func check_y_limit_depending_on_x(limit):
	if has_record:
		if arm_base.rotation_degrees.y < -4.127:
			if arm.rotation_degrees.x <= -1.681:
				limit = true
		elif arm_base.rotation_degrees.y < -2.451:
			if arm.rotation_degrees.x <= -2.942:
				limit = true
	else:
		if arm_base.rotation_degrees.y < -7.521:
			if arm.rotation_degrees.x <= -2.197:
				limit = true
		elif arm_base.rotation_degrees.y < -7.139:
			if arm.rotation_degrees.x <= -2.546 + (-7.139 - arm_base.rotation_degrees.y) * 0.9136:
				limit = true
		elif arm_base.rotation_degrees.y < -5.444:
			if arm.rotation_degrees.x <= -3.482:
				limit = true
		elif arm_base.rotation_degrees.y < -5.068:
			if arm.rotation_degrees.x <= -3.821 + (-5.068 - arm_base.rotation_degrees.y) * 0.902:
				limit = true
	return limit


func rotate_arm(angle):
	arm_base.rotate_y(angle)


func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.pressed:
		mode = NONE
		$OrbitCamera.locked = false
	if event is InputEventMouseMotion:
		match mode:
			MOVING_LEVER:
				lever.rotation.x = clamp(lever.rotation.x - event.relative.y * 0.01, -1.33, -0.73)
				# Get a value between 0 and 1
				lever_pos = (lever.rotation.x + 1.33) / (1.33 - 0.73)
			MOVING_HANDLE:
				if arm_limit_x(event.relative.x): return
				arm_base.rotate_object_local(Vector3(0, 1, 0), event.relative.x * 0.005)
				if event.relative.y > 0:
					if arm.rotation.x < angle_limit or arm_limit_y(): return
				else:
					if arm.rotation_degrees.x > 17.0: return
				arm.rotate_object_local(Vector3(1, 0, 0), -event.relative.y * 0.002)
			MOVING_SWITCH:
				switch_pos = clamp(switch_pos + event.relative.x, 0.0, 199.0)
				var disc_state = int(switch_pos / 50.0)
				set_led_color(disc_state)
			MOVING_DISC:
				pass


func update_track_name(track):
	var tnode = get_node("%TrackName")
	if track:
		if tnode.text == track.title: return
	else:
		if tnode.text == "": return
	not_updating_track_name = false
	var tween = create_tween()
	if track:
		if tnode.text == "":
			tnode.text = track.title
			tween.tween_property(tnode, "modulate:a", 1.0, 0.5)
		else:
			tween.tween_property(tnode, "modulate:a", 0.0, 0.5)
	else:
		tween.tween_property(tnode, "modulate:a", 0.0, 0.5)
	yield(tween, "finished")
	if tnode.modulate.a < 0.1: tnode.text = ""
	not_updating_track_name = true


func _on_Lever_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		mode = MOVING_LEVER
		$OrbitCamera.lock()


func _on_Lever_mouse_entered():
	lever_handle_material.next_pass = highlight_material


func _on_Lever_mouse_exited():
	lever_handle_material.next_pass = null


func _on_HandleArea_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		mode = MOVING_HANDLE
		arm_angle = arm.rotation.x
		$OrbitCamera.lock()


func _on_HandleArea_mouse_entered():
	arm_handle_material.next_pass = highlight_material


func _on_HandleArea_mouse_exited():
	arm_handle_material.next_pass = null


func _on_SwitchArea_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		mode = MOVING_SWITCH
		$OrbitCamera.lock()


func _on_SwitchArea_mouse_entered():
	switch_material.next_pass = highlight_material


func _on_SwitchArea_mouse_exited():
	switch_material.next_pass = null


func _on_disc_mouse_entered():
	disc_shader.set_shader_param("Level", 1.0)


func _on_disc_mouse_exited():
	disc_shader.set_shader_param("Level", 0.0)


func _on_disc_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		mode = MOVING_DISC
		$OrbitCamera.lock()


func _on_Play_pressed():
	get_node("%Play").disabled = true
	record_state = MOVING_DISC
	# Make the correct side up
	$Disc.rotation = Vector3.ZERO
	if side == 1: $Disc.rotate_z(PI)
	side_playing = side
	var tween = create_tween()
	# Doesn't work if parameter is called alpha (thinks it's an INT)
	tween.tween_property($Disc.get_surface_material(0), "shader_param/alphav", 1.0, 0.5) #.from_current()
	yield(tween, "finished")
	has_record = true
	record_state = CAN_EJECT
	last_slider_value = -1.0 # trigger update of button states
	_on_Close_pressed()


func _on_Eject_pressed():
	get_node("%Eject").disabled = true
	record_state = MOVING_DISC
	var tween = create_tween()
	tween.tween_property($Disc.get_surface_material(0), "shader_param/alphav", 0.0, 0.5).from_current()
	yield(tween, "finished")
	has_record = false
	record_state = WAITING
	last_slider_value = -1.0


func _on_Audio_finished():
	play_state = NOT_PLAYING


func _on_VolSlider_value_changed(value):
	g.settings.volume = value
	var db = -pow(8.0 - value, 1.8)
	AudioServer.set_bus_volume_db(0, db)
	get_node("%VolSlider").hint_tooltip = "%d db" % db


func _on_Vol_draw():
	$"%EnvControl".resize_bg()


func _on_Open_pressed():
	get_node("%Details").visible = true
	get_node("%Open").visible = false


func _on_Close_pressed():
	get_node("%Details").visible = false
	get_node("%Open").visible = true


func _on_DeckColor_color_changed(color):
	g.settings.deck_color = color
	set_deck_color(color)


func _on_CartColor_color_changed(color):
	g.settings.cart_color = color
	set_cart_color(color)


func d(txt):
	$"%TrackName".text = txt


func _on_EnvControl_info_pressed():
	$c/InfoDialog.popup_centered()
