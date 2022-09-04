extends ColorRect

func _ready():
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	pass



func _on_Snap_pressed():
	var img = get_parent().get_viewport().get_texture().get_data()
	img.flip_y()
	img.save_png("res://temp.png")
