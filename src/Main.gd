extends Spatial

var settings

func _ready():
	pass


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			save_and_quit()


# Handle shutdown of App
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		save_and_quit()


func save_and_quit():
	g.settings.save_data()
	get_tree().quit()
