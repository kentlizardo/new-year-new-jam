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
	user_icons.add_child(user_icon)
	user_messages_root.add_child(new_messages)
	contacts[contact] = UserBinding.new(user_icon, new_messages)
	if !contact_shown:
		focus(contact)

func focus(contact : Contact):
	if contacts.keys().has(contact):
		if contact_shown:
			_hide(contact_shown)
		_show(contact)
	else:
		push_error("Error: Cannot focus on a contact that is not bound to MessageView")

func _show(contact : Contact):
	var p := contacts[contact] as UserBinding
	(p.messages as CanvasItem).visible = true
	var icon := (p.tab_icon as CanvasItem)
	icon.get_parent().move_child(icon, 0)
	p.tab_icon.clear_notifications()

func _hide(contact : Contact):
	var p := contacts[contact] as UserBinding
	(p.messages as CanvasItem).visible = false

func send_message(contact : Contact, message : String, author : MessageAuthor) -> BubbleSay:
	if !contacts.keys().has(contact):
		print("adding missing contact" + contact.name)
		add_contact(contact)
	var binding := contacts[contact] as UserBinding
	var bubble := binding.messages.send_message(message, author)
	if contact_shown != contact:
		binding.tab_icon.add_notification()
	return bubble

class UserBinding extends RefCounted:
	var tab_icon : UserIcon
	var messages : UserMessages
	func _init(icon : UserIcon, messages : UserMessages):
		self.tab_icon = icon
		self.messages = messages
