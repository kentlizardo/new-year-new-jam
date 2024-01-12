extends Area2D

func _input_event(viewport, event, shape_idx):
	if !MessageView.current.visible:
		if Input.is_action_just_released("click"):
			MessageView.current.reveal()
			get_viewport().set_input_as_handled()
