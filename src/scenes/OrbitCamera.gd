extends Spatial

func _process(delta):
	if (Input.is_key_pressed(KEY_LEFT)):
		$YAxis.rotate_y(delta)
	if (Input.is_key_pressed(KEY_RIGHT)):
		$YAxis.rotate_y(-delta)
	if (Input.is_key_pressed(KEY_UP)):
		$YAxis/XAxis.rotate_x(delta)
	if (Input.is_key_pressed(KEY_DOWN)):
		$YAxis/XAxis.rotate_x(-delta)
	if (Input.is_key_pressed(KEY_Z)):
		$YAxis/XAxis/Camera.translation.z += delta
	if (Input.is_key_pressed(KEY_X)):
		$YAxis/XAxis/Camera.translation.z -= delta
	if (Input.is_key_pressed(KEY_W)):
		$YAxis/XAxis/Camera.translation.y -= delta
	if (Input.is_key_pressed(KEY_A)):
		$YAxis/XAxis/Camera.translation.x += delta
	if (Input.is_key_pressed(KEY_S)):
		$YAxis/XAxis/Camera.translation.y += delta
	if (Input.is_key_pressed(KEY_D)):
		$YAxis/XAxis/Camera.translation.x -= delta

