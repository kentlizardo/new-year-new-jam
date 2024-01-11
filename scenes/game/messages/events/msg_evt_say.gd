extends MessageEvent

@export var message := ""
@export var as_player : MessageView.MessageAuthor = MessageView.MessageAuthor.AS_LAST
@export var skip := false
# Originally intended to require a message to be "read"
# but now will be used to convert any player message to be
# manually clicked as a choice instead.
# TODO: Delegate author_switching to derived classes of MessageEvent
@export var require_prompt := false

func _play():
	if require_prompt:
		var bubbles := MessageView.current.make_choice(contact, [message])
		var answer = await bubbles.choice_taken
		MessageView.current.send_message(contact, answer, MessageView.MessageAuthor.PLAYER)
	else:
		var bubble := MessageView.current.send_message(contact, message, as_player)
		if !skip:
			await bubble.read()
		#await get_tree().create_timer(1.0).timeout
