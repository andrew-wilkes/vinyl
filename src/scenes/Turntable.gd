extends Spatial

enum { NONE, MOVING_LEVER, MOVING_HANDLE, MOVING_SWITCH }

onready var arm = find_node("Arm")
onready var arm_base = find_node("ArmBase")
onready var arm_handle = find_node("Handle")
onready var lever: MeshInstance = find_node("Lever")
onready var platter = find_node("Platter")
onready var switch = find_node("Switch")
onready var weight = find_node("Weight")
onready var support = find_node("SupportPin")
onready var lever_handle = find_node("LeverHandle")
onready var lever_handle_shader = lever_handle.mesh.surface_get_material(0).next_pass
onready var switch_handle_shader = switch.mesh.surface_get_material(0).next_pass
onready var arm_handle_shader = arm_handle.mesh.surface_get_material(0).next_pass

var arm_angle = 0
var mode = NONE
var support_pos = 1.0
var lever_pos = 1.0
var arm_base_transform
var angle_limit

func _ready():
	relocate_collision_area($LeverArea, lever_handle)
	relocate_collision_area($HandleArea, arm_handle)
	relocate_collision_area($SwitchArea, switch)
	arm_base_transform = arm.transform


func relocate_collision_area(src: Spatial, dest: Spatial):
	src.translation = Vector3.ZERO
	remove_child(src)
	dest.add_child(src)
	src.get_child(0).rotation = Vector3.ZERO


func _process(delta):
	# Move support in relation to lever position
	if lever_pos >= support_pos:
		support_pos = lever_pos
	else:
		support_pos -= delta * 0.4
	support.translation.y = lerp(-0.073, 0.114, support_pos)
	
	# Calculate the angle limit for the arm
	angle_limit = atan((0.114 - support.translation.y) / 0.3952)
	
	# Make arm fall if within angle_limit
	if get_arm_angle() < (angle_limit - 0.05):
		arm.rotate_object_local(Vector3(1, 0, 0), -delta * 0.8)
	else:
		arm.transform = arm_base_transform
		arm.rotate_object_local(Vector3(1, 0, 0), -angle_limit)


func rotate_arm(angle):
	arm_base.rotate_y(angle)


func raise_arm(angle):
	arm.rotate_object_local(Vector3(1, 0, 0), angle)


func raise_support(_dist):
	pass


func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.pressed:
		mode = NONE
		$OrbitCamera.locked = false
	if event is InputEventMouseMotion:
		match mode:
			MOVING_LEVER:
				lever.rotation.x = clamp(lever.rotation.x - event.relative.y * 0.01, -1.33, -0.73)
				lever_pos = (lever.rotation.x + 1.33) / (1.33 - 0.73)
			MOVING_HANDLE:
				pass
			MOVING_SWITCH:
				pass


func _on_Lever_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		mode = MOVING_LEVER
		$OrbitCamera.lock()


func _on_Lever_mouse_entered():
	lever_handle_shader.set_shader_param("Level", 1.0)


func _on_Lever_mouse_exited():
	lever_handle_shader.set_shader_param("Level", 0.0)


func _on_HandleArea_input_event(_camera,_event, _position, _normal, _shape_idx):
	pass # Replace with function body.


func _on_HandleArea_mouse_entered():
	arm_handle_shader.set_shader_param("Level", 1.0)


func _on_HandleArea_mouse_exited():
	arm_handle_shader.set_shader_param("Level", 0.0)


func _on_SwitchArea_input_event(_camera, _event, _position, _normal, _shape_idx):
	pass # Replace with function body.


func _on_SwitchArea_mouse_entered():
	switch_handle_shader.set_shader_param("Level", 1.0)


func _on_SwitchArea_mouse_exited():
	switch_handle_shader.set_shader_param("Level", 0.0)


func get_arm_angle():
	return (1.5708 - arm.rotation.x) * 11.162
