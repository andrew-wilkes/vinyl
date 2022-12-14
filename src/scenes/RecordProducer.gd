extends Control

enum { SIDE_A, SIDE_B }

const X_PITCH = 25.4 / 16 * 0.1 # >= 16 grooves per inch
const LAST_MUSIC_GROOVE = [120.6, 108.0, 120.6]
const FIRST_MUSIC_GROOVE = [292.1, 168.3, 241.3]
const GAP_TIME = 5
const VU_COUNT = 8
const FREQ_MAX = 11050.0

onready var tracks = [$VBox/HB2/VB1/ATracks, $VBox/HB2/VB2/BTracks]
onready var bars = [$VBox/HB1/VB3/HB/UA, $VBox/HB1/VB3/HB2/UB]
onready var times = [$VBox/HB1/VB3/HB/TimeA, $VBox/HB1/VB3/HB2/TimeB]
onready var audio_bar = find_node("AudioBar")
onready var audio_progress = find_node("AudioProgress")

var audio
var spectrum
var current_track
var pitch
var size_group
var speed_group
var image_idx = 0

export(Color) var gap_color
export(Color) var ok_color
export(Color) var warn_color
export(Color) var spare_color
export var FFSTEP = 10.0

func load_album(id):
	g.current_album_id = id
	var album = g.settings.albums[id]
	$VBox/HB/VB1/VB1/Title.text = album.title
	$VBox/HB/VB1/VB2/Band.text = album.band
	for button in size_group.get_buttons():
		if button.name == album.size: button.pressed = true
	for button in speed_group.get_buttons():
		if button.name == album.rpm: button.pressed = true
	for idx in 4:
		var text = { resized = g.default_art[idx] }
		if album.images[idx]:
			text = g.get_resized_texture(album.images[idx], 64)
		set_art_image(text.resized, idx)
	set_pitch(album.pitch)
	tracks[SIDE_A].clear()
	tracks[SIDE_B].clear()
	add_tracks(album.a_side, SIDE_A, false)
	add_tracks(album.b_side, SIDE_B, false)
	update_utilizations()


func set_art_image(text, idx):
	get_node("%ArtButtons").get_child(idx).material.set_shader_param("image", text)


func new_album():
	g.new_album()
	clear_record()


func clear_record():
	tracks[SIDE_A].clear()
	tracks[SIDE_B].clear()
	$VBox/HB/VB1/VB1/Title.text = ""
	$VBox/HB/VB1/VB2/Band.text = ""
	for idx in 4:
		get_node("%ArtButtons").get_child(idx).texture_normal = g.default_art[idx]
	size_group.get_buttons()[0].pressed = true
	speed_group.get_buttons()[0].pressed = true
	set_pitch(2.3)
	update_utilizations()


func delete_album():
	g.delete_album()
	new_album()


func _ready():
	var id = 0
	for button in get_node("%ArtButtons").get_children():
		button.hint_tooltip = "Select image or RMB to delete the image"
		var _e = button.connect("gui_input", self, "art_button_clicked", [button, id])
		id += 1
	var _e = $c/TrackSelector.connect("add_tracks", self, "add_tracks")
	_e = $c/EditPanel.connect("text_updated", self, "update_track_title")
	audio = Audio.new($AudioStreamPlayer)
	size_group = $VBox/HB1/VB1/size10.group
	speed_group = $VBox/HB1/VB2/speed33.group
	if g.current_album_id:
		load_album(g.current_album_id)
	else:
		new_album()
	$VBox/HB/VB1/VB1/Title.grab_focus()
	set_pitch(0.23)
	$VBox/HB1/VB3/HB3/VB/Pitch.value = pitch
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
	$VBox/HB1/VB/Volume.value = g.settings.volume
	g.set_panel_color(theme)
	for node in $c.get_children():
		node.theme = theme


func _process(_delta):
	if audio.player.playing:
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
		audio_progress.material.set_shader_param("value", audio.player.get_playback_position() / current_track.length)


func get_rpm():
	var rpm = speed_group.get_pressed_button().name
	g.set_album_property("rpm", rpm)
	return g.RPMS[rpm]


func get_size():
	var size = size_group.get_pressed_button().name
	g.set_album_property("size", size)
	return g.SIZES.find(size)


func _on_AddToA_pressed():
	$c/TrackSelector.open(SIDE_A)


func _on_AddToB_pressed():
	$c/TrackSelector.open(SIDE_B)


func add_tracks(items, side, new_tracks = true):
	# Add track to list and get meta data from audio file
	# There are 2 columns of cells in ItemList so divide index by 2
	for item in items:
		var track = item if item is Track else g.settings.tracks[item / 2].duplicate()
		audio.load_data(track.path)
		track.title = audio.info.get("title", "")
		track.band = audio.info.get("band", "")
		if $VBox/HB/VB1/VB2/Band.text.empty():
			$VBox/HB/VB1/VB2/Band.text = track.band
			g.set_album_property("band", track.band)
		track.album = audio.info.get("album", "")
		if $VBox/HB/VB1/VB1/Title.text.empty():
			$VBox/HB/VB1/VB1/Title.text = track.album
			g.set_album_property("title", track.album)
		track.year = audio.info.get("year", "")
		track.length = audio.player.stream.get_length()
		tracks[side].add_item(track.title)
		tracks[side].set_item_metadata(tracks[side].get_item_count() - 1, track)
		if new_tracks:
			g.add_track(side, track)
		current_track = track
	if items.size() > 0:
		tracks[side].select(tracks[side].get_item_count() - 1)
	update_utilization(side)


func _on_DeleteA_pressed():
	remove_tracks(SIDE_A)
	update_utilization(SIDE_A)


func remove_tracks(side):
	var list_offset = 0
	for idx in tracks[side].get_selected_items():
		var track = tracks[side].get_item_metadata(idx - list_offset)
		g.remove_track(side, track)
		tracks[side].remove_item(idx - list_offset)
		list_offset += 1


func _on_EditA_pressed():
	edit_track_title(SIDE_A)


func _on_InfoA_pressed():
	load_track(SIDE_A)
	if current_track:
		$c/TrackInfo.open(current_track)


func _on_PlayA_pressed():
	if load_track(SIDE_A) and current_track:
		set_play_state(true)


func set_play_state(play):
	if play:
		audio.player.play()
		audio_controls_visibility(1)
		$VBox/HB2/VB1/HB/PlayA.hide()
		$VBox/HB2/VB2/HB/PlayB.hide()
		$VBox/HB2/VB1/HB/StopA.show()
		$VBox/HB2/VB2/HB/StopB.show()
	else:
		audio.player.stop()
		audio_controls_visibility(0)
		$VBox/HB2/VB1/HB/PlayA.show()
		$VBox/HB2/VB2/HB/PlayB.show()
		$VBox/HB2/VB1/HB/StopA.hide()
		$VBox/HB2/VB2/HB/StopB.hide()


func audio_controls_visibility(alpha_value):
	for node in get_tree().get_nodes_in_group("audio"):
		node.modulate.a = alpha_value


func _on_DeleteB_pressed():
	remove_tracks(SIDE_B)
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
	if load_track(SIDE_B) and current_track:
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
	var ok = true
	var items = tracks[side].get_selected_items()
	if items.size() > 0:
		var track = tracks[side].get_item_metadata(items[0])
		if current_track != track:
			var file = File.new()
			if file.file_exists(track.path):
				audio.load_data(track.path) # Set the stream
				current_track = track
			else:
				ok = false
				alert("Unable to load the audio file from " + track.path)
	return ok


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
	times[side].text = g.format_time(time)
	if overflow:
		times[side].modulate = Color.red
	else:
		times[side].modulate = Color.white
	$VBox/HB1/VB3/HB4/Capacity.text = g.format_time(capacity)


func _on_Pitch_value_changed(value):
	set_pitch(value)


func set_pitch(value):
	$VBox/HB1/VB3/HB3/PV.text = "%0.2f mm" % value
	pitch = value
	update_utilizations()
	g.set_album_property("pitch", value)


func update_utilizations():
	update_utilization(SIDE_A)
	update_utilization(SIDE_B)


func _on_Stop_pressed():
	set_play_state(false)


func _on_New_pressed():
	new_album()


func _on_Load_pressed():
	$c/AlbumSelector.open()


func _on_Delete_pressed():
	$c/ConfirmDelete.popup_centered()


func _on_ConfirmDelete_confirmed():
	delete_album()


func _on_Title_text_changed(new_text):
	g.set_album_property("title", new_text)


func _on_Band_text_changed(new_text):
	g.set_album_property("band", new_text)


func _on_AlbumSelector_album_selected(album_id):
	load_album(album_id)


func _on_FastForward_pressed():
	audio.player.seek(audio.player.get_playback_position() + FFSTEP)


func _on_Volume_value_changed(value):
	g.settings.volume = value
	var db = -pow(8.0 - value, 1.8)
	AudioServer.set_bus_volume_db(0, db)
	$VBox/HB1/VB/Volume.hint_tooltip = "%d db" % db


func _on_ImageSelector_file_selected(path):
	g.settings.last_image_dir = path.get_base_dir()
	g.get_album_property("images")[image_idx] = path
	var text = g.get_resized_texture(path, 64)
	if text.resized == null:
		text.resized = g.default_art[image_idx]
		alert("Unable to load image from: " + path)
	set_art_image(text.resized, image_idx)


func art_button_clicked(event, button, idx):
	if event is InputEventMouseButton:
		if event.button_index == 1:
			open_image_selector(idx)
		else:
			button.texture_normal = g.default_art[idx]
			g.get_album_property("images")[image_idx] = null


func open_image_selector(idx):
	image_idx = idx
	var path = g.get_album_property("images")[idx]
	if path == null:
		$c/ImageSelector.current_dir = g.settings.last_image_dir
		$c/ImageSelector.current_file = ""
	else:
		$c/ImageSelector.current_dir = path.get_base_dir()
		$c/ImageSelector.current_path = path
	$c/ImageSelector.popup_centered()


func alert(msg):
	$c/Alert.dialog_text = msg
	$c/Alert.popup_centered()


func _on_Info_pressed():
	$c/Info.open(1)
