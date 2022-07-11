extends Spatial

func _ready():
	var audio = Audio.new($AudioStreamPlayer)
	var path = "../data/Sia.mp3"
	audio.load_data(path)
	audio.player.play()
