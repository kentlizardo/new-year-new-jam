extends Control

@onready var player : AnimationPlayer = $AnimationPlayer

func _ready():
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 1.0, 2.0).from(0.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	await tw.finished
	player.play("open")
