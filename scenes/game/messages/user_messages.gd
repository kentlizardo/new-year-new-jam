class_name UserMessages extends ScrollContainer

const PLAYER_PFP = preload("res://assets/textures/pfp.png")
const BUBBLE_SAY_TEMPLATE = preload("res://scenes/game/bubble_say.tscn")
const BUBBLE_MEDIA_TEMPLATE = preload("res://scenes/game/bubble_media.tscn")

@export var message_root : Control
@export var choice_root : Control

var contact_pfp : Texture2D

var last_author : MessageView.MessageAuthor = MessageView.MessageAuthor.GLOBAL

func say(message : String, author : MessageView.MessageAuthor) -> BubbleSay:
	var bubble := BUBBLE_SAY_TEMPLATE.instantiate() as BubbleSay
	var align : BubbleSay.BubbleAlignment
	if author == MessageView.MessageAuthor.AS_LAST:
		author = last_author
	assert(author != MessageView.MessageAuthor.AS_LAST, "Author invariant violated. Should never set last_author to AS_LAST")
	var pfp : Texture2D = null
	match(author):
		MessageView.MessageAuthor.CONTACT:
			align = BubbleSay.BubbleAlignment.LEFT
			pfp = contact_pfp
		MessageView.MessageAuthor.PLAYER:
			align = BubbleSay.BubbleAlignment.RIGHT
			pfp = PLAYER_PFP
		MessageView.MessageAuthor.GLOBAL:
			align = BubbleSay.BubbleAlignment.MIDDLE
			pfp = null
	bubble.setup(message, align, pfp)
	if author != MessageView.MessageAuthor.AS_LAST:
		last_author = author
	message_root.add_child(bubble)
	return bubble

