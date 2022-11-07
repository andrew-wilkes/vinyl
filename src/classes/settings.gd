extends Resource

class_name Settings

const FILENAME = "user://settings.res"

export var albums = {}
export var tracks = []
export var last_dir = ""
export var last_image_dir = ""
export var last_font_dir = ""
export var volume = 8.0
export var background_image = ""

func save_data():
	g.remove_empty_albums()
	var _e = ResourceSaver.save(FILENAME, self)


func load_data():
	if ResourceLoader.exists(FILENAME):
		return ResourceLoader.load(FILENAME)
	else:
		last_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
		last_image_dir = last_dir
		last_font_dir = g.get_font_dir()
		return self
