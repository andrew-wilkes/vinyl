extends PanelContainer

signal album_selected(album_id)


func open():
	$VB/Albums.clear()
	for album_id in g.settings.albums:
		var title = g.settings.albums[album_id].title
		if title != "":
			$VB/Albums.add_item(title)
			$VB/Albums.set_item_metadata($VB/Albums.get_item_count() - 1, album_id)
	if $VB/Albums.get_item_count() > 0:
		rect_position = (get_viewport().get_visible_rect().size - rect_size) / 2.0
		show()


func _on_Albums_item_selected(index):
	emit_signal("album_selected", $VB/Albums.get_item_metadata(index))
	hide()
