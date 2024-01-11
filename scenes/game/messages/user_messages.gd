class_name UserMessages extends ScrollContainer

const PLAYER_PFP = preload("res://assets/textures/pfp.png")
const BUBBLE_SAY_TEMPLATE = preload("res://scenes/game/bubble_say.tscn")
const BUBBLE_MEDIA_TEMPLATE = preload("res://scenes/game/bubble_media.tscn")
const CHOICE_ROOT_TEMPLATE = preload("res://scenes/game/messages/choice_root.tscn")

@export var message_root : Control
@export var choice_root_container : Control

@onready var scrollbar := get_v_scroll_bar()

var max_scroll := 0
var contact_pfp : Texture2D
var last_author : MessageView.MessageAuthor = MessageView.MessageAuthor.GLOBAL

func _ready():
	scrollbar.changed.connect(on_scroll_changed)
	max_scroll = scrollbar.max_value

func on_scroll_changed():
	if max_scroll != scrollbar.max_value:
		max_scroll = scrollbar.max_value
		scroll_vertical = max_scroll

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

func send_media(media : Array[Texture2D], author : MessageView.MessageAuthor) -> BubbleMedia:
	var bubble := BUBBLE_MEDIA_TEMPLATE.instantiate() as BubbleMedia
	var align : BubbleMedia.BubbleAlignment
	if author == MessageView.MessageAuthor.AS_LAST:
		author = last_author
	assert(author != MessageView.MessageAuthor.AS_LAST, "Author invariant violated. Should never set last_author to AS_LAST")
	match(author):
		MessageView.MessageAuthor.CONTACT:
			align = BubbleMedia.BubbleAlignment.LEFT
		MessageView.MessageAuthor.PLAYER:
			align = BubbleMedia.BubbleAlignment.RIGHT
		MessageView.MessageAuthor.GLOBAL:
			align = BubbleMedia.BubbleAlignment.MIDDLE
	bubble.setup(align, media)
	if author != MessageView.MessageAuthor.AS_LAST:
		last_author = author
	message_root.add_child(bubble)
	return bubble

func make_choice(choices : Array) -> ChoiceRoot:
	var choice_root = CHOICE_ROOT_TEMPLATE.instantiate() as ChoiceRoot
	choice_root.setup(choices)
	choice_root_container.add_child(choice_root)
	return choice_root
