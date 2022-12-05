extends Spatial

# Wood: 6mm or 18mm or 24mm thickness
# LP: 31cm x 31cm x 6mm
# Position inner back wall at z = 0
# Back wall is inset

const thin_wood = 0.006
const plank_wood = 0.018
const thick_wood = 0.024
const shelf_depth = 0.32
const outer_depth = 0.34
const vspace = 0.34
const record_thickness = 0.006
const record_size = 0.31
const record_gap = 0.008
const X_CAPACITY = 50
const Y_CAPACITY = 3

onready var record = preload("res://scenes/Record.tscn")

var xoff: int
var xshift
var x_spacing
var y_spacing
var selected_item
var not_handled = true
var accept_click = true
var slots = PoolStringArray()
export(Theme) var theme

func _ready():
	get_node("%Details").hide()
	var material = record.instance().get_child(0).get_active_material(0)
	x_spacing = record_thickness + record_gap
	y_spacing = vspace + plank_wood
	xoff = calc_offset(X_CAPACITY)
	slots.resize(X_CAPACITY * Y_CAPACITY)
	slots.fill("")
	for album_id in g.settings.albums:
		add_album(material, album_id)
	if g.current_album_id:
		for item in $Albums.get_children():
			if item.album_id == g.current_album_id:
				select_item(item)
	$c.get_child(0).theme = theme
	set_light_energy()
	set_env_energy()
	$"%EnvControl".setup($WE)
	g.set_panel_color(theme)
	for node in $c.get_children():
		node.theme = theme


func add_album(material, album_id):
	var lp = record.instance()
	lp.remove_anim = true
	lp.get_node("Anim").queue_free()
	lp.set_lights(false)
	var album = g.settings.albums[album_id]
	# Set wanted shelf depending on record size
	if album.shelf_pos.y < 0:
		album.shelf_pos.y = g.SIZES.find(album.size)
	lp.translation = get_record_position(get_album_pos(album_id, album))
	match album.size:
		"size7":
			lp.scale = Vector3(1.0, 0.583, 0.583)
			lp.translation.y -= 0.064635 #0.155 * (1 - 0.583)
		"size10":
			lp.scale = Vector3(1.0, 0.833, 0.833)
			lp.translation.y -= 0.025885
	lp.album_id = album_id
	$Albums.add_child(lp)
	lp.get_child(0).get_child(0).connect("mouse_entered", self, "edge_entered", [lp])
	lp.get_child(0).get_child(0).connect("mouse_exited", self, "edge_exited", [lp])
	lp.get_child(0).get_child(0).connect("input_event", self, "edge_input", [lp])
	lp.get_child(0).set_surface_material(0, material.duplicate())
	lp.get_child(0).get_active_material(0).next_pass = material.next_pass.duplicate()
	var edge_color = Color.whitesmoke if album.bg[2].empty() else album.bg[2].color
	lp.set_textures(album, edge_color)


func get_album_pos(album_id, album):
	var slot_idx = album.shelf_pos.x + album.shelf_pos.y * X_CAPACITY
	if slots[slot_idx].empty():
		slots[slot_idx] = album_id
	else:
		# Try to relocate position if slot is occupied
		for idx in slots.size():
			if slots[idx].empty():
				slots[idx] = album_id
				album.shelf_pos.x = idx % X_CAPACITY
				album.shelf_pos.y = idx / X_CAPACITY
				break
	return Vector2(album.shelf_pos.x, album.shelf_pos.y)


func edge_entered(item):
	item.get_child(0).get_active_material(0).next_pass.set_shader_param("Level", 1.0)
	$"%AlbumTitle".text = g.settings.albums[item.album_id].title


func edge_exited(item):
	item.get_child(0).get_active_material(0).next_pass.set_shader_param("Level", 0.0)
	$"%AlbumTitle".text = ""


func edge_input(_camera, event, _position, _normal, _shape_idx, item):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		not_handled = false
		if accept_click: # Tweens have finished
			if selected_item and selected_item == item:
				get_node("%Navigation").goto_turntable()
			else:
				accept_click = false
				if selected_item:
					selected_item.reveal()
					get_node("%Details").hide()
					yield(selected_item.tween, "finished")
				select_item(item)


func select_item(item):
	selected_item = item
	g.current_album_id = item.album_id
	item.reveal()
	yield(item.tween, "finished")
	accept_click = true
	var album = g.settings.albums[g.current_album_id]
	if album.title.empty():
		get_node("%Details").hide()
	else:
		get_node("%Title").text = album.title
		get_node("%Band").text = album.band
		var side_a = get_node("%SideA")
		side_a.clear()
		for track in album.a_side:
			side_a.add_item(track.title)
		var side_b = get_node("%SideA")
		for track in album.b_side:
			side_b.add_item(track.title)
		get_node("%Details").show()


func _unhandled_input(event):
	# Right click to hide album
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT and event.pressed:
		not_handled = true
		call_deferred("got_click")
	if event is InputEventKey and selected_item:
		if Input.is_action_just_pressed("ui_left", true):
			move_item(-1, 0)
		if Input.is_action_just_pressed("ui_right", true):
			move_item(1, 0)
		if Input.is_action_just_pressed("ui_up", true):
			move_item(0, 1)
		if Input.is_action_just_pressed("ui_down", true):
			move_item(0, -1)


func move_item(x, y):
	var album = g.settings.albums[selected_item.album_id]
	album.shelf_pos.x = int(clamp(album.shelf_pos.x + x, 0, X_CAPACITY - 1))
	album.shelf_pos.y = int(clamp(album.shelf_pos.y + y, 0, Y_CAPACITY - 1))
	var pos = get_record_position(Vector2(album.shelf_pos.x, album.shelf_pos.y))
	selected_item.translation.x = pos.x
	selected_item.translation.y = pos.y


func insert_item():
	var album = g.settings.albums[selected_item.album_id]
	var slot_idx = album.shelf_pos.x + X_CAPACITY * album.shelf_pos.y
	# Check if item has been moved
	if slots[slot_idx] != selected_item.album_id:
		var id = slots[slot_idx]
		# Add item to new slot
		slots[slot_idx] = selected_item.album_id
		if not id.empty():
			# Rotate slots to right
			while true:
				slot_idx = (slot_idx + 1) % slots.size()
				var id2 = slots[slot_idx]
				slots[slot_idx] = id
				album = g.settings.albums[id]
				album.shelf_pos.x = slot_idx % X_CAPACITY
				album.shelf_pos.y = slot_idx / X_CAPACITY
				for node in $Albums.get_children():
					if node.album_id == id:
						node.translation = get_record_position(Vector2(album.shelf_pos.x, album.shelf_pos.y))
						break
				id = id2
				if id.empty() or id == selected_item.album_id:
					break


func got_click():
	if not_handled and selected_item:
		insert_item()
		selected_item.reveal()
		selected_item = null
		g.current_album_id = null
		get_node("%Details").hide()


func calc_cabinet_width(x_capacity):
	x_spacing = record_thickness + record_gap
	return x_capacity * (record_thickness + record_gap) + record_gap + 2 * plank_wood


func calc_offset(capacity: int):
	# warning-ignore:integer_division
	var off = -(capacity - 1) / 2
	xshift = 0.0
	if capacity % 2 == 0:
		# warning-ignore:integer_division
		off = -(capacity / 2)
		xshift = x_spacing / 2.0
	return off


func get_record_position(pos):
	return Vector3((xoff + pos.x) * x_spacing + xshift, thick_wood + pos.y * y_spacing + record_size / 2, record_size / 2)


func _on_Info_pressed():
	$c/Info.open(4)


func _on_EnvControl_slider1_changed(value):
	g.settings.bg_brightness[0] = value
	set_light_energy()


func set_light_energy():
	var e = g.settings.bg_brightness[0] / 100.0
	$Light1.light_energy = e
	$Light2.light_energy = e


func _on_EnvControl_slider2_changed(value):
	g.settings.env_brightness[1] = value
	set_env_energy()


func set_env_energy():
	$WE.environment.background_energy = g.settings.env_brightness[1] / 100.0


func _on_Reset_pressed():
	$OrbitCamera.reset_position()
