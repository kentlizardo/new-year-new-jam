extends Node2D



func _on_area_2d_body_entered(body : Node2D):
	if body is Profile:
		if body.stamped:
			var align := body.create_tween()
			align.tween_property(body, "global_position", global_position, 0.3)
