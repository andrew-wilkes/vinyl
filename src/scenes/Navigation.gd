extends PanelContainer

var hovered_bar

export var current_selection = 0
export var selected_color = Color.green
export var hovered_color = Color.yellow

const scenes = ["MusicTracks", "AlbumArt", "RecordProducer", "MusicLibrary", "Turntable", "Gear"]

func _ready():
	for n in $HBox.get_child_count():
		var node = $HBox.get_child(n)
		var _e = node.get_child(0).connect("pressed", self, "button_pressed", [n])
		_e = node.get_child(0).connect("mouse_entered", self, "mouse_entered", [n])
		_e = node.get_child(0).connect("mouse_exited", self, "mouse_exited")
		var bar = node.get_child(1)
		if n == current_selection:
			bar.show()
			bar.modulate = selected_color
		else:
			bar.hide()
			bar.modulate = hovered_color


func button_pressed(idx):
	hovered_bar = null
	if idx != current_selection:
		$c/Fader.fade_out(scenes[idx])


func mouse_entered(idx):
	hovered_bar = null
	if idx != current_selection:
		hovered_bar = $HBox.get_child(idx).get_child(1) 
		hovered_bar.show()


func mouse_exited():
	if hovered_bar: hovered_bar.hide()
