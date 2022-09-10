extends Node

var settings
var default_art = []

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
