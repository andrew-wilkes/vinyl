extends Spatial

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

func _ready():
	relocate_collision_area($LeverArea, lever_handle)
	relocate_collision_area($HandleArea, arm_handle)
	relocate_collision_area($SwitchArea, switch)


func relocate_collision_area(src: Spatial, dest: Spatial):
	src.translation = Vector3.ZERO
	remove_child(src)
	dest.add_child(src)
	src.get_child(0).rotation = Vector3.ZERO


func _process(_delta):
	pass
	#arm_angle += delta * 0.01
	#raise_arm(arm_angle)


func rotate_arm(angle):
	arm_base.rotate_y(angle)


func raise_arm(angle):
	arm.rotate_object_local(Vector3(1, 0, 0), angle)


func raise_support(_dist):
	pass


func _on_Lever_input_event(_camera, _event, _position, _normal, _shape_idx):
	pass # Replace with function body.


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
