extends PanelContainer

signal bg_texture_button_pressed

onready var color_adjusters = find_node("Adjusters")

var current_element: ArtElement
var background
var elements: Array
var default_bg = preload("res://assets/checkerboard.png")
var current_images = [null, null, null, null]


func disable_input(disable = true):
	$HB/VB/ImageView/Viewport.gui_disable_input = disable


func init_canvas(idx, album):
	background = album.bg[idx]
	elements = album.elements[idx]
	if current_images[idx] == null:
		set_currect_image(idx, album)
	get_node("%CurrentImage").texture = current_images[idx]
	$HB/VB/Title.text = ["Label design - side A", "Label design - side B", "Front Cover design", "Back Cover design"][idx]
	get_node("%ImageView").is_disc = idx < 2
	get_node("%BGTexture").icon = default_bg
	get_node("%ImageView").image = null
	var image_path = background.get("image", null)
	if image_path:
		try_updating_bg_image(image_path)
	var color = background.get("color", Color.white)
	update_mod_color(color)
	color_adjusters.get_node("H").value = color.h
	color_adjusters.get_node("S").value = color.s
	color_adjusters.get_node("V").value = color.v
	color_adjusters.get_node("A").value = color.a
	$HB/RHS/Props.hide()
	$HB/ArtElements.init_elements(elements)


func update_mod_color(color = null):
	if color == null:
		color = Color.from_hsv(color_adjusters.get_node("H").value, color_adjusters.get_node("S").value, color_adjusters.get_node("V").value, color_adjusters.get_node("A").value)
	get_node("%ImageView").mod_color = color
	get_node("%ModColor").color = color
	background["color"] = color


func set_hole_size(large = true):
	if large:
		get_node("%ImageView").hole_size = 0.3
	else:
		get_node("%ImageView").hole_size = 0.1


func update_bg_image(path, text):
	get_node("%ImageView").image = text.texture
	background["image"] = path
	get_node("%BGTexture").icon = text.resized


func try_updating_bg_image(image_path):
	var text = g.get_resized_texture(image_path, 64)
	if text.resized:
		update_bg_image(image_path, text)


func _on_H_value_changed(_value):
	update_mod_color()


func _on_S_value_changed(_value):
	update_mod_color()


func _on_V_value_changed(_value):
	update_mod_color()


func _on_A_value_changed(_value):
	update_mod_color()


func _on_ArtElements_added_element(el):
	elements.append(el)
	fill_props(el)
	$HB/RHS/Props.show()


func _on_ArtElements_removed_element(el):
	elements.erase(el)
	$HB/RHS/Props.hide()


func _on_ArtElements_selected_element(el):
	fill_props(el)
	$HB/RHS/Props.show()


func fill_props(el):
	current_element = el
	var props = $HB/RHS/Props
	var adjusters = props.get_node("Adjusters")
	match el.type:
		ArtElement.AB, ArtElement.ABROT:
			props.get_node("Text").text = el.text
			props.get_node("Fonts").show()
			props.get_node("Text").show()
			props.get_node("TextLabel").show()
		_:
			props.get_node("Text").hide()
			props.get_node("Fonts").hide()
			props.get_node("TextLabel").hide()
	adjusters.get_node("Length").value = el.length
	adjusters.get_node("Size").value = el.size
	adjusters.get_node("H2").value = el.color.h
	adjusters.get_node("S2").value = el.color.s
	adjusters.get_node("V2").value = el.color.v
	adjusters.get_node("A2").value = el.color.a
	adjusters.get_node("Rot").value = el.rotation
	adjusters.get_node("X").value = el.position.x
	adjusters.get_node("Y").value = el.position.y
	update_fill_color()


func _on_Length_value_changed(value):
	current_element.length = value


func _on_Size_value_changed(value):
	current_element.size = value


func _on_Rot_value_changed(value):
	current_element.rotation = value


func _on_X_value_changed(value):
	current_element.position.x = value


func _on_Y_value_changed(value):
	current_element.position.y = value


func _on_Text_text_changed(new_text):
	current_element.text = new_text


func _on_H2_value_changed(value):
	current_element.color.h = value
	update_fill_color()


func update_fill_color():
	$HB/RHS/Props/Adjusters/HB/FillColor.color = current_element.color


func _on_S2_value_changed(value):
	current_element.color.s = value
	update_fill_color()


func _on_V2_value_changed(value):
	current_element.color.v = value
	update_fill_color()


func _on_A2_value_changed(value):
	current_element.color.a = value
	update_fill_color()


func _on_BGTexture_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1:
			emit_signal("bg_texture_button_pressed")
		else:
			get_node("%ImageView").image = null
			background["image"] = null
			get_node("%BGTexture").icon = default_bg


func set_currect_image(idx, album):
	# Need to re-map image indexes here
	var text = { resized = g.default_art[[2, 3, 0, 1][idx]] }
	if album.images[idx]:
		text = g.get_resized_texture(album.images[idx], 64)
	current_images[idx] = text.resized