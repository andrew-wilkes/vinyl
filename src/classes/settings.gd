extends Resource

class_name Settings

const FILENAME = "user://settings.res"

export var albums = []
export var last_dir = ""

func save_data():
	ResourceSaver.save(FILENAME, self)


func load_data():
	if ResourceLoader.exists(FILENAME):
		return ResourceLoader.load(FILENAME)
	else:
		last_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
		return self
