extends Node

const RPMS = { "zero": 0.0, "speed33": 33.33, "speed45": 45.0, "speed78": 78.0 }
const SIZES = [ "size12", "size7", "size10" ]

var settings
var default_art = []
var current_album_id

func _init():
	settings = Settings.new()
	settings = settings.load_data()
	set_bg_color(settings.bg_color)
	pass #settings.albums.clear()
	default_art.append(load("res://assets/a-side.png"))
	default_art.append(load("res://assets/b-side.png"))
	default_art.append(load("res://assets/cover-front.png"))
	default_art.append(load("res://assets/cover-rear.png"))


func _ready():
	set_panel_color(get_parent().get_child(1).theme)


func set_bg_color(color):
	VisualServer.set_default_clear_color(color)


func set_panel_color(theme):
	theme.get_stylebox("normal", "Button").bg_color = settings.fg_color
	theme.get_stylebox("pressed", "Button").bg_color = settings.fg_color * 0.7
	theme.get_stylebox("hover", "Button").bg_color = settings.fg_color * 0.8
	theme.get_stylebox("disabled", "Button").bg_color = settings.fg_color * 1.5
	theme.get_stylebox("panel", "PanelContainer").bg_color = settings.fg_color
	theme.get_stylebox("panel", "WindowDialog").border_color = settings.fg_color
	#print(theme.get_stylebox_types())
	#print(theme.get_stylebox_list("Button"))


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			save_and_quit()


# Handle shutdown of App
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		save_and_quit()


func save_and_quit():
	if get_parent().get_child(1).name == "Main":
		settings.save_data()
		get_tree().quit()
	else:
		settings.save_data()
		var fader = get_parent().get_child(1).find_node("Fader")
		if fader:
			fader.fade_out("Main")
		else:
			get_tree().quit()


func format_time(time):
# warning-ignore:integer_division
	return "%02d:%02d" % [int(time) / 60, int(time) % 60]


func get_resized_texture(path, size = 0):
	var resized = ImageTexture.new()
	var texture = ImageTexture.new()
	var image = Image.new()
	var file = File.new()
	if file.file_exists(path):
		image.load(path)
		texture.create_from_image(image)
		if size > 0:
			image.resize(size, size)
			resized.create_from_image(image)
	else:
		texture = null
	return { texture = texture, resized = resized}


func get_font_size(size):
	return int(lerp(16, 128, size))


func get_album_id():
	return str(OS.get_unix_time()).md5_text()


func delete_album():
	settings.albums.erase(current_album_id)


func new_album():
	var album = Album.new()
	current_album_id = get_album_id()
	settings.albums[current_album_id] = album


func remove_empty_albums():
	var ids = []
	for id in settings.albums:
		if settings.albums[id].title.empty():
			ids.append(id)
	for id in ids:
		settings.albums.erase(id)
		if current_album_id == id:
			current_album_id = null


func set_album_property(prop, value):
	settings.albums[current_album_id][prop] = value


func get_album_property(prop):
	return settings.albums[current_album_id][prop]


func add_track(side, track):
	if side == 0:
		settings.albums[current_album_id].a_side.append(track)
	else:
		settings.albums[current_album_id].b_side.append(track)


func remove_track(side, track):
	if side == 0:
		settings.albums[current_album_id].a_side.erase(track)
	else:
		settings.albums[current_album_id].b_side.erase(track)
