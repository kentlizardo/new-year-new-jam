class_name BubbleChoice extends RichTextLabel

func setup(text : String):
	self.text = "[url]%s[/url]" % text

func read():
	if !is_inside_tree():
		await tree_entered
	if !is_visible_in_tree():
		await visibility_changed
	visible_characters = 0
	while visible_characters < len(text.replace("/[^a-z0-9-]/g", "")):
		var char_timer := get_tree().create_timer(0.005)
		await char_timer.timeout
		visible_characters += 1
