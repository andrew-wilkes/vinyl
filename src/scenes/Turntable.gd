extends Spatial

func _ready():
	var handle = find_node("Handle")
	var marker = $Marker
	marker.translation = Vector3.ZERO
	remove_child(marker)
	handle.add_child(marker)
	marker.set_owner(handle)


func lower_lever():
	pass


func raise_lever():
	pass


func rotate_arm(_angle):
	pass


func move_arm(_vpos):
	pass


func _on_Handle_input_event(camera, event, position, normal, shape_idx):
	pass # Replace with function body.


func _on_Handle_mouse_entered():
	print("Entered")
	pass # Replace with function body.


func _on_Handle_mouse_exited():
	pass # Replace with function body.
