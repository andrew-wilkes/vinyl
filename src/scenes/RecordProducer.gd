extends Control

enum { SIDE_A, SIDE_B }

onready var tracks = [$VBox/HB2/VB1/ATracks, $VBox/HB2/VB2/BTracks]

var audio
var currently_loaded_track = -1
var current_track

func _ready():
	var _e = $c/TrackSelector.connect("add_tracks", self, "add_tracks")
	_e = $c/EditPanel.connect("text_updated", self, "update_track_title")
	audio = Audio.new($AudioStreamPlayer)


func _on_AddToA_pressed():
	$c/TrackSelector.open(SIDE_A)


func _on_AddToB_pressed():
	$c/TrackSelector.open(SIDE_B)


func add_tracks(items, side):
	# There are 2 columns of cells in ItemList so divide index by 2
	for idx in items:
		tracks[side].add_item(g.settings.tracks[idx / 2].title)
		tracks[side].set_item_metadata(tracks[side].get_item_count() - 1, idx / 2)


func _on_DeleteA_pressed():
	remove_tracks(tracks[SIDE_A])


func remove_tracks(list):
	var list_offset = 0
	for idx in list.get_selected_items():
		list.remove_item(idx - list_offset)
		list_offset += 1


func _on_EditA_pressed():
	edit_track_title(SIDE_A)


func _on_InfoA_pressed():
	load_track(SIDE_A)
	$c/TrackInfo.open(current_track)


func _on_PlayA_pressed():
	if audio.player.playing:
		audio.player.stop()
	else:
		load_track(SIDE_A)
		audio.player.play()
	set_play_button_text(audio.player.playing)


func _on_DeleteB_pressed():
	remove_tracks(tracks[SIDE_B])


func _on_EditB_pressed():
	edit_track_title(SIDE_B)


func edit_track_title(side):
	var items = tracks[side].get_selected_items()
	if items.size() > 0:
		$c/EditPanel.open(side, items[0], tracks[side].get_item_text(items[0]))


func _on_InfoB_pressed():
	load_track(SIDE_B)
	$c/TrackInfo.open(current_track)


func _on_PlayB_pressed():
	if audio.player.playing:
		audio.player.stop()
	else:
		load_track(SIDE_B)
		audio.player.play()
	set_play_button_text(audio.player.playing)


func update_track_title(side, idx, txt):
	tracks[side].set_item_text(idx, txt)


func _on_Up_pressed(side):
	var items = tracks[side].get_selected_items()
	for idx in items:
		if idx == 0: break
		tracks[side].move_item(idx, idx - 1)


func _on_Down_pressed(side):
	var items = tracks[side].get_selected_items()
	items.invert()
	for idx in items:
		if idx == tracks[side].get_item_count() - 1: break
		tracks[side].move_item(idx, idx + 1)


func load_track(side):
	var items = tracks[side].get_selected_items()
	if items.size() > 0:
		var track_idx = tracks[side].get_item_metadata(items[0])
		if track_idx != currently_loaded_track:
			current_track = g.settings.tracks[track_idx]
			currently_loaded_track = track_idx
			audio.load_data(current_track.path)
			current_track.title = audio.info.get("title", "")
			current_track.band = audio.info.get("band", "")
			current_track.album = audio.info.get("album", "")
			current_track.year = audio.info.get("year", "")
			current_track.length = audio.player.stream.get_length()


func set_play_button_text(play = true):
	var ptext = "Stop" if play else "Play"
	$VBox/HB2/VB1/HB/PlayA.text = ptext
	$VBox/HB2/VB2/HB/PlayB.text = ptext
