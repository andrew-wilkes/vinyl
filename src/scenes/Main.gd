extends Control

func _on_Tracks_pressed():
	$c/Fader.fade_out("MusicTracks")


func _on_Artwork_pressed():
	$c/Fader.fade_out("AlbumArt")


func _on_Producer_pressed():
	$c/Fader.fade_out("RecordProducer")


func _on_Collection_pressed():
	$c/Fader.fade_out("MusicLibrary")


func _on_Player_pressed():
	$c/Fader.fade_out("Turntable")


func _on_Gear_pressed():
	$c/Fader.fade_out("Gear")
