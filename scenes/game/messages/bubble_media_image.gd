extends TextureRect

func _on_gui_input(event):
	if Input.is_action_just_pressed("click"):
		var overlay := preload("res://scenes/game/overlay.tscn").instantiate() as Overlay
		overlay.profile_tex = texture
		MessageView.current.add_child(overlay)
		overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
