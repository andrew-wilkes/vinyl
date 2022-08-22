extends PanelContainer

signal text_updated(side, idx, txt)

var side
var idx

func open(_side, _idx, txt):
	side = _side
	idx = _idx
	$HB/LineEdit.text = txt
	show()


func _on_OK_pressed():
	emit_signal("text_updated", side, idx, $HB/LineEdit.text)
