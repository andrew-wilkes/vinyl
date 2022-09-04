extends Node

var settings

func _init():
	settings = Settings.new()
	settings = settings.load_data()
	pass #settings.albums.clear()


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			save_and_quit()


# Handle shutdown of App
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		save_and_quit()


func save_and_quit():
	settings.save_data()
	if get_parent().get_child(1).name == "Main":
		get_tree().quit()
	else:
		get_parent().get_child(1).find_node("Fader").fade_out("Main")


func format_time(time):
# warning-ignore:integer_division
	return "%02d:%02d" % [int(time) / 60, int(time) % 60]
