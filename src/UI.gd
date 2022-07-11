extends PanelContainer

enum { FORWARD, BACKWARDS }

var play_direction = FORWARD

func _ready():
	pass # Replace with function body.


func _on_Play_pressed():
	play_direction = FORWARD


func _on_Stop_pressed():
	play_direction = FORWARD


func _on_Rewind_pressed():
	play_direction = BACKWARDS
