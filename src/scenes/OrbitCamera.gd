extends Spatial

func _process(delta):
	if (Input.is_key_pressed(KEY_LEFT)):
		rotate_y(delta)
	if (Input.is_key_pressed(KEY_RIGHT)):
		rotate_y(-delta)
	if (Input.is_key_pressed(KEY_UP)):
		rotate_x(delta)
	if (Input.is_key_pressed(KEY_DOWN)):
		rotate_x(-delta)
