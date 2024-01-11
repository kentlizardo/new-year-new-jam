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
		tex_rect.texture = img
		media_root.add_child(tex_rect)
