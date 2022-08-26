extends Control

enum { SIDE_A, SIDE_B }

const X_PITCH = 25.4 / 16 * 0.1 # >= 16 grooves per inch
const LAST_MUSIC_GROOVE = [120.6, 108.0, 120.6]
const FIRST_MUSIC_GROOVE = [292.1, 168.3, 241.3]
const RPMS = { "speed33": 33.33, "speed45": 45.0, "speed78": 78.0 }
const SIZES = [ "size12", "size7", "size10" ]
const GAP_TIME = 5
const VU_COUNT = 8
const FREQ_MAX = 11050.0

onready var tracks = [$VBox/HB2/VB1/ATracks, $VBox/HB2/VB2/BTracks]
onready var bars = [$VBox/HB1/VB3/HB/UA, $VBox/HB1/VB3/HB2/UB]
onready var times = [$VBox/HB1/VB3/HB/TimeA, $VBox/HB1/VB3/HB2/TimeB]
onready var audio_bar = $VBox/HB1/VB3/HB3/AudioBar

var audio
var current_track
var pitch
var size_group
var speed_group
var spectrum

export(Color) var gap_color
export(Color) var ok_color
export(Color) var warn_color
export(Color) var spare_color

func _ready():
	var _e = $c/TrackSelector.connect("add_tracks", self, "add_tracks")
	_e = $c/EditPanel.connect("text_updated", self, "update_track_title")
	audio = Audio.new($AudioStreamPlayer)
	size_group = $VBox/HB1/VB1/size10.group
	speed_group = $VBox/HB1/VB2/speed33.group
	$VBox/HB/VB1/VB1/Title.grab_focus()
	_on_Pitch_value_changed(0.23)
	$VBox/HB1/VB3/HB3/Pitch.value = pitch
	for b in size_group.get_buttons():
		_e = b.connect("pressed", self, "update_utilizations")
	for b in speed_group.get_buttons():
		_e = b.connect("pressed", self, "update_utilizations")
	for idx in 2:
		bars[idx].material.set_shader_param("gap_color", gap_color)
		bars[idx].material.set_shader_param("ok_color", ok_color)
		bars[idx].material.set_shader_param("warn_color", warn_color)
		bars[idx].material.set_shader_param("spare_color", spare_color)
	set_play_state(false)
	AudioServer.add_bus_effect(0, AudioEffectSpectrumAnalyzer.new())
	spectrum = AudioServer.get_bus_effect_instance(0, 0)

var count = 0
func _process(_delta):
	if audio.player.playing:
		count += 1
		var prev_hz = 0
		var data = PoolByteArray()
		for i in range(1, VU_COUNT + 1):
			var hz = i * FREQ_MAX / VU_COUNT;
			var magnitude = spectrum.get_magnitude_for_frequency_range(prev_hz, hz).length()
			data.append(255 * clamp(magnitude * 3.0, 0, 1))
			prev_hz = hz
		var img = Image.new()
		img.create_from_data(1, VU_COUNT, false, Image.FORMAT_R8, data)
		var texture = ImageTexture.new()
		texture.create_from_image(img, 0)
		audio_bar.material.set_shader_param("data", texture)


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
		var track = g.settings.tracks[idx / 2].duplicate()
		audio.load_data(track.path)
		track.title = audio.info.get("title", "")
		track.band = audio.info.get("band", "")
		if $VBox/HB/VB1/VB2/Band.text.empty():
			$VBox/HB/VB1/VB2/Band.text = track.band
		track.album = audio.info.get("album", "")
		if $VBox/HB/VB1/VB1/Title.text.empty():
			$VBox/HB/VB1/VB1/Title.text = track.album
		track.year = audio.info.get("year", "")
		track.length = audio.player.stream.get_length()
		tracks[side].add_item(track.title)
		tracks[side].set_item_metadata(tracks[side].get_item_count() - 1, track)
		if current_track == null:
			current_track = track
			tracks[side].select(tracks[side].get_item_count() - 1)
			
	update_utilization(side)


func _on_DeleteA_pressed():
	remove_tracks(tracks[SIDE_A])
	update_utilization(SIDE_A)


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
	load_track(SIDE_A)
	if current_track:
		set_play_state(true)


func set_play_state(play):
	if play:
		audio.player.play()
		audio_bar.modulate.a = 1
		$VBox/HB2/VB1/HB/PlayA.hide()
		$VBox/HB2/VB2/HB/PlayB.hide()
		$VBox/HB2/VB1/HB/StopA.show()
		$VBox/HB2/VB2/HB/StopB.show()
	else:
		audio.player.stop()
		audio_bar.modulate.a = 0
		$VBox/HB2/VB1/HB/PlayA.show()
		$VBox/HB2/VB2/HB/PlayB.show()
		$VBox/HB2/VB1/HB/StopA.hide()
		$VBox/HB2/VB2/HB/StopB.hide()


func _on_DeleteB_pressed():
	remove_tracks(tracks[SIDE_B])
	update_utilization(SIDE_B)


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
	load_track(SIDE_B)
	if current_track:
		set_play_state(true)


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


func _on_AudioStreamPlayer_finished():
	set_play_state(false)


func get_capacity(rpm, size):
	return (FIRST_MUSIC_GROOVE[size] - LAST_MUSIC_GROOVE[size]) * 60 / rpm / pitch


func utilization(rpm, tsecs, size):
	return tsecs / get_capacity(rpm, size)


func update_utilization(side):
	var time = 0
	var img = Image.new()
	var idata = PoolByteArray()
	var overflow = false
	var capacity = get_capacity(get_rpm(), get_size())
	var data = PoolByteArray()
	for idx in tracks[side].get_item_count():
		var track = tracks[side].get_item_metadata(idx)
		time += track.length
		if idx > 0:
			time += GAP_TIME
			data.resize(GAP_TIME)
			data.fill(100)
			idata.append_array(data)
		if not overflow:
			if time > capacity:
				overflow = true
				var size = capacity - idata.size()
				if size > 0:
					data.resize(size)
					data.fill(255)
					idata.append_array(data)
				break
			else:
				data.resize(track.length)
				data.fill(140)
				idata.append_array(data)
	if idata.size() < capacity:
		data.resize(capacity - idata.size())
		data.fill(0)
		idata.append_array(data)
	img.create_from_data(idata.size(), 1, false, Image.FORMAT_R8, idata)
	var texture = ImageTexture.new()
	texture.create_from_image(img, 0)
	bars[side].material.set_shader_param("data", texture)
# warning-ignore:integer_division
	times[side].text = "%02d:%02d" % [int(time) / 60, int(time) % 60]
	if overflow:
		times[side].modulate = Color.red
	else:
		times[side].modulate = Color.white
# warning-ignore:integer_division
	$VBox/HB1/VB3/HB4/Capacity.text = "%02d:%02d" % [int(capacity) / 60, int(capacity) % 60]


func _on_Pitch_value_changed(value):
	$VBox/HB1/VB3/HB3/PV.text = "%0.2f mm" % value
	pitch = value
	update_utilizations()


func update_utilizations():
	update_utilization(SIDE_A)
	update_utilization(SIDE_B)


func _on_Stop_pressed():
	set_play_state(false)
