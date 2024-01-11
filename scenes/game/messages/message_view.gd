class_name MessageView extends Control

const USER_ICON_TEMPLATE = preload("res://scenes/game/messages/user_icon.tscn")
const USER_MESSAGES_TEMPLATE = preload("res://scenes/game/messages/user_messages.tscn")

enum MessageAuthor {
	CONTACT,
	PLAYER,
	GLOBAL,
	AS_LAST,
}

static var current : MessageView

@export var user_icons : Control
@export var user_messages_root : Control

var contacts : Dictionary = {} # Contact -> UserBinding
var contact_shown : Contact

func _init():
	current = self

func add_contact(contact : Contact):
	var user_icon := USER_ICON_TEMPLATE.instantiate() as UserIcon
	user_icon.texture = contact.pfp
	var new_messages := USER_MESSAGES_TEMPLATE.instantiate() as UserMessages
	new_messages.visible = false
	new_messages.contact_pfp = contact.pfp
	
	user_icons.add_child(user_icon)
	user_messages_root.add_child(new_messages)
	contacts[contact] = UserBinding.new(user_icon, new_messages)
	
	user_icon.clicked.connect(func(): focus(contact))
	if !contact_shown:
		focus(contact)

func focus(contact : Contact):
	if contact_shown:
		_hide(contact_shown)
	contact_shown = contact
	if contacts.keys().has(contact):
		_show(contact)

func _show(contact : Contact):
	var p := contacts[contact] as UserBinding
	(p.messages as CanvasItem).visible = true
	var icon := (p.tab_icon as CanvasItem)
	icon.get_parent().move_child(icon, 0)
	p.tab_icon.clear_notifications()

func _hide(contact : Contact):
	var p := contacts[contact] as UserBinding
	(p.messages as CanvasItem).visible = false

func check_contact(contact : Contact):
	if !contacts.has(contact):
		print("adding missing contact" + contact.name)
		add_contact(contact)

func send_message(contact : Contact, message : String, author : MessageAuthor) -> BubbleSay:
	check_contact(contact)
	var binding := contacts[contact] as UserBinding
	var bubble := binding.messages.say(message, author)
	if contact_shown != contact:
		binding.tab_icon.add_notification()
	return bubble

func send_media(contact : Contact, media : Array[Texture2D], author : MessageAuthor) -> BubbleMedia:
	check_contact(contact)
	var binding := contacts[contact] as UserBinding
	var bubble := binding.messages.send_media(media, author)
	if contact_shown != contact:
		binding.tab_icon.add_notification()
	return bubble

func make_choice(contact : Contact, choices : Array) -> ChoiceRoot:
	check_contact(contact)
	var binding := contacts[contact] as UserBinding
	var bubbles := binding.messages.make_choice(choices)
	if contact_shown != contact:
		binding.tab_icon.add_notification()
	return bubbles

class UserBinding extends RefCounted:
	var tab_icon : UserIcon
	var messages : UserMessages
	func _init(icon : UserIcon, messages : UserMessages):
		self.tab_icon = icon
		self.messages = messages
