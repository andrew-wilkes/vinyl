extends PanelContainer

signal bg_texture_button_pressed

onready var color_adjusters = find_node("Adjusters")

var current_element: ArtElement
var background
var elements: Array
var default_bg = preload("res://assets/checkerboard.png")


func disable_input(disable = true):
	$HB/VB/ImageView/Viewport.gui_disable_input = disable


func init_canvas(idx, album):
	background = album.bg[idx]
	elements = album.elements[idx]
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
	$HB/Props.hide()
	$HB/Spacer.show()
	$HB/ArtElements.init_elements(elements)


func update_mod_color(color = null):
	if color == null:
		color = Color.from_hsv(color_adjusters.get_node("H").value, color_adjusters.get_node("S").value, color_adjusters.get_node("V").value, color_adjusters.get_node("A").value)
	get_node("%ImageView").mod_color = color
	$HB/VB/VB/HB/ModColor.color = color
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
	$HB/Props.show()
	$HB/Spacer.hide()


func _on_ArtElements_removed_element(el):
	elements.erase(el)
	$HB/Props.hide()
	$HB/Spacer.show()


func _on_ArtElements_selected_element(el):
	fill_props(el)
	$HB/Props.show()
	$HB/Spacer.hide()


func fill_props(el):
	current_element = el
	match el.type:
		ArtElement.AB, ArtElement.ABROT:
			$HB/Props/Text.text = el.text
			$HB/Props/Fonts.show()
			$HB/Props/Text.show()
			$HB/Props/TextLabel.show()
		_:
			$HB/Props/Text.hide()
			$HB/Props/Fonts.hide()
			$HB/Props/TextLabel.hide()
	$HB/Props/Adjusters/Length.value = el.length
	$HB/Props/Adjusters/Size.value = el.size
	$HB/Props/Adjusters/H2.value = el.color.h
	$HB/Props/Adjusters/S2.value = el.color.s
	$HB/Props/Adjusters/V2.value = el.color.v
	$HB/Props/Adjusters/A2.value = el.color.a
	$HB/Props/Adjusters/Rot.value = el.rotation
	$HB/Props/Adjusters/X.value = el.position.x
	$HB/Props/Adjusters/Y.value = el.position.y
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
	$HB/Props/Adjusters/HB/FillColor.color = current_element.color


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
