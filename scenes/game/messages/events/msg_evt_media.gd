extends MessageEvent

@export var media : Array[Texture2D]
@export var as_player : MessageView.MessageAuthor = MessageView.MessageAuthor.AS_LAST

func _play():
	var author := as_player
	if as_player == MessageView.MessageAuthor.AS_LAST:
		var messages := MessageView.current.get_contact_messages(contact)
		if messages:
			author = messages.last_author
		else:
			push_error("Error: message with author of LAST_AUTHOR with no previous message history")
			author = MessageView.MessageAuthor.GLOBAL
	var bubble := MessageView.current.send_media(contact, media, author)
	if Input.is_action_pressed("ui_accept"):
		await get_tree().create_timer(0.2).timeout
	else:
		await get_tree().create_timer(1.0).timeout
