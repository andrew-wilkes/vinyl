extends PopupPanel

signal text_copied

func _on_CopyText_pressed():
	OS.set_clipboard($"%PanelText".text)
	hide()
	emit_signal("text_copied")


func _on_OK_pressed():
	hide()
