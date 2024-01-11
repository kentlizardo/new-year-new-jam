extends MessageEvent

@export var message := ""
@export var contact : Contact
@export var as_player : MessageView.MessageAuthor = MessageView.MessageAuthor.AS_LAST

func _play():
	MessageView.current.send_message(contact, message, as_player)
