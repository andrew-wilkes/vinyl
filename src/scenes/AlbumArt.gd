extends Control

const RPMS = { "speed33": "33 1/3", "speed45": "45", "speed78": "78" }
const SIZES = { "size12": "12", "size7": "7", "size10": "10" }
const osx_dirs = ["/System/Library/Fonts/", "/Library/Fonts/", "~/Library/Fonts/"]
const linux_dirs = ["/usr/share/fonts", "~/.fonts"]
const windows_dirs = ["%WINDIR%/Fonts", "%appdata%/Local/Microsoft/Windows/Fonts"]

enum { PICK_MOD, PICK_FILL }

var label_a
var label_b
var blank
var label
var album
var canvas_group
var texture_to_save: Image
var canvas_index
var color_pick_mode
onready var art = find_node("ArtDesigner")

func _ready():
	show_album_details(false)
	if g.current_album_id:
		load_album(g.current_album_id)
	else:
		album = Album.new()
	$VB/Header/VB/NoRecords.visible = g.settings.albums.size() < 1
	var idx = 0
	for b in $"%CanvasMenu".get_children():
		if b is CheckBox:
			var _e = b.connect("pressed", self, "change_canvas", [idx])
			idx += 1
	art.disable_input()
	$"%BgColor".color = g.settings.bg_color
	$"%FgColor".color = g.settings.fg_color
	g.set_panel_color(theme)
	for node in $c.get_children():
		node.theme = theme


func change_canvas(idx):
	art.init_canvas(idx, album)


func _on_Load_pressed():
	art.disable_input()
	$c/AlbumSelector.open()


func _on_AlbumSelector_album_selected(album_id):
	art.disable_input(false)
	load_album(album_id)


func load_album(id):
	g.current_album_id = id
	album = g.settings.albums[id]
	find_node("Title").text = album.title
	find_node("Band").text = album.band
	var type = "%s inch %s RPM" % [SIZES[album.size], RPMS[album.rpm]]
	find_node("Type").text = type
	var text = PoolStringArray()
	text.append(album.title)
	text.append(album.band)
	text.append(type)
	text.append("\nSIDE A")
	var n = 1
	for track in album.a_side:
		text.append("%d. %s" % [n, track.title])
		n += 1
	text.append("\nSIDE B")
	n = 1
	for track in album.b_side:
		text.append("%d. %s" % [n, track.title])
		n += 1
	text.append("\n")
	for track in album.a_side:
		text.append(get_track_details(track))
	for track in album.b_side:
		text.append(get_track_details(track))
	get_node("%PanelText").text = text.join("\n")
	get_node("%Canvas1").pressed = true
	var large_hole = album.size == "size7"
	art.set_hole_size(large_hole)
	art.init_canvas(0, album)
	show_album_details()


func get_track_details(track):
	return "%s %s %s %s" % [track.title, track.album, track.year, g.format_time(track.length)]


func _on_ArtDesigner_save_button_pressed(_texture, _canvas_index, show_dialog):
	texture_to_save = _texture
	canvas_index = _canvas_index
	if album.images[canvas_index] == null or show_dialog:
		art.disable_input()
		$c/SaveDialog.current_dir = g.settings.last_image_dir
		$c/SaveDialog.current_file = "" if album.images[canvas_index] == null else album.images[canvas_index]
		$c/SaveDialog.popup_centered()
	else:
		var _e = texture_to_save.save_png(album.images[canvas_index])


func _on_SaveDialog_file_selected(path: String):
	art.disable_input(false)
	if path.get_extension() != "png":
		path = path.rstrip(".") + ".png"
	var _e = texture_to_save.save_png(path)
	g.settings.last_image_dir = path.get_base_dir()
	album.images[canvas_index] = path


# Archive this code
func get_icon_texture(color):
	var sqr_color = Image.new()
	sqr_color.copy_from(blank)
	sqr_color.fill(color)
	label = Image.new()
	label.copy_from(blank)
	label.fill(Color.transparent)
	label.blend_rect_mask(sqr_color, blank, sqr_color.get_used_rect(), Vector2.ZERO)
	label.fix_alpha_edges()
	var texture = ImageTexture.new()
	texture.create_from_image(label)
	return texture


func show_album_details(show = true):
	get_node("%LeftCol").visible = show
	art.visible = show


func _on_ShowText_pressed():
	art.disable_input()
	$c/TextPanel.popup_centered()


func _on_ImageSelector_file_selected(path):
	g.settings.last_image_dir = path.get_base_dir()
	art.disable_input(false)
	art.try_updating_bg_image(path)


func _on_ArtDesigner_bg_texture_button_pressed():
	art.disable_input()
	$c/ImageSelector.current_dir = g.settings.last_image_dir
	$c/ImageSelector.popup_centered()


func _on_TextPanel_popup_hide():
	art.disable_input(false)


func _on_ArtDesigner_pick_bg_color(color):
	open_color_picker(PICK_MOD, color)


func _on_ArtDesigner_pick_fill_color(color):
	open_color_picker(PICK_FILL, color)


func open_color_picker(mode, color):
	color_pick_mode = mode
	get_node("%ColorPicker").color = color
	get_node("%ColorPicker").edit_alpha = mode == PICK_FILL
	art.disable_input()
	$c/Color.popup_centered()


func _on_Color_popup_hide():
	art.disable_input(false)


func _on_ColorPicker_color_changed(color):
	match color_pick_mode:
		PICK_MOD:
			art.init_mod_color(color)
		PICK_FILL:
			art.set_fill_adjusters(color)


func _on_ArtDesigner_font_button_pressed():
	art.disable_input()
	if g.settings.last_font_dir.empty():
		var dir = Directory.new()
		match OS.get_name():
			"OSX":
				for fd in osx_dirs:
					if dir.dir_exists(fd):
						g.settings.last_font_dir = fd
						break
			"Windows":
				for fd in windows_dirs:
					if dir.dir_exists(fd):
						g.settings.last_font_dir = fd
						break
			"X11":
				for fd in linux_dirs:
					if dir.dir_exists(fd):
						g.settings.last_font_dir = fd
						break
	$c/FontSelector.current_dir = g.settings.last_font_dir
	$c/FontSelector.current_file = ""
	$c/FontSelector.popup_centered()


func _on_FontSelector_file_selected(path):
	art.disable_input(false)
	g.settings.last_font_dir = path.get_base_dir()
	art.current_element.font_path = path
	art.update_element_font(path)


func _on_BgColor_color_changed(color):
	g.set_bg_color(color)
	g.settings.bg_color = color


func _on_FgColor_color_changed(color):
	g.settings.fg_color = color
	g.set_panel_color(theme)


func _on_Info_pressed():
	$c/Info.open(1)


func _on_TextPanel_text_copied():
	art.disable_input()
	$c/Copied.popup_centered()


func _on_Copied_popup_hide():
	art.disable_input(false)
