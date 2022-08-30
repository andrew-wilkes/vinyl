extends Control

func _on_Tracks_pressed():
	var _e = get_tree().change_scene("res://scenes/MusicTracks.tscn")


func _on_Artwork_pressed():
	var _e = get_tree().change_scene("res://scenes/AlbumArt.tscn")


func _on_Producer_pressed():
	var _e = get_tree().change_scene("res://scenes/RecordProducer.tscn")


func _on_Collection_pressed():
	var _e = get_tree().change_scene("res://scenes/MusicLibrary.tscn")


func _on_Player_pressed():
	var _e = get_tree().change_scene("res://scenes/Turntable.tscn")


func _on_Gear_pressed():
	var _e = get_tree().change_scene("res://scenes/Gear.tscn")
