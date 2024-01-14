class_name Opening extends Control

signal finished

@export var color : ColorRect
@export var comic : Control

@onready var player : AnimationPlayer = $AnimationPlayer

func _ready():
	var tw := create_tween()
	tw.tween_property(comic, "modulate:a", 1.0, 2.0).from(0.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	await tw.finished
	player.play("RESET")
	player.play("open")
	await player.animation_changed
	var c := create_tween()
	c.tween_property(color, "modulate:a", 0.0, 4.0).from(1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	await c.finished
	color.visible = false
	finished.emit()
