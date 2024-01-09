extends Node2D

func drop(body : Node2D):
	var align := body.create_tween()
	align.tween_property(body, "global_position", global_position, 0.3)
	align.parallel().tween_property(body, "global_rotation", global_rotation, 0.2)
	if body is RigidBody2D:
		body.freeze = true
		var old_mode = body.freeze_mode
		body.freeze_mode = body.FREEZE_MODE_KINEMATIC
		await align.finished
		body.freeze = false
		body.freeze_mode = old_mode

func _on_area_2d_body_entered(body : Node2D):
	if body is Profile:
		if body.stamped and body.dragging:
			body.drop_zone = self

func _on_area_2d_body_exited(body):
	if body is Profile:
		if body.drop_zone == self:
			body.drop_zone = null
