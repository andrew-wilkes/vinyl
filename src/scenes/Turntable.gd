extends Spatial

enum { NONE, MOVING_LEVER, MOVING_HANDLE, MOVING_SWITCH }

enum { WAITING, CAN_PLAY, MOVING_DISC, CAN_EJECT }

onready var arm = find_node("Arm")
onready var arm_base = find_node("ArmBase")
onready var arm_handle = find_node("Handle")
onready var lever: MeshInstance = find_node("Lever")
onready var platter = find_node("Platter")
onready var switch = find_node("Switch")
onready var weight = find_node("Weight")
onready var support = find_node("SupportPin")
onready var lever_handle = find_node("LeverHandle")
onready var lever_handle_shader = lever_handle.mesh.surface_get_material(0).next_pass
onready var switch_handle_shader = switch.mesh.surface_get_material(0).next_pass
onready var arm_handle_shader = arm_handle.mesh.surface_get_material(0).next_pass
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

func _ready():
	relocate_collision_area($LeverArea, lever_handle)
	relocate_collision_area($HandleArea, arm_handle)
	relocate_collision_area($SwitchArea, switch)
	arm_transform = arm.transform
	arm_base_transform = arm_base.transform
	switch_transform = switch.transform
	if g.current_album_id:
		var album = g.settings.albums[g.current_album_id]
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
	else:
		get_node("%Details").hide()


func relocate_collision_area(src: Spatial, dest: Spatial):
	src.translation = Vector3.ZERO
	remove_child(src)
	dest.add_child(src)
	src.get_child(0).rotation = Vector3.ZERO


func _process(delta):
	if mode == MOVING_HANDLE: return
	
	if Input.is_key_pressed(KEY_1):
		prints(arm_base.rotation, needle.global_translation)
	# Move support in relation to lever position
	if lever_pos >= support_pos:
		support_pos = lever_pos
	else:
		support_pos -= delta * 1.0
	support.translation.y = lerp(0.06, 0.114, support_pos)
	
	# Calculate the angle limit for the arm
	angle_limit = atan((0.114 - support.translation.y) / 0.3952)
	
	# Make arm fall if within angle_limit
	if angle_limit > get_arm_angle() and arm_limit_y(): return
	if get_arm_angle() < (angle_limit - 0.06):
		arm.rotate_object_local(Vector3(1, 0, 0), -delta * 0.8)
	else:
		arm.transform = arm_transform
		arm.rotate_object_local(Vector3(1, 0, 0), -angle_limit)
	
	var v = get_node("%HSlider").value
	if v != last_slider_value:
		last_slider_value = v
		get_node("%Record").animate(v)
		match record_state:
			WAITING:
				if v > 65:
					record_state = CAN_PLAY
					get_node("%Play").disabled = false
					get_node("%Eject").disabled = true
				else:
					get_node("%Play").disabled = true
					get_node("%Eject").disabled = true
			CAN_PLAY:
				if v < 65:
					record_state = WAITING
					get_node("%Play").disabled = true
			CAN_EJECT:
				get_node("%Play").disabled = true
				get_node("%Eject").disabled = false
		if v > 65: side = 0
		if v > 85: side = 1


func arm_limit_y():
	var limit = false
	var np = needle.global_translation
	if np.x < 1.0827:
		if has_record:
			if np.y <= 0.16: limit = true
		else:
			if np.y <= 0.145: limit = true
	elif np.x < 1.121:
		if has_record:
			if np.y <= 0.115: limit = true
		else:
			if np.y <= 0.1: limit = true
	elif np.y <= -0.075: limit = true
	return limit


func arm_limit_x(dir):
	var limit = false
	var np = needle.global_translation
	if dir < 0:
		if np.x < 1.0827:
			if has_record:
				if np.y <= 0.16: limit = true
			else:
				if np.y <= 0.145: limit = true
		elif np.x < 1.121:
			if has_record:
				if np.y <= 0.115: limit = true
			else:
				if np.y <= 0.1: limit = true
		if np.x <= 0.182: limit = true
	elif np.x >= 2.28: limit = true
	return limit


func rotate_arm(angle):
	arm_base.rotate_y(angle)


func raise_support(_dist):
	pass


func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.pressed:
		mode = NONE
		$OrbitCamera.locked = false
	if event is InputEventMouseMotion:
		match mode:
			MOVING_LEVER:
				lever.rotation.x = clamp(lever.rotation.x - event.relative.y * 0.01, -1.33, -0.73)
				lever_pos = (lever.rotation.x + 1.33) / (1.33 - 0.73)
			MOVING_HANDLE:
				if arm_limit_x(event.relative.x): return
				arm_base.rotate_object_local(Vector3(0, 1, 0), event.relative.x * 0.005)
				var new_arm_angle = arm_angle + event.relative.y * 0.002
				if event.relative.y > 0:
					if new_arm_angle > angle_limit or arm_limit_y(): return
				else:
					if new_arm_angle < -0.4: return
				arm_angle = new_arm_angle
				arm.transform = arm_transform
				arm.rotate_object_local(Vector3(1, 0, 0), -arm_angle)
			MOVING_SWITCH:
				pass
			MOVING_DISC:
				pass


func _on_Lever_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		mode = MOVING_LEVER
		$OrbitCamera.lock()


func _on_Lever_mouse_entered():
	lever_handle_shader.set_shader_param("Level", 1.0)


func _on_Lever_mouse_exited():
	lever_handle_shader.set_shader_param("Level", 0.0)


func _on_HandleArea_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		mode = MOVING_HANDLE
		arm_angle = get_arm_angle()
		$OrbitCamera.lock()


func _on_HandleArea_mouse_entered():
	arm_handle_shader.set_shader_param("Level", 1.0)


func _on_HandleArea_mouse_exited():
	arm_handle_shader.set_shader_param("Level", 0.0)


func _on_SwitchArea_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		mode = MOVING_SWITCH
		$OrbitCamera.lock()


func _on_SwitchArea_mouse_entered():
	switch_handle_shader.set_shader_param("Level", 1.0)


func _on_SwitchArea_mouse_exited():
	switch_handle_shader.set_shader_param("Level", 0.0)


func get_arm_angle():
	return (1.5708 - arm.rotation.x) * 11.162


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
	var tween = create_tween()
	# Doesn't work if parameter is called alpha (thinks it's an INT)
	tween.tween_property($Disc.get_surface_material(0), "shader_param/alphav", 1.0, 0.5) #.from_current()
	yield(tween, "finished")
	record_state = CAN_EJECT
	last_slider_value = -1.0 # trigger update of button states


func _on_Eject_pressed():
	get_node("%Eject").disabled = true
	record_state = MOVING_DISC
	var tween = create_tween()
	tween.tween_property($Disc.get_surface_material(0), "shader_param/alphav", 0.0, 0.5).from_current()
	yield(tween, "finished")
	record_state = WAITING
	last_slider_value = -1.0	
