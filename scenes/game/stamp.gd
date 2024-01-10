extends Draggable

@export var stamp_top : Draggable
@export var spring : DampedSpringJoint2D
@export var stamp_threshold : Area2D
@export var stamping_area : Area2D

func _ready():
	super()
	stamp_top.drag_started.connect(start_stamp)
	stamp_top.drag_ended.connect(end_stamp)
	stamp_threshold.body_entered.connect(threshold_body_entered)
	stamp_threshold.body_exited.connect(threshold_body_exited)
	stamping_area.body_entered.connect(stamping_body_entered)
	stamping_area.body_exited.connect(stamping_body_exited)

func threshold_body_entered(body : Node2D):
	if body == stamp_top:
		for i in stamping:
			if i is Profile:
				i.stamped = true
				var stamp_sprite := Sprite2D.new()
				stamp_sprite.scale = Vector2.ONE * 0.25
				stamp_sprite.texture = preload("res://assets/textures/stamp.png")
				i.sprite.add_child(stamp_sprite)
				stamp_sprite.global_position = stamping_area.global_position
				
				var tw := stamp_sprite.create_tween()
				tw.tween_property(stamp_sprite, "modulate:a", 1.0 * randf_range(0.4, 1.0), 0.05).from(0.0)

func threshold_body_exited(body : Node2D):
	pass

var stamping : Array[Node2D] = []

func stamping_body_entered(body : Node2D):
	if body is Profile:
		stamping.append(body)

func stamping_body_exited(body : Node2D):
	if body is Profile:
		var i := stamping.find(body)
		if i != -1:
			stamping.remove_at(i)

func start_stamp():
	linear_damp = 500
	spring.stiffness = 1

func end_stamp():
	linear_damp = 5
	spring.stiffness = 40
