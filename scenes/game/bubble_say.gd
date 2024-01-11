class_name BubbleSay extends Control

const PATCH_BLUE := preload("res://assets/textures/message_blue.png")
const PATCH_RED := preload("res://assets/textures/message_red.png")
const PATCH_WHITE := preload("res://assets/textures/message_white.png")

@export var pfp_left : TextureRect
@export var pfp_right : TextureRect
@export var label : RichTextLabel
@export var box_container : HBoxContainer
@export var patch_rect : NinePatchRect

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
			patch_rect.texture = PATCH_BLUE
		BubbleAlignment.RIGHT:
			box_container.alignment = BoxContainer.ALIGNMENT_END
			pfp_right.visible = true
			pfp_right.texture = icon
			patch_rect.texture = PATCH_RED
		BubbleAlignment.MIDDLE:
			box_container.alignment = BoxContainer.ALIGNMENT_CENTER
			patch_rect.texture = PATCH_WHITE
	label.text = text
	
func read():
	if !is_inside_tree():
		await tree_entered
	if !is_visible_in_tree():
		await visibility_changed
	label.visible_characters = 0
	while label.visible_characters < len(label.text.replace("/[^a-z0-9-]/g", "")):
		var char_timer := get_tree().create_timer(0.05)
		await char_timer.timeout
		label.visible_characters += 1
