extends Node2D

@export var sprite : Sprite2D

var current_suitors : Array[String] = []

func _process(delta):
	tray_cooldown -= delta

func drop(body : Node2D):
	var align := body.create_tween()
	align.tween_property(body, "global_position", global_position, 0.3).set_trans(Tween.TRANS_BOUNCE)
	align.parallel().tween_property(body, "global_rotation", global_rotation, 0.2)
	if body is RigidBody2D:
		body.freeze = true
		var old_mode = body.freeze_mode
		body.freeze_mode = body.FREEZE_MODE_KINEMATIC
		await align.finished
		body.freeze = false
		body.freeze_mode = old_mode
	var squeeze := create_tween()
	squeeze.tween_property(self, "scale", Vector2(1.2, 0.8), 0.05).set_ease(Tween.EASE_IN)
	squeeze.tween_property(self, "scale", Vector2.ONE, 0.05).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	if body is SuitorProfile:
		var suitor_id = body.name.to_lower()
		if !current_suitors.has(suitor_id):
			current_suitors.append(suitor_id)
	body.queue_free()

func _on_area_2d_body_entered(body : Node2D):
	if body is SuitorProfile:
		if body.stamped and body.dragging:
			body.drop_zone = self

func _on_area_2d_body_exited(body):
	if body is SuitorProfile:
		if body.drop_zone == self:
			body.drop_zone = null
	
func _on_area_2d_mouse_entered():
	var hover := sprite.create_tween()
	hover.tween_property(sprite, "modulate:v", 1.2, 0.05)

func _on_area_2d_mouse_exited():
	var unhover := sprite.create_tween()
	unhover.tween_property(sprite, "modulate:v", 1.0, 0.05)

static var tray_cooldown := 0.0
func _on_area_2d_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("click"):
		if tray_cooldown > 0:
			return
		tray_cooldown += 1.0
		# This condition is only usable if the only valid multiple ending
		# is one where *all* suitors are chosen. aka this game.
		if ClientProfile.current != null:
			var recipe := try_recipe()
			if !recipe.is_empty():
				DataManager.game_data.dates_left.append(MessageParser.DATES_PATH + recipe)
				if MessageEvent.is_done():
					App.call_deferred("stage", load("res://scenes/stages/workday.tscn"))
		else:
			if MessageEvent.is_done():
					App.call_deferred("stage", load("res://scenes/stages/workday.tscn"))

func try_recipe() -> String:
	if current_suitors.size() == 0:
		return ""
	if current_suitors.size() > 1 and ClientProfile.current.recipes.has("true"):
		return ClientProfile.current.recipes["true"]
	elif current_suitors.size() == 1:
		if ClientProfile.current.recipes.has(current_suitors[0]):
			return ClientProfile.current.recipes[current_suitors[0]]
	return ""
