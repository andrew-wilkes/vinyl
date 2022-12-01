extends TextureButton

class_name HoverTextureButton

export(Color) var mod_color = Color(0.8, 0.8, 0.8)

func _ready():
	var _e = connect("mouse_entered", self, "_on_HoverTextureButton_mouse_entered")
	_e = connect("mouse_exited", self, "_on_HoverTextureButton_mouse_exited")
	modulate = Color.white


func _on_HoverTextureButton_mouse_entered():
	modulate = mod_color


func _on_HoverTextureButton_mouse_exited():
	modulate = Color.white
