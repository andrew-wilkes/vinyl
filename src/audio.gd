class_name Audio

var player: AudioStreamPlayer

func _init(audio_player_instance):
	var p = PoolByteArray([1,2,3])
	player = audio_player_instance


func load_data(path):
	var file = File.new()
	var err = file.open(path, File.READ)
	if err == OK:
		var stream = AudioStreamMP3.new()
		stream.data = file.get_buffer(file.get_len())
		file.close()
		player.stream = stream
		parse_data(stream.data)
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

enum { NONE, NOT_ID3 }
func parse_data(data: PoolByteArray):
	var info = {}
	var error = NONE
	if data.size() < 10:
		error = NOT_ID3
		return error
	# Detect ID3v2 tag
	var header = data.subarray(0, 9)
	var id = header.subarray(0, 2).get_string_from_ascii()
	if id != "ID3":
		error = NOT_ID3
		return error
	info["version"] = "ID3v2.%d.%d" % [header[3], header[4]]
	var flags = header[5]
	var unsync = flags & 0x80 > 0
	var extended = flags & 0x40 > 0
	var _experimental = flags & 0x20 > 0
	var has_footer = flags & 0x10 > 0
	var idx = 10
	var end = idx + bytes_to_int(header.subarray(6, 9))
	if extended:
		idx += bytes_to_int(data.subarray(idx, idx + 3))
	# Now idx points to the start of the first frame
	while idx < end:
		var frame_id = data.subarray(idx, idx + 3).get_string_from_ascii()
		print(frame_id)
		var size = bytes_to_int(data.subarray(idx + 4, idx + 7))
		match frame_id:
			"TIT2":
				info["title"] = get_string_from_data(data, idx, size)
			"TALB":
				info["album"] = get_string_from_data(data, idx, size)
			"COMM":
				info["comments"] = get_string_from_data(data, idx + 17, size)
			"TYER":
				info["year"] = get_string_from_data(data, idx, size)
			"TPE1", "TPE2", "TPE3", "TPE4":
				info["band"] = get_string_from_data(data, idx, size)
			"APIC":
				# Ignore the encoding byte
				var pic_frame = data.subarray(idx + 11, idx + 9 + size)
				#prints(idx + 9 + size, 0x1614a)
				var zero1 = pic_frame.find(0)
				if zero1 > 0:
					info["mime_type"] = pic_frame.subarray(0, zero1 - 1).get_string_from_ascii()
					zero1 += 1
					if zero1 < pic_frame.size():
						var pic_type = pic_frame[zero1 + 1]
						zero1 += 1
						if zero1 < pic_frame.size():
							var zero2 = pic_frame.find(0, zero1)
							info["description"] = get_string_from_ucs2(pic_frame.subarray(zero1, zero2 - 1))
							info["image"] = pic_frame.subarray(zero2 + 1, -1)
							var i = idx + 11
							while i < data.size():
								if data[i] == 0xd9 and data[i - 1] == 0xff:
									print(i)
								i += 1
							var file = File.new()
							file.open("res://temp.jpg", File.WRITE)
							file.store_buffer(info["image"])
							file.close()
							var img = Image.new()
							match info["mime_type"]:
								"image/jpeg":
									if img.load_jpg_from_buffer(info["image"]):
										img.save_png("res://temp.png")
		idx += size + 10


func get_string_from_data(data, idx, size):
	return get_string_from_ucs2(data.subarray(idx + 13, idx + 9 + size))


# Syncsafe uses 0x80 multiplier otherwise use 0x100 multiplier
func bytes_to_int(bytes: Array, MULT = 0x80):
	var n = 0
	for byte in bytes:
		n *= MULT
		n += byte
	return n


func get_string_from_ucs2(bytes: Array):
	var s = ""
	var idx = 0
	while idx < (bytes.size() - 1):
		s += char(bytes[idx] + 256 * bytes[idx + 1])
		idx += 2
	return s
