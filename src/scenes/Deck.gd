extends Spatial

onready var arm = find_node("Arm")
onready var arm_base = find_node("ArmBase")
onready var handle = find_node("Handle")
onready var lever: MeshInstance = find_node("Lever")
onready var platter = find_node("Platter")
onready var knob = find_node("Switch")
onready var weight = find_node("Weight")
onready var support = find_node("SupportPin")
onready var hlighter = find_node("LeverHandle").mesh.surface_get_material(0).next_pass

var arm_angle = 0

func _ready():
	print(arm)
	pass
	#arm.rotate_x(0.1)


func _process(delta):
	pass
	#arm_angle += delta * 0.01
	#raise_arm(arm_angle)


func rotate_arm(angle):
	arm_base.rotate_y(angle)


func raise_arm(angle):
	arm.rotate_object_local(Vector3(1, 0, 0), angle)


func raise_support(dist):
	pass


func _on_Lever_input_event(_camera, _event, _position, _normal, _shape_idx):
	pass # Replace with function body.


func _on_Lever_mouse_entered():
	hlighter.set_shader_param("Level", 1.0)
	print("Entered")


func _on_Lever_mouse_exited():
	hlighter.set_shader_param("Level", 0.0)
	print("Exited")
