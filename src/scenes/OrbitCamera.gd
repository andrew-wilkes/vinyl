extends Spatial

export var ROTATION_SPEED = 0.01
export var PANNING_SPEED = 0.02
export var ZOOMING_SPEED = 0.05
export var KEY_SPEED = 2.0

enum { ROTATING, PANNING, ZOOMING }

var moving = false
var locked = false
var reset_transform

func _ready():
	reset_transform = $YAxis/XAxis/Camera.transform


func lock():
	moving = false
	locked = true


func reset_position():
	$YAxis/XAxis/Camera.transform = reset_transform


func _process(delta):
	delta *= KEY_SPEED
	# Need to hold the shift key to use the arrow keys
	if Input.is_physical_key_pressed(KEY_SHIFT):
		if (Input.is_physical_key_pressed(KEY_LEFT)):
			$YAxis.rotate_y(delta)
		if (Input.is_physical_key_pressed(KEY_RIGHT)):
			$YAxis.rotate_y(-delta)
		if (Input.is_physical_key_pressed(KEY_UP)):
			$YAxis/XAxis.rotate_x(delta)
		if (Input.is_physical_key_pressed(KEY_DOWN)):
			$YAxis/XAxis.rotate_x(-delta)
	if (Input.is_physical_key_pressed(KEY_Z)):
		$YAxis/XAxis/Camera.translation.z += delta
	if (Input.is_physical_key_pressed(KEY_X)):
		$YAxis/XAxis/Camera.translation.z -= delta
	if (Input.is_physical_key_pressed(KEY_W)):
		$YAxis/XAxis/Camera.translation.y -= delta
	if (Input.is_physical_key_pressed(KEY_A)):
		$YAxis/XAxis/Camera.translation.x += delta
	if (Input.is_physical_key_pressed(KEY_S)):
		$YAxis/XAxis/Camera.translation.y += delta
	if (Input.is_physical_key_pressed(KEY_D)):
		$YAxis/XAxis/Camera.translation.x -= delta


func _unhandled_input(event):
	if locked: return
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			moving = true
		else:
			moving = false
		
	if event is InputEventMouseMotion and moving:
		var mode = ROTATING
		if Input.is_physical_key_pressed(KEY_SHIFT):
			mode = PANNING
		if Input.is_physical_key_pressed(KEY_CONTROL):
			mode = ZOOMING
		match mode:
			PANNING:
				$YAxis/XAxis/Camera.translation.x += event.relative.x * PANNING_SPEED
				$YAxis/XAxis/Camera.translation.y += event.relative.y * PANNING_SPEED
			ROTATING:
				$YAxis/XAxis.rotate_x(event.relative.y * ROTATION_SPEED)
				$YAxis.rotate_y(event.relative.x * ROTATION_SPEED)
			ZOOMING:
				$YAxis/XAxis/Camera.translation.z += event.relative.y * ZOOMING_SPEED
