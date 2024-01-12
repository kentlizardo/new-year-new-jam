extends TextureRect

signal clicked

func _gui_input(event):
	if Input.is_action_just_released("click"):
		clicked.emit()
		accept_event()
