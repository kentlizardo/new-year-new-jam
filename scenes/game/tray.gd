extends Node2D

const OPEN_SPRITE = preload("res://assets/textures/desk/tray_open.png")
const CLOSED_SPRITE = preload("res://assets/textures/desk/tray_close.png")
const SUITOR_TEMPLATE = preload("res://scenes/game/suitor_profile.tscn")

@export var tray_body : Draggable
@export var sprite : Sprite2D
@export var sprite_root : Node2D

var current_suitors : Array[String] = [] # suitor_ids

func _ready():
	tray_body.double_clicked.connect(drop_papers)

func _process(delta):
	tray_cooldown -= delta

func drop(body : Node2D):
	if body is SuitorProfile:
		if current_suitors.has(body.name.to_lower()):
			return
		var align := body.create_tween()
		align.tween_property(body, "global_position", tray_body.global_position, 0.3).set_trans(Tween.TRANS_BOUNCE)
		align.parallel().tween_property(body, "global_rotation", tray_body.global_rotation, 0.2)
		if body is RigidBody2D:
			body.freeze = true
			var old_mode = body.freeze_mode
			body.freeze_mode = body.FREEZE_MODE_KINEMATIC
			await align.finished
			body.freeze = false
			body.freeze_mode = old_mode
		var squeeze := create_tween()
		squeeze.tween_property(sprite_root, "scale", Vector2(1.2, 0.8), 0.05).set_ease(Tween.EASE_IN)
		squeeze.tween_property(sprite_root, "scale", Vector2.ONE, 0.05).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		current_suitors.append(body.name.to_lower())
		body.queue_free()
		sprite.texture = CLOSED_SPRITE

func _on_area_2d_body_entered(body : Node2D):
	if body is Profile:
		if body.stamped and body.dragging:
			body.drop_zone = self

func _on_area_2d_body_exited(body):
	if body is Profile:
		if body.drop_zone == self:
			body.drop_zone = null
	
func _on_area_2d_mouse_entered():
	var hover := sprite.create_tween()
	hover.tween_property(sprite, "modulate:v", 1.2, 0.05)

func _on_area_2d_mouse_exited():
	var unhover := sprite.create_tween()
	unhover.tween_property(sprite, "modulate:v", 1.0, 0.05)

static var tray_cooldown := 0.0
func drop_papers():
	for i in current_suitors.duplicate():
		var profile := SUITOR_TEMPLATE.instantiate()
		profile.name = i.capitalize()
		get_parent().add_child(profile)
		profile.global_position = tray_body.global_position
		profile.global_rotation = tray_body.global_rotation
		current_suitors.remove_at(current_suitors.find(i))
	sprite.texture = CLOSED_SPRITE

func submit():
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
	var suitor_ids := current_suitors
	if suitor_ids.size() == 0:
		return ""
	if suitor_ids.size() > 1 and ClientProfile.current.recipes.has("true"):
		return ClientProfile.current.recipes["true"]
	elif suitor_ids.size() == 1:
		if ClientProfile.current.recipes.has(suitor_ids[0]):
			return ClientProfile.current.recipes[suitor_ids[0]]
	return ""
