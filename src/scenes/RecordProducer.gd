extends Control

enum { SIDE_A, SIDE_B }

const X_PITCH = 25.4 / 16 * 0.1 # >= 16 grooves per inch
const LAST_MUSIC_GROOVE = [120.6, 108.0, 120.6]
const FIRST_MUSIC_GROOVE = [292.1, 168.3, 241.3]
const RPMS = { "speed33": 33.33, "speed45": 45.0, "speed78": 78.0 }
const SIZES = [ "size12", "size7", "size10" ]

onready var tracks = [$VBox/HB2/VB1/ATracks, $VBox/HB2/VB2/BTracks]
onready var bars = [$VBox/HB1/VB3/HB/UA, $VBox/HB1/VB3/HB2/UB]
onready var times = [$VBox/HB1/VB3/HB/TimeA, $VBox/HB1/VB3/HB2/TimeB]

var audio
var current_track
var pitch
var size_group
var speed_group

func _ready():
	var _e = $c/TrackSelector.connect("add_tracks", self, "add_tracks")
	_e = $c/EditPanel.connect("text_updated", self, "update_track_title")
	audio = Audio.new($AudioStreamPlayer)
	size_group = $VBox/HB1/VB1/size10.group
	speed_group = $VBox/HB1/VB2/speed33.group
	$VBox/HB/VB1/Title.grab_focus()
	_on_Pitch_value_changed(0.23)
	$VBox/HB1/VB3/HB3/Pitch.value = pitch
	for b in size_group.get_buttons():
		_e = b.connect("pressed", self, "update_utilizations")
	for b in speed_group.get_buttons():
		_e = b.connect("pressed", self, "update_utilizations")


func get_rpm():
	return RPMS[speed_group.get_pressed_button().name]


func get_size():
	return SIZES.find(size_group.get_pressed_button().name)


func _on_AddToA_pressed():
	$c/TrackSelector.open(SIDE_A)


func _on_AddToB_pressed():
	$c/TrackSelector.open(SIDE_B)


func add_tracks(items, side):
	# Add track to list and get meta data from audio file
	# There are 2 columns of cells in ItemList so divide index by 2
	for idx in items:
		var track = g.settings.tracks[idx / 2]
		audio.load_data(track.path)
		track.title = audio.info.get("title", "")
		track.band = audio.info.get("band", "")
		track.album = audio.info.get("album", "")
		track.year = audio.info.get("year", "")
		track.length = audio.player.stream.get_length()
		tracks[side].add_item(track.title)
		tracks[side].set_item_metadata(tracks[side].get_item_count() - 1, track)
	update_utilization(side)


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
	if current_track:
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
	if current_track:
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
	tracks[side].get_item_metadata(idx).title = txt


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
		var track = tracks[side].get_item_metadata(items[0])
		if current_track != track:
			audio.load_data(track.path) # Set the stream
			current_track = track


func set_play_button_text(play = true):
	var ptext = "Stop" if play else "Play"
	$VBox/HB2/VB1/HB/PlayA.text = ptext
	$VBox/HB2/VB2/HB/PlayB.text = ptext


func _on_AudioStreamPlayer_finished():
	set_play_button_text(false)


func utilization(rpm, tsecs, size):
	return rpm / 60 * tsecs * pitch / (FIRST_MUSIC_GROOVE[size] - LAST_MUSIC_GROOVE[size])


func update_utilization(side):
	var u = 0
	var time = 0
	var rpm = get_rpm()
	var size = get_size()
	for idx in tracks[side].get_item_count():
		var track = tracks[side].get_item_metadata(idx)
		u += utilization(rpm, track.length, size)
		time += track.length
	bars[side].value = u * 100
# warning-ignore:integer_division
	times[side].text = "%02d:%02d" % [int(time) / 60, int(time) % 60]


func _on_Pitch_value_changed(value):
	$VBox/HB1/VB3/HB3/PV.text = "%0.2f mm" % value
	pitch = value
	update_utilizations()


func update_utilizations():
	update_utilization(SIDE_A)
	update_utilization(SIDE_B)
