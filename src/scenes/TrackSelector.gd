extends PanelContainer

signal add_tracks(items, side)

onready var tracks = $VB/SC/Tracks

var side

func _ready():
	hide()
	for track in g.settings.tracks:
		tracks.add_item(track.title)
		tracks.add_item(track.path.get_base_dir().split("/")[-1], null, false)


func open(_side):
	side = _side
	show()


func _on_Cancel_pressed():
	hide()


func _on_Add_pressed():
	emit_signal("add_tracks", tracks.get_selected_items(), side)
