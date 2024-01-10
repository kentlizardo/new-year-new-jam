class_name Overlay extends Node

@export var content_root : Control
@export var items : PackedScene

func _ready():
	var new_items = items.instantiate()
	content_root.add_child(new_items)

func destroy():
	var hide = create_tween()
	hide.tween_property(self, "modulate:a", 0, 0.2).from(1.0).set_trans(Tween.TRANS_SINE)
	await hide.finished
	queue_free()
