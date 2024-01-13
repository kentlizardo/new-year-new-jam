class_name Overlay extends Node

@export var profile_tex : Texture2D
@export var profile_sprite : Sprite2D

func destroy():
	var hide = create_tween()
	hide.tween_property(self, "modulate:a", 0.0, 0.2).from(1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	await hide.finished
	queue_free()

func _ready():
	profile_sprite.texture = profile_tex

func _process(delta):
	profile_sprite.global_position = get_viewport().size / 2
