class_name BubbleChoice extends RichTextLabel

@export var bg : NinePatchRect

func _ready():
	meta_hover_started.connect(highlight_bubble)
	meta_hover_ended.connect(unhighlight_bubble)

func highlight_bubble(meta : Variant):
	var hover := create_tween()
	hover.tween_property(bg, "modulate:a", 1.0, 0.2).from_current().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)

func unhighlight_bubble(meta : Variant):
	var hover := create_tween()
	hover.tween_property(bg, "modulate:a", 0.6, 0.2).from_current().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)

func setup(text : String):
	self.text = "[url]%s[/url]" % text

func read():
	if !is_inside_tree():
		await tree_entered
	if !is_visible_in_tree():
		await visibility_changed
	var show := create_tween()
	show.tween_property(bg, "modulate:a", 0.6, 0.2).from(0.0).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	visible_characters = 0
	while visible_characters < len(text.replace("/[^a-z0-9-]/g", "")):
		var char_timer := get_tree().create_timer(0.005)
		await char_timer.timeout
		visible_characters += 1
