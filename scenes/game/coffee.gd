class_name Coffee extends Draggable

@onready var init_pos := self.global_position

@export var break_sound : AudioStreamPlayer2D

func _ready():
	super()
	freeze = true
	var tw := create_tween()
	tw.tween_property(self, "global_position", init_pos, 1.6).from(init_pos + Vector2(300, 0)).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUINT)
	await tw.finished
	freeze = false

func refresh_coffee():
	break_sound.reparent(get_parent())
	break_sound.play()
	break_sound.finished.connect(break_sound.call_deferred.bind("queue_free"))
	var new_coffee := preload("res://scenes/game/coffee.tscn").instantiate() as Node2D
	new_coffee.global_position = init_pos
	get_parent().call_deferred("add_child", new_coffee)
	queue_free()
