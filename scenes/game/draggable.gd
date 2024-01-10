class_name Draggable extends RigidBody2D

signal drag_started
signal drag_ended

@export var sprite : Sprite2D

var dragging := false
var hovering := false
var drop_zone = null
var drag_body : StaticBody2D
var drag_distance := Vector2.ZERO

func _ready():
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

static var current : Draggable:
	set(x):
		if is_instance_valid(current):
			current.end_drag()
		current = x
		if is_instance_valid(current):
			current.start_drag()

static func set_dragged_item(drag : Draggable):
	current = drag

func is_on_top() -> bool:
	for node in get_tree().get_nodes_in_group("hovered"):
		var a_search : Node = get_parent()
		var a : Node = self
		var b_search : Node = node.get_parent()
		var b : Node = node
		while a_search != b_search:	
			if a_search.is_ancestor_of(b):
				b = b_search
				b_search = b_search.get_parent()
			elif b_search.is_ancestor_of(a):
				a = a_search
				a_search = a_search.get_parent()
			else:
				a = a_search
				b = b_search
				a_search = a_search.get_parent()
				b_search = b_search.get_parent()
		var is_hiding_this := b.get_index() > a.get_index()
		if is_hiding_this:
			return false
	return true

func start_drag():
	if !dragging:
		dragging = true
		drag_started.emit()
		drag_distance = Vector2.ZERO
		print("dragging " + name)
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
		drag_ended.emit()
		#apply_central_impulse(Input.get_last_mouse_velocity())
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
		#start_drag()
		get_parent().move_child(self, get_parent().get_children().size())
		if is_on_top():
			set_dragged_item(self)
		if event is InputEventMouseButton:
			if event.double_click:
				print("doubled")

func _input(event):
	if dragging:
		if Input.is_action_just_released("click"):
			if current == self:
				set_dragged_item(null)
			#end_drag()

func _on_mouse_entered():
	var hover := sprite.create_tween()
	hover.tween_property(sprite, "modulate:v", 1.2, 0.1)
	add_to_group("hovered")

func _on_mouse_exited():
	var unhover := sprite.create_tween()
	unhover.tween_property(sprite, "modulate:v", 1.0, 0.1)
	remove_from_group("hovered")
