extends MessageEvent

@export var message := ""
@export var contact : Contact
@export var as_player : MessageView.MessageAuthor = MessageView.MessageAuthor.AS_LAST

func _play():
	var bubble := MessageView.current.send_message(contact, message, as_player)
	await bubble.read()
	await get_tree().create_timer(1.0).timeout
