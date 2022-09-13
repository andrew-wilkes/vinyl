extends Resource

class_name Settings

const FILENAME = "user://settings.res"

export var albums = {}
export var tracks = []
export var last_dir = ""
export var last_image_dir = ""
export var last_font_dir = ""
export var volume = 8.0

var album_id

func save_data():
	remove_empty_albums()
	var _e = ResourceSaver.save(FILENAME, self)


func load_data():
	if ResourceLoader.exists(FILENAME):
		return ResourceLoader.load(FILENAME)
	else:
		last_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
		last_image_dir = last_dir
		last_font_dir = g.get_font_dir()
		return self


func get_album_id():
	return str(OS.get_unix_time()).md5_text()


func delete_album():
	albums.erase(album_id)


func new_album():
	var album = Album.new()
	album_id = get_album_id()
	albums[album_id] = album


func remove_empty_albums():
	var ids = []
	for id in albums:
		if albums[id].title.empty():
			ids.append(id)
	for id in ids:
		albums.erase(id)


func set_album_property(prop, value):
	albums[album_id][prop] = value


func get_album_property(prop):
	return albums[album_id][prop]


func add_track(side, track):
	if side == 0:
		albums[album_id].a_side.append(track)
	else:
		albums[album_id].b_side.append(track)


func remove_track(side, track):
	if side == 0:
		albums[album_id].a_side.erase(track)
	else:
		albums[album_id].b_side.erase(track)
