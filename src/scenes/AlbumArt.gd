extends Control

const RPMS = { "speed33": "33 1/3", "speed45": "45", "speed78": "78" }
const SIZES = { "size12": "12", "size7": "7", "size10": "10" }

var label_a
var label_b
var blank
var label
var album

onready var label_blank = find_node("LabelBlank")

func _ready():
	label_a = load("res://assets/labela.png")
	label_b = load("res://assets/labelb.png")
	blank = Image.new()
	find_node("Large").visible = false
	show_album_details(false)
	if g.settings.album_id:
		load_album(g.settings.album_id)
	$VB/Header/VB/NoRecords.visible = g.settings.albums.size() < 1


func _on_Load_pressed():
	$c/AlbumSelector.open()


func _on_AlbumSelector_album_selected(album_id):
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
	find_node("Text").text = text.join("\n")
	var large_hole = album.size == "size7"
	find_node("Large").visible = large_hole
	if large_hole:
		blank = label_b.get_data()
	else:
		blank = label_a.get_data()
	label_blank.icon = get_icon_texture(album.label_color)
	show_album_details()


func _on_Label_pressed():
	$c/Color/M/ColorPicker.color = album.label_color
	$c/Color.popup_centered()


func _on_Color_popup_hide():
	album.label_color = $c/Color/M/ColorPicker.color
	label_blank.icon = get_icon_texture(album.label_color)


func _on_Save_pressed():
	$c/SaveDialog.current_dir = g.settings.last_image_dir
	$c/SaveDialog.current_file = ""
	$c/SaveDialog.popup_centered()


func _on_SaveDialog_file_selected(path):
	label.save_png(path)
	g.settings.last_image_dir = path.get_base_dir()


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


func _on_CopyText_pressed():
	OS.set_clipboard($VB/A2/VB/Text.text)


func show_album_details(show = true):
	$VB/A1.visible = show
	$VB/A2.visible = show
