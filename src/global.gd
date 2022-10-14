extends Node

var settings
var default_art = []
var current_album_id

func _init():
	settings = Settings.new()
	settings = settings.load_data()
	pass #settings.albums.clear()
	default_art.append(load("res://assets/a-side.png"))
	default_art.append(load("res://assets/b-side.png"))
	default_art.append(load("res://assets/cover-front.png"))
	default_art.append(load("res://assets/cover-rear.png"))

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


func get_resized_texture(path, size):
	var resized = ImageTexture.new()
	var texture = ImageTexture.new()
	var image = Image.new()
	var file = File.new()
	if file.file_exists(path):
		image.load(path)
		texture.create_from_image(image)
		image.resize(size, size)
		resized.create_from_image(image)
	else:
		texture = null
	return { texture = texture, resized = resized}


func get_font_dir():
	var dir = ""
	var dirs = []
	match OS.get_name():
		"Windows":
			dirs = ["%appdata%/Local/Microsoft/Windows/Fonts", "/%windir%/fonts"]
		"OSX":
			dirs = ["~/Library/Fonts/", "/Library/Fonts/", " /System/Library/Fonts/"]
		"X11":
			dirs = ["~/.fonts", "/usr/share/fonts"]
	var d = Directory.new()
	for path in dirs:
		if d.dir_exists(path):
			dir = path
			break
	return dir


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
