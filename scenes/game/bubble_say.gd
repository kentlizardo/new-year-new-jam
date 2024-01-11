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
