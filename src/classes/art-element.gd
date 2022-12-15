extends Resource

class_name ArtElement

enum { AB, ABROT, CIRC, ARC, LINE, DOT, SQR, BOX }

var ref
var font

export(int) var type
export(float) var size
export(float) var length
export(float) var thickness
export var position = Vector2.ZERO
export(float) var rotation
export(Color) var color = Color.black
export var text = ""
export var font_path = ""

func get_hash():
	var t = text + font_path
	return t.hash() + color.to_argb32() + size + length + thickness + rotation + position.x + position.y


func _to_string():
	return String({
		type = type,
		size = size,
		length = length,
		position = position,
		rotation = rotation,
		thickness = thickness
	})
