class_name Overlay extends Fade

@export var profile_tex : Texture2D
@export var profile_sprite : Sprite2D

func destroy():
	var hide = create_tween()
	hide.tween_property(self, "modulate:a", 0.0, 0.4).from(1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	await hide.finished
	queue_free()

func _ready():
	super()
	profile_sprite.texture = profile_tex
	var tw := create_tween()
	tw.tween_property(profile_sprite, "position", Vector2.ZERO, 0.15).from(Vector2(0, 768)).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tw.parallel().tween_property(profile_sprite, "modulate:a", 1.0, 0.06).from(0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART)

#func _process(delta):
	#profile_sprite.global_position = get_viewport().size / 2
