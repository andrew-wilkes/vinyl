extends Resource

class_name Settings

const FILENAME = "user://settings.res"

export var albums = {}
export var tracks = []
export var last_dir = ""
export var last_image_dir = ""
export var last_font_dir = ""
export var volume = 4.0
export var bg_images = [null, null]
export var deck_color = Color(0x003bb7ff)
export var cart_color = Color(0xd79802ff)
export var bg_color = Color(0x17408eff)
export var fg_color = Color(0x12419bff)
export var bg_color_3d = [Color(0x434343ff), Color(0x434343ff)]
export var bg_modes = [0, 0]
export var bg_brightness = [50.0, 50.0]
export var env_brightness = [50.0, 50.0]

func save_data():
	g.remove_empty_albums()
	var _e = ResourceSaver.save(FILENAME, self)


func load_data():
	if ResourceLoader.exists(FILENAME):
		return ResourceLoader.load(FILENAME)
	else:
		last_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
		last_image_dir = last_dir
		last_font_dir = get_font_dir()
		return self


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
