extends PanelContainer

func open(track):
	rect_position = (get_viewport().get_visible_rect().size - rect_size) / 2.0
	$VB/Grid/Title.text = track.title
	$VB/Grid/Band.text = track.band
	$VB/Grid/Album.text = track.album
	$VB/Grid/Year.text = track.year
# warning-ignore:integer_division
	$VB/Grid/Length.text = "%02d:%02d" % [int(track.length) / 60, int(track.length) % 60]
	show()


func _on_OK_pressed():
	hide()
