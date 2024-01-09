class_name Profile extends RigidBody2D

var stamped := false
var dragging := false

var drag_body : StaticBody2D

func _init():
	add_to_group("profiles")

func _physics_process(delta):
	if dragging:
		if is_instance_valid(drag_body):
			drag_body.global_position = get_global_mouse_position()

func _on_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("click"):
		dragging = true
		if !is_instance_valid(drag_body):
			drag_body = StaticBody2D.new()
			var sprite = Sprite2D.new()
			sprite.texture = preload("res://assets/icon.svg")
			drag_body.add_child(sprite)
			drag_body.add_child(CollisionShape2D.new())
			var joint = PinJoint2D.new()
			drag_body.add_child(joint)
			get_parent().add_child(drag_body)
			drag_body.global_position = get_global_mouse_position()
			joint.node_a = get_path()
			joint.node_b = drag_body.get_path()

func _input(event):
	if dragging:
		if Input.is_action_just_released("click"):
			dragging = false
			#apply_central_impulse(Input.get_last_mouse_velocity())
			if is_instance_valid(drag_body):
				drag_body.queue_free()
			
