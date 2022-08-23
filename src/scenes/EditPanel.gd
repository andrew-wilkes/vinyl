extends PanelContainer

signal text_updated(side, idx, txt)

var side
var idx

func open(_side, _idx, txt):
	side = _side
	idx = _idx
	$HB/LineEdit.text = txt
	$HB/LineEdit.grab_focus()
	rect_position = (get_viewport().get_visible_rect().size - rect_size) / 2.0
	show()


func _on_OK_pressed():
	exit()


func _on_LineEdit_text_entered(_new_text):
	exit()


func exit():
	hide()
	emit_signal("text_updated", side, idx, $HB/LineEdit.text)
