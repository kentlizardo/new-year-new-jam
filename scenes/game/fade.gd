class_name Fade extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5).from(0.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
