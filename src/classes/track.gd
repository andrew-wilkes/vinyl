extends Resource

class_name Track

export var title = ""
export var band = ""
export var album = ""
export var year = ""
export var path = ""
export var length = 0

func _to_string():
	return title
