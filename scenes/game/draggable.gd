class_name Draggable extends RigidBody2D

@export var sprite : Sprite2D

var dragging := false
var hovering := false
var drop_zone = null
var drag_body : StaticBody2D
var drag_distance := Vector2.ZERO

func start_drag():
	if !dragging:
		dragging = true
		drag_distance = Vector2.ZERO
		if !is_instance_valid(drag_body):
			drag_body = StaticBody2D.new()
			drag_body.add_child(CollisionShape2D.new())
			var joint = PinJoint2D.new()
			drag_body.add_child(joint)
			get_parent().add_child(drag_body)
			drag_body.global_position = get_global_mouse_position()
			joint.node_a = get_path()
			joint.node_b = drag_body.get_path()

func end_drag():
	if dragging:
		dragging = false
		apply_central_impulse(Input.get_last_mouse_velocity())
		if is_instance_valid(drag_body):
			drag_body.queue_free()
		if is_instance_valid(drop_zone):
			drop_zone.drop(self)

func _physics_process(delta):
	if dragging:
		if is_instance_valid(drag_body):
			drag_body.global_position = get_global_mouse_position()

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseMotion:
		drag_distance += event.relative
	if Input.is_action_just_pressed("click"):
		start_drag()
		if event is InputEventMouseButton:
			if event.double_click:
				print("doubled")

func _input(event):
	if dragging:
		if Input.is_action_just_released("click"):
			end_drag()

func _on_mouse_entered():
	var hover := sprite.create_tween()
	hover.tween_property(sprite, "modulate:v", 1.2, 0.1)

func _on_mouse_exited():
	var unhover := sprite.create_tween()
	unhover.tween_property(sprite, "modulate:v", 1.0, 0.1)
