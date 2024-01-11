extends MessageEvent

@export var message := ""
@export var as_player : MessageView.MessageAuthor = MessageView.MessageAuthor.AS_LAST
@export var skip := false
@export var require_prompt := false

func _play():
	var bubble := MessageView.current.send_message(contact, message, as_player)
	if !skip:
		await bubble.read()
	#await get_tree().create_timer(1.0).timeout
