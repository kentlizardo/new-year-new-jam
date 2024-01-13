class_name Hand extends Sprite2D

@export var idle : Node2D
@export var prompt : Node2D
@export var accept : Node2D

static var current : Hand

var valid_recipe := false:
	set(x):
		valid_recipe = x
		check_status()
var can_grab := false:
	set(x):
		can_grab = x
		check_status()

func check_status():
	if ClientProfile.current == null:
		_move_to(idle)
		return
	if valid_recipe:
		if can_grab:
			_move_to(accept)
		else:
			_move_to(prompt)
	else:
		_move_to(idle)

func _ready():
	current = self

func drop(body : Node2D):
	if body is Draggable:
		if body.get_parent() is Tray:
			var tray := body.get_parent() as Tray
			body.freeze = true
			body.input_pickable = false
			tray.submit()
			tray.reparent(self)

func _move_to(node : Node2D):
	var tw := create_tween()
	tw.tween_property(self, "global_position", node.global_position, 2.4).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

func _on_area_2d_body_entered(body : Node2D):
	if body.is_in_group("tray_bodies"):
		can_grab = true
		body.drop_zone = self

func _on_area_2d_body_exited(body : Node2D):
	if body.is_in_group("tray_bodies"):
		can_grab = false
		if body.drop_zone == self:
			body.drop_zone = null
