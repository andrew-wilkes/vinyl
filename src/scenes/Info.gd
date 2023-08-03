extends AcceptDialog

func open(tab_idx = 0):
	$TabContainer.set_current_tab(tab_idx)
	popup_centered()


func _on_Author_meta_clicked(_meta):
	var _e = OS.shell_open("https://buymeacoffee.com/gdscriptdude")
