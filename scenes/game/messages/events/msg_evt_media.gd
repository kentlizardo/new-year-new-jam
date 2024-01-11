extends MessageEvent

@export var media : Array[Texture2D]
@export var as_player : MessageView.MessageAuthor = MessageView.MessageAuthor.AS_LAST

func _play():
	var bubble := MessageView.current.send_media(contact, media, as_player)
	#await get_tree().create_timer(1.0).timeout
