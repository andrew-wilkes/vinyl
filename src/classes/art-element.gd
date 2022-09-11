extends Resource

class_name ArtElement

enum { AB, ABROT, CIRC, ARC, LINE, DOT, SQR, BOX }

var ref

export(int) var type
export(float) var size
export(float) var length
export var position = Vector2.ZERO
export(float) var rotation
export(Color) var color = Color.white
export var text = ""
export var font = ""

func get_hash():
	var t = text + font
	return t.hash() + color.to_argb32() + size + length + rotation + position.x + position.y
