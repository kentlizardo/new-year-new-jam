extends Area2D

func _enter_tree():
	App.message_events_added.connect(show_notifs)
	App.message_events_done.connect(hide_notifs)
func _exit_tree():
	App.message_events_added.disconnect(show_notifs)
	App.message_events_done.disconnect(hide_notifs)

func show_notifs():
	pass
func hide_notifs():
	pass

func _input_event(viewport, event, shape_idx):
	if !MessageView.current.visible:
		if Input.is_action_just_released("click"):
			MessageView.current.reveal()
			get_viewport().set_input_as_handled()
