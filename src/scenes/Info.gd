extends AcceptDialog

func open(tab_idx = 0):
	$TabContainer.set_current_tab(tab_idx)
	popup_centered()
