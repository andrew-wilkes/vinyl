extends Control

const RPMS = { "speed33": "33 1/3", "speed45": "45", "speed78": "78" }
const SIZES = { "size12": "12", "size7": "7", "size10": "10" }

var label_a
var label_b
var blank
var label
var album
var canvas_group
var texture_to_save
var canvas_index
onready var art = find_node("ArtDesigner")

func _ready():
	#find_node("Large").visible = false
	show_album_details(false)
	if g.settings.album_id:
		load_album(g.settings.album_id)
	else:
		album = Album.new()
	$VB/Header/VB/NoRecords.visible = g.settings.albums.size() < 1
	canvas_group = get_node("%Canvas1").group
	var idx = 0
	for b in canvas_group.get_buttons():
		var _e = b.connect("pressed", self, "change_canvas", [idx])
		idx += 1
	art.disable_input()


func change_canvas(idx):
	art.init_canvas(idx, album)


func _on_Load_pressed():
	art.disable_input()
	$c/AlbumSelector.open()


func _on_AlbumSelector_album_selected(album_id):
	art.disable_input(false)
	load_album(album_id)


func load_album(id):
	g.settings.album_id = id
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


func _on_Color_popup_hide():
	album.label_color = $c/Color/M/ColorPicker.color


func _on_ArtDesigner_save_button_pressed(_texture, _canvas_index):
	texture_to_save = _texture
	canvas_index = _canvas_index
	art.disable_input()
	$c/SaveDialog.current_dir = g.settings.last_image_dir
	$c/SaveDialog.current_file = ""
	$c/SaveDialog.popup_centered()


func _on_SaveDialog_file_selected(path):
	art.disable_input(false)
	texture_to_save.save_png(path)
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
	art.disable_input(false)
	art.try_updating_bg_image(path)


func _on_ArtDesigner_bg_texture_button_pressed():
	art.disable_input()
	$c/ImageSelector.popup_centered()


func _on_TextPanel_popup_hide():
	art.disable_input(false)
