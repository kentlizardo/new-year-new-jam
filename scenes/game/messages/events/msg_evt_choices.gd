extends MessageEvent

@export var choices : Array[ChoiceLink] = []

func _play():
	var bubbles := MessageView.current.make_choice(contact, choices.map(get_text_from_link))
	var answer = await bubbles.choice_taken
	for link : ChoiceLink in choices:
		if link.text == answer:
			if !link.branch_event.is_empty():
				next_event = get_node(link.branch_event)
	MessageView.current.send_message(contact, answer, MessageView.MessageAuthor.PLAYER)
	print("choice made")
	#await get_tree().create_timer(1.0).timeout

func get_text_from_link(link : ChoiceLink) -> String:
	return link.text
