extends Control

onready var items: ItemList = find_node("ItemList")
onready var headings = find_node("Headings")

func _ready():
	for track in g.settings.tracks:
		add_item(track)


func _on_Button_pressed():
	$FileDialog.popup_centered()


func _on_FileDialog_files_selected(paths):
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
	print(g.settings.tracks)
	var list_offset = 0
	var array_offset = 0
	for idx in items.get_selected_items():
		g.settings.tracks.remove(idx / 3 - array_offset)
		array_offset += 1
		for n in 3:
			items.remove_item(idx + n - list_offset)
			list_offset += 1
	print(g.settings.tracks)


func add_item(track):
	items.add_item(track.title)
	items.add_item(track.path.get_base_dir().split("/")[-1], null, false)
	items.add_item(track.path.get_base_dir(), null, false)


func _on_SC_sort_children():
	var max_chars = 0
	for idx in items.get_item_count():
		var n = items.get_item_text(idx).length()
		if n > max_chars: max_chars = n
	if max_chars > 0:
		for node in headings.get_children():
			node.rect_min_size.x = max_chars * 7.3

