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
	var author := as_player
	if as_player == MessageView.MessageAuthor.AS_LAST:
		var messages := MessageView.current.get_contact_messages(contact)
		if messages:
			author = messages.last_author
		else:
			push_error("Error: message with author of LAST_AUTHOR with no previous message history")
			author = MessageView.MessageAuthor.GLOBAL
	#if require_prompt and author == MessageView.MessageAuthor.PLAYER:
	# Always make player click message to proceed with message
	if author == MessageView.MessageAuthor.PLAYER:
		var bubbles := MessageView.current.make_choice(contact, [message])
		var answer = await bubbles.choice_taken
		MessageView.current.send_message(contact, answer, MessageView.MessageAuthor.PLAYER)
	else:
		var bubble := MessageView.current.send_message(contact, message, author)
		if !skip:
			await bubble.read()
		#await get_tree().create_timer(1.0).timeout
