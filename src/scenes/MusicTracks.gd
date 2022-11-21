extends Control

onready var items: ItemList = find_node("TrackList")
onready var headings = find_node("Headings")

func _ready():
	for track in g.settings.tracks:
		add_item(track)
	g.set_panel_color(theme)
	$c.get_child(0).theme = theme


func _on_Button_pressed():
	$c/FileDialog.current_dir = g.settings.last_dir
	$c/FileDialog.popup_centered()


func _on_FileDialog_files_selected(paths):
	# Set dir to parent directory of this path's dir
	g.settings.last_dir = $c/FileDialog.current_path.get_base_dir().rsplit("/", true, 1)[0]
	for path in paths:
		var new = true
		for track in g.settings.tracks:
			if path == track.path:
				new = false
				continue
		if new:
			var track = Track.new()
			track.path = path
			track.title = path.get_file()
			g.settings.tracks.append(track)
			add_item(track)


func _on_Remove_pressed():
	var list_offset = 0
	var array_offset = 0
	for idx in items.get_selected_items():
		g.settings.tracks.remove(idx - array_offset)
		array_offset += 1
		items.remove_item(idx - list_offset)
		list_offset += 1
		items.remove_item(idx - list_offset)
		list_offset += 1


func add_item(track):
	items.add_item(track.title)
	items.add_item("     " + track.path.get_base_dir(), null, false)
