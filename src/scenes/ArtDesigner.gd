extends PanelContainer

signal bg_texture_button_pressed()
signal save_button_pressed(texture, idx, show_dialog)
signal pick_bg_color(color)
signal pick_fill_color(color)
signal font_button_pressed()

onready var color_adjusters = find_node("Adjusters")

var current_element: ArtElement
var background
var elements: Array
var default_bg = preload("res://assets/checkerboard.png")
var current_images = [null, null, null, null]
var canvas_index = 0
var last_hash = 0
var album

func disable_input(disable = true):
	$HB/VB/ImageView/Viewport.gui_disable_input = disable


func init_canvas(idx, _album):
	album = _album
	canvas_index = idx
	background = _album.bg[idx]
	elements = _album.elements[idx]
	if current_images[idx] == null:
		set_currect_image(idx, _album)
	get_node("%CurrentImage").texture = current_images[idx]
	$HB/VB/Title.text = ["Label design - side A", "Label design - side B", "Front Cover design", "Back Cover design"][idx]
	get_node("%ImageView").is_disc = idx < 2
	get_node("%BGTexture").icon = default_bg
	get_node("%ImageView").image = null
	var image_path = background.get("image", null)
	if image_path:
		try_updating_bg_image(image_path)
	var color = background.get("color", Color.white)
	init_mod_color(color)
	$HB/RHS/Props.hide()
	$HB/ArtElements.init_elements(elements)
	assign_fonts()
	update_elements()


func init_mod_color(color):
	update_mod_color(color)
	color_adjusters.get_node("H").value = color.h
	color_adjusters.get_node("S").value = color.s
	color_adjusters.get_node("V").value = color.v
	color_adjusters.get_node("A").value = color.a


func update_mod_color(color = null):
	if color == null:
		color = Color.from_hsv(color_adjusters.get_node("H").value, color_adjusters.get_node("S").value, color_adjusters.get_node("V").value, color_adjusters.get_node("A").value)
	get_node("%ImageView").mod_color = color
	get_node("%ModColor").color = color
	background["color"] = color


func update_element_font(path):
	current_element.font_path = path
	assign_font_to_element(current_element)


func assign_fonts():
	for el in elements:
		if el.type == ArtElement.AB or el.type == ArtElement.ABROT:
			assign_font_to_element(el)


func assign_font_to_element(element):
	var path = element.font_path
	var df = DynamicFont.new()
	df.use_filter = true
	df.size = g.get_font_size(element.size)
	if path.empty():
		path = "res://assets/fonts/NotoSansUI_Regular.ttf"
		get_node("%Font").text = "Font"
	else:
		get_node("%Font").text = path.get_file()
	df.font_data = load(path)
	element.font = df


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
	assign_font_to_element(el)
	fill_props(el)
	$HB/RHS/Props.show()


func _on_ArtElements_removed_element(el):
	elements.erase(el)
	update_elements()
	$HB/RHS/Props.hide()


func _on_ArtElements_selected_element(el):
	fill_props(el)
	$HB/RHS/Props.show()


func fill_props(el):
	current_element = el
	var props = $HB/RHS/Props
	match el.type:
		ArtElement.AB, ArtElement.ABROT:
			props.get_node("Text").text = el.text
			props.get_node("Font").text = el.font_path.get_file()
			props.get_node("Font").show()
			props.get_node("Text").show()
			props.get_node("TextLabel").show()
		_:
			props.get_node("Text").hide()
			props.get_node("Font").hide()
			props.get_node("TextLabel").hide()
	set_adjusters(el)


func set_adjusters(el):
	var adjusters = get_node("%Adjusters")
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


func set_fill_adjusters(color):
	current_element.color = color
	set_adjusters(current_element)


func _on_Length_value_changed(value):
	current_element.length = value


func _on_Size_value_changed(value):
	current_element.size = value
	match current_element.type:
		ArtElement.AB, ArtElement.ABROT:
			current_element.font.size = g.get_font_size(value)


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


func set_currect_image(idx, _album, update_image = false):
	var text = { resized = default_bg }
	if _album.images[idx]:
		text = g.get_resized_texture(_album.images[idx], 64)
	current_images[idx] = text.resized
	if update_image:
		get_node("%CurrentImage").texture = text.resized


func _on_SaveAs_pressed():
	_on_Save_pressed(true)


func _on_Save_pressed(show_dialog = false):
	var image = get_node("%ImageView").get_texture()
	emit_signal("save_button_pressed", image.duplicate(), canvas_index, show_dialog)
	image.resize(64, 64)
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	get_node("%CurrentImage").texture = texture
	current_images[canvas_index] = texture


func _on_ModColor_gui_input(event):
	if event is InputEventMouseButton:
		emit_signal("pick_bg_color", background["color"])


func _on_FillColor_gui_input(event):
	if event is InputEventMouseButton:
		emit_signal("pick_fill_color", current_element.color)


func update_elements():
	var iv = get_node("%ImageView")
	iv.strings.clear()
	iv.rotated_strings.clear()
	iv.arcs.clear()
	iv.rings.clear()
	iv.boxes.clear()
	iv.circles.clear()
	iv.lines.clear()
	iv.squares.clear()
	for el in elements:
		if el.type == ArtElement.AB:
			iv.strings.append(el)
		if el.type == ArtElement.ABROT:
			iv.rotated_strings.append(el)
		if el.type == ArtElement.ARC:
			iv.arcs.append(el)
		if el.type == ArtElement.CIRC:
			iv.rings.append(el)
		if el.type == ArtElement.BOX:
			iv.boxes.append(el)
		if el.type == ArtElement.DOT:
			iv.circles.append(el)
		if el.type == ArtElement.LINE:
			iv.lines.append(el)
		if el.type == ArtElement.SQR:
			iv.squares.append(el)
	iv.overlay.update()


func _process(_delta):
	if current_element:
		var h = current_element.get_hash()
		if last_hash != h:
			last_hash = h
			update_elements()


func _on_Text_gui_input(event):
	if event is InputEventKey and event.scancode == KEY_DELETE:
		get_tree().set_input_as_handled()


func _on_Font_pressed():
	emit_signal("font_button_pressed")


func _on_Clear_pressed():
	$Confirmation.popup_centered()


func _on_Confirmation_confirmed():
	current_images[canvas_index] = null
	album.images[canvas_index] = null
	album.bg[canvas_index].clear()
	album.elements[canvas_index].clear()
	init_canvas(canvas_index, album)
