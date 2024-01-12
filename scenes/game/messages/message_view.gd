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

func reveal():
	visible = true
	var shown_pos := get_viewport_rect().size / 2 - size / 2 
	var hidden_pos := get_viewport_rect().size / 2 - size / 2 + Vector2(0, get_viewport_rect().size.y)
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 1.0, 0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	tw.parallel().tween_property(self, "global_position", shown_pos, 0.5).from(hidden_pos).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
func unreveal():
	var shown_pos := get_viewport_rect().size / 2 - size / 2 
	var hidden_pos := get_viewport_rect().size / 2 - size / 2 + Vector2(0, get_viewport_rect().size.y)
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	tw.parallel().tween_property(self, "global_position", hidden_pos, 0.5).from(shown_pos).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	await tw.finished
	visible = false

func _ready():
	visible = false

func add_contact(contact : Contact):
	var user_icon := USER_ICON_TEMPLATE.instantiate() as UserIcon
	user_icon.texture = contact.pfp
	var new_messages := USER_MESSAGES_TEMPLATE.instantiate() as UserMessages
	new_messages.visible = false
	new_messages.contact_pfp = contact.pfp
	
	user_icons.add_child(user_icon)
	user_icons.move_child(user_icon, 0)
	user_messages_root.add_child(new_messages)
	contacts[contact] = UserBinding.new(user_icon, new_messages)
	
	user_icon.clicked.connect(func(): focus(contact))
	if !contact_shown:
		focus(contact)

signal contact_focused(contact : Contact)

func focus(contact : Contact):
	if contact_shown:
		_hide_contact(contact_shown)
	contact_shown = contact
	if contacts.keys().has(contact):
		_show_contact(contact)
	contact_focused.emit(contact_shown)

func _show_contact(contact : Contact):
	var p := contacts[contact] as UserBinding
	(p.messages as CanvasItem).visible = true
	var icon := (p.tab_icon as CanvasItem)
	icon.get_parent().move_child(icon, 0)
	p.tab_icon.clear_notifications()

func _hide_contact(contact : Contact):
	var p := contacts[contact] as UserBinding
	(p.messages as CanvasItem).visible = false

func check_contact(contact : Contact):
	if !contacts.has(contact):
		print("adding missing contact" + contact.name)
		add_contact(contact)

func get_contact_messages(contact : Contact) -> UserMessages:
	if contacts.has(contact):
		var binding : UserBinding = contacts[contact]
		return binding.messages
	return null

func wait_until_open(contact : Contact):
	var next_focus = contact_shown
	while next_focus != contact:
		next_focus = await contact_focused

func send_message(contact : Contact, message : String, author : MessageAuthor) -> BubbleSay:
	check_contact(contact)
	wait_until_open(contact)
	var binding := contacts[contact] as UserBinding
	var bubble := binding.messages.say(message, author)
	if contact_shown != contact:
		binding.tab_icon.add_notification()
	return bubble

func send_media(contact : Contact, media : Array[Texture2D], author : MessageAuthor) -> BubbleMedia:
	check_contact(contact)
	wait_until_open(contact)
	var binding := contacts[contact] as UserBinding
	var bubble := binding.messages.send_media(media, author)
	if contact_shown != contact:
		binding.tab_icon.add_notification()
	return bubble

func make_choice(contact : Contact, choices : Array) -> ChoiceRoot:
	check_contact(contact)
	wait_until_open(contact)
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
