class_name Audio

var player: AudioStreamPlayer

func _init(audio_stream_instance):
	player = audio_stream_instance


func load_data(path):
	var file = File.new()
	var err = file.open(path, File.READ)
	if err == OK:
		var stream = AudioStreamMP3.new()
		stream.data = file.get_buffer(file.get_len())
		file.close()
		player.stream = stream
	pass


func pause(pause = true):
	player.stream_paused = pause


func stop():
	player.stop()


func seek(time):
	player.seek(time)


func set_volume(percent):
	player.volume_db = clamp(percent - 1.0, 0, 1) * 30


func set_speed(target, actual): # e.g. 45, 33 RPM
	player.pitch_scale = actual / target
