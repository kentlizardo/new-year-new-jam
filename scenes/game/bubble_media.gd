class_name BubbleMedia extends MarginContainer

enum BubbleAlignment {
	LEFT,
	MIDDLE,
	RIGHT,
}

@export var media_root : Control

var IMAGE_TEMPLATE = preload("res://scenes/game/messages/bubble_media_image.tscn")

func clean():
	(self as Control).set_anchors_preset(Control.PRESET_CENTER)

const MEDIA_SIZE := 0.2
func setup(align : BubbleAlignment, images : Array[Texture2D]):
	clean()
	match(align):
		BubbleAlignment.LEFT:
			(self as Control).set_anchors_preset(Control.PRESET_CENTER_LEFT)
		BubbleAlignment.RIGHT:
			(self as Control).set_anchors_preset(Control.PRESET_CENTER_RIGHT)
		BubbleAlignment.MIDDLE:
			(self as Control).set_anchors_preset(Control.PRESET_CENTER)
	for img in images:
		var tex_rect := IMAGE_TEMPLATE.instantiate() as TextureRect
		if img:
			tex_rect.texture = img
			tex_rect.custom_minimum_size  = img.get_size() * MEDIA_SIZE
		media_root.add_child(tex_rect)

func read():
	if !is_inside_tree():
		await tree_entered
	if !is_visible_in_tree():
		await visibility_changed
	var show := create_tween()
	show.tween_property(self, "modulate:a", 1.0, 0.2).from(0.0).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
