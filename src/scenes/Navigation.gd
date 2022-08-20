extends PanelContainer

signal nav_button_pressed(idx)

var current_selection = 0
var hovered_bar

export var selected_color = Color.green
export var hovered_color = Color.yellow

func _ready():
	for n in $HBox.get_child_count():
		var node = $HBox.get_child(n)
		var _e = node.get_child(0).connect("pressed", self, "button_pressed", [n])
		_e = node.get_child(0).connect("mouse_entered", self, "mouse_entered", [n])
		_e = node.get_child(0).connect("mouse_exited", self, "mouse_exited")
		node.get_child(1).visible = n < 1
		node.get_child(1).modulate = selected_color


func button_pressed(idx):
	current_selection = idx
	hovered_bar = null
	for n in $HBox.get_child_count():
		var bar = $HBox.get_child(n).get_child(1)
		if  n == idx:
			bar.modulate = selected_color
			bar.show()
		else:
			bar.hide()
	emit_signal("nav_button_pressed", idx)


func mouse_entered(idx):
	hovered_bar = null
	if idx != current_selection:
		hovered_bar = $HBox.get_child(idx).get_child(1) 
		hovered_bar.modulate = hovered_color
		hovered_bar.show()


func mouse_exited():
	if hovered_bar: hovered_bar.hide()
