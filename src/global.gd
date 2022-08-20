extends Node

var settings

func _init():
	settings = Settings.new()
	settings = settings.load_data()
