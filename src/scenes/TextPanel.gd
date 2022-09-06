extends PopupPanel

func _on_CopyText_pressed():
	OS.set_clipboard($VB/A2/VB/Text.text)


func _on_OK_pressed():
	hide()
