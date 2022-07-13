extends Control

var audio

func _ready():
	audio = Audio.new($AudioStreamPlayer)


func _on_FileDialog_file_selected(path):
	audio.load_data(path)
	$VBox/Version.text = audio.info.get("version", "")
	$VBox/Title.text = audio.info.get("title", "")
	$VBox/Album.text = audio.info.get("album", "")
	$VBox/Band.text = audio.info.get("band", "")
	$VBox/Comments.text = str(audio.info.get("comments", ""))
	$VBox/Year.text = audio.info.get("year", "")
	if audio.info.error:
		$VBox/Error.text = str(audio.info.error)
	else:
		$VBox/Error.text = ""
	var img = audio.info.get("image")
	if img:
		$VBox/MimeType.text = audio.info.mime_type
		$VBox/Description.text = audio.info.description
		var image = Image.new()
		image.load_jpg_from_buffer(img)
		var texture = ImageTexture.new()
		texture.create_from_image(image)
		$VBox/TextureRect.texture = texture
	else:
		$VBox/TextureRect.texture = null
	audio.player.play()


func _on_File_pressed():
	$FileDialog.popup_centered()
