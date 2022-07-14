class_name Audio

var player: AudioStreamPlayer
var info

func _init(audio_player_instance):
	player = audio_player_instance


func load_data(path: String):
	var file = File.new()
	var err = file.open(path, File.READ)
	if err == OK:
		var data = file.get_buffer(file.get_len())
		file.close()
		var stream
		match path.get_extension():
			"mp3":
				parse_mp3(data)
				stream = AudioStreamMP3.new()
			"ogg":
				parse_ogg(data)
				stream = AudioStreamOGGVorbis.new()
		stream.data = data
		player.stream = stream


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


func parse_ogg(data: PoolByteArray):
	info = { error = null }
	# Locate the comments header, it is where the second "vorbis" octet stream occurs
	var hex = data.subarray(0, 0x100).hex_encode()
	var idx = hex.find("766f72626973")
	if idx > 0:
		idx = hex.find("766f72626973", idx + 6) / 2 + 6
		# Let's just use the 1st byte of the 32-bit length values for the length
		# Skip over vendor_string
		idx += data[idx] + 4
		var num_comments = data[idx]
		idx += 4
		for n in num_comments:
			var comment_length = data[idx]
			idx += 4
			var comment = data.subarray(idx, idx + comment_length - 1).get_string_from_utf8()
			var tag_val = comment.split("=")
			if tag_val.size() == 2:
				var tag = tag_val[0].to_lower()
				match tag:
					"artist":
						info["band"] = tag_val[1]
					_:
						info[tag] = tag_val[1]
			idx += comment_length 


func parse_mp3(data: PoolByteArray):
	info = { error = null }
	if data.size() < 10:
		info.error = "NOT ID3"
		return
	# Detect ID3v2 tag
	var header = data.subarray(0, 9)
	var id = header.subarray(0, 2).get_string_from_ascii()
	if id != "ID3":
		info.error = "NOT ID3"
		return
	info["version"] = "ID3v2.%d.%d" % [header[3], header[4]]
	var flags = header[5]
	var _unsync = flags & 0x80 > 0
	var extended = flags & 0x40 > 0
	var _experimental = flags & 0x20 > 0
	var _has_footer = flags & 0x10 > 0
	var idx = 10
	var end = idx + bytes_to_int(header.subarray(6, 9))
	if extended:
		idx += bytes_to_int(data.subarray(idx, idx + 3))
	# Now idx points to the start of the first frame
	while idx < end:
		var frame_id = data.subarray(idx, idx + 3).get_string_from_ascii()
		var size = bytes_to_int(data.subarray(idx + 4, idx + 7), frame_id != "APIC")
		idx += 10
		match frame_id:
			"TIT2":
				info["title"] = get_string_from_data(data, idx, size)
			"TALB":
				info["album"] = get_string_from_data(data, idx, size)
			"COMM":
				info["comments"] = get_string_from_data(data, idx, size)
			"TYER":
				info["year"] = get_string_from_data(data, idx, size)
			"TPE1", "TPE2", "TPE3", "TPE4":
				info["band"] = get_string_from_data(data, idx, size)
			"APIC":
				# size of APIC does not use syncsafe number
				# Ignore the encoding byte
				# The image is always jpeg I think, but the mime-type text varies
				# Could just detect the byte signature for verification ffd8 ... ffd9
				var pic_frame = data.subarray(idx + 1, idx + size - 1)
				var zero1 = pic_frame.find(0)
				if zero1 > 0:
					info["mime_type"] = pic_frame.subarray(0, zero1 - 1).get_string_from_ascii()
					zero1 += 1 # Picture type
					if zero1 < pic_frame.size():
						zero1 += 1
						if zero1 < pic_frame.size():
							var zero2 = pic_frame.find(0, zero1)
							info["description"] = get_string_from_ucs2(pic_frame.subarray(zero1, zero2 - 1))
							info["image"] = pic_frame.subarray(zero2 + 1, -1)
							"""
							var img = Image.new()
							match info["mime_type"]:
								"image/jpg", "image/jpeg", "image/JPG":
									var e = img.load_jpg_from_buffer(info["image"])
									if e == OK:
										img.save_png("res://temp.png")
							"""
		idx += size


func get_string_from_data(data, idx, size):
	if size > 3 and Array(data.subarray(idx, idx + 2)).hash() == [1, 0xff, 0xfe].hash():
		# Null-terminated string of ucs2 chars
		return get_string_from_ucs2(data.subarray(idx + 3, idx + size - 1))
	if data[idx] == 0:
		# Simple utf8 string
		return data.subarray(idx + 1, idx + size - 1).get_string_from_utf8()


# Syncsafe uses 0x80 multiplier otherwise use 0x100 multiplier
func bytes_to_int(bytes: Array, is_syncsafe = true):
	var mult = 0x80 if is_syncsafe else 0x100
	var n = 0
	for byte in bytes:
		n *= mult
		n += byte
	return n


func get_string_from_ucs2(bytes: Array):
	var s = ""
	var idx = 0
	while idx < (bytes.size() - 1):
		s += char(bytes[idx] + 256 * bytes[idx + 1])
		idx += 2
	return s
