class_name BubbleSay extends Control

@export var pfp_left : TextureRect
@export var pfp_right : TextureRect
@export var label : RichTextLabel
@export var box_container : HBoxContainer

enum BubbleAlignment {
	LEFT,
	MIDDLE,
	RIGHT,
}

func clean():
	pfp_left.visible = false
	pfp_left.texture = null
	pfp_right.visible = false
	pfp_right.texture = null
	label.text = "N/A"
	box_container.alignment = BoxContainer.ALIGNMENT_BEGIN

func setup(text : String, align : BubbleAlignment, icon : Texture2D):
	clean()
	match(align):
		BubbleAlignment.LEFT:
			box_container.alignment = BoxContainer.ALIGNMENT_BEGIN
			pfp_left.visible = true
			pfp_left.texture = icon
		BubbleAlignment.RIGHT:
			box_container.alignment = BoxContainer.ALIGNMENT_END
			pfp_right.visible = true
			pfp_right.texture = icon
		BubbleAlignment.MIDDLE:
			box_container.alignment = BoxContainer.ALIGNMENT_CENTER
	label.text = text
	
