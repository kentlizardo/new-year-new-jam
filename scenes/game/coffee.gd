class_name Coffee extends Draggable

@onready var init_pos := self.global_position

func _ready():
	super()
	freeze = true
	var tw := create_tween()
	tw.tween_property(self, "global_position", init_pos, 8.0).from(init_pos + Vector2(300, 0)).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUINT)
	await tw.finished
	freeze = false

func refresh_coffee():
	var new_coffee := preload("res://scenes/game/coffee.tscn").instantiate() as Node2D
	new_coffee.global_position = init_pos
	get_parent().call_deferred("add_child", new_coffee)
	queue_free()
