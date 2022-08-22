extends Control

enum { SIDE_A, SIDE_B }

onready var tracks = [$VBox/HB2/VB1/ATracks, $VBox/HB2/VB2/BTracks]

func _ready():
	var _e = $c/TrackSelector.connect("add_tracks", self, "add_tracks")
	_e = $c/EditPanel.connect("text_updated", self, "update_track_title")


func _on_AddToA_pressed():
	$c/TrackSelector.open(SIDE_A)


func _on_AddToB_pressed():
	$c/TrackSelector.open(SIDE_B)


func add_tracks(items, side):
	for idx in items:
		tracks[side].add_item(g.settings.tracks[idx].title)
		tracks[side].set_item_metadata(tracks[side].get_item_count() - 1, idx)


func _on_DeleteA_pressed():
	remove_tracks(tracks[SIDE_A])


func remove_tracks(list):
	var list_offset = 0
	for idx in list.get_selected_items():
		list.remove_item(idx - list_offset)
		list_offset += 1


func _on_EditA_pressed():
	edit_track_title(SIDE_A)


func _on_InfoA_pressed():
	pass # Replace with function body.


func _on_PlayA_pressed():
	pass # Replace with function body.


func _on_DeleteB_pressed():
	remove_tracks(tracks[SIDE_B])


func _on_EditB_pressed():
	edit_track_title(SIDE_B)


func edit_track_title(side):
	var items = tracks[side].get_selected_items()
	if items.size() > 0:
		$c/EditPanel.open(side, items[0], tracks[side].get_item_text(items[0]))


func _on_InfoB_pressed():
	pass # Replace with function body.


func _on_PlayB_pressed():
	pass # Replace with function body.


func update_track_title(side, idx, txt):
	tracks[side].set_item_text(idx, txt)
