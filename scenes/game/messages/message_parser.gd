class_name MessageParser extends MessageGroup

const CONTACTS_PATH := "res://scenes/game/messages/contacts/"
const MEDIA_PATH := "res://scenes/game/messages/media"

const EventSay := preload("res://scenes/game/messages/events/msg_evt_say.gd")
const EventMedia := preload("res://scenes/game/messages/events/msg_evt_media.gd")

@export_file("*.txt") var source

var registered_contacts : Dictionary = {} # string -> Resource(Contact)
var registered_media : Dictionary = {} # string -> Resource(Texture2D)

var pointer : Node = self
var labeled : Dictionary = {} # string -> Node(most likely MessageEvent)
var main_contact : Contact = null
var aliases : Dictionary = {} # string -> MessageView.MessageAuthor

func _ready():
	var contact_paths := DirAccess.get_files_at(CONTACTS_PATH)
	for path in contact_paths:
		var res := load(CONTACTS_PATH + path) as Contact
		if res:
			registered_contacts[path.get_file().trim_suffix(".tres")] = res
	var media_paths := DirAccess.get_files_at(MEDIA_PATH)
	for path in media_paths:
		var res := load(MEDIA_PATH + path) as Texture2D
		if res:
			registered_contacts[path.get_file()] = res
	var file := FileAccess.open(source, FileAccess.READ)
	if file:
		parse_file(file)
	linearize()

func parse_file(file : FileAccess):
	var file_content := file.get_as_text()
	var context_indent_level := 0
	for line : String in file_content.split("\n"):
		var current_indent_level := 0
		var created_node : Node = null
		var line_label := ""
		# Find indent level
		while line.begins_with("\t"):
			current_indent_level += 1
			line = line.trim_prefix("\t")
		# Create label
		if line.begins_with("<"):
			var left := line.find("<")
			var right := line.rfind(">")
			line_label = line.substr(left + 1, right - left - 1)
			line = line.replace("<" + line_label + ">", "").strip_edges()
		if line.begins_with("//"): # Comments
			continue
		elif line.begins_with("/"): # If its not a comment, it might be a command
			var command := line.trim_prefix("/")
			print("found command " + command)
			var left := command.find("(")
			var right := command.rfind(")")
			var raw_params := command.substr(left + 1, right - left - 1).strip_edges().split(",")
			var params : Array = []
			for raw in raw_params:
				var param : Variant = convert_param(raw.strip_edges())
				params.append(param)
			command = command.substr(0, left)
			command(command, params)
		else: # If it's neither, it's a message
			var author : MessageView.MessageAuthor = MessageView.MessageAuthor.AS_LAST
			var message_l := line.find("\"")
			var message_r := line.rfind("\"")
			var message := line.substr(message_l + 1, message_r - message_l - 1)
			line = line.substr(0, message_l) + line.substr(message_r, -1)	
			var alias_index := line.find(":")
			if alias_index != -1:
				var split := line.split(":")
				line = split[1].strip_edges()
				var alias_token := split[0].strip_edges()
				if alias_token.ends_with("?"):
					push_warning("implement ? suffix")
					alias_token = alias_token.trim_suffix("?")
				author = read_alias_token(alias_token)
			var say_event := EventSay.new()
			say_event.as_player = author
			say_event.contact = main_contact
			say_event.message = message
			pointer.add_child(say_event)
			created_node = say_event
		if line_label != "" and created_node != null:
			labeled[line_label] = created_node

func read_alias_token(token : String) -> MessageView.MessageAuthor:
	var alias := token
	if aliases.has(alias):
		var author := aliases[alias] as MessageView.MessageAuthor
		return author
	push_error("Error: could not read alias token of \"" + token + "\"")
	return MessageView.MessageAuthor.AS_LAST

func convert_param(token : String):
	if token.begins_with("<"):
		var line_label := LineLabel.new(token.trim_prefix("<").trim_suffix(">"))
		return LineLabel
	return token.trim_prefix("\"").trim_suffix("\"")

func command(command : String, params : Array) -> Node:
	#print("executing command " + command + " with params " + ", ".join(params))
	match(command):
		"set_main_contact":
			main_contact = registered_contacts[(params[0] as String)]
		"add_contact_alias":
			var alias := (params[0] as String)
			aliases[alias] = MessageView.MessageAuthor.CONTACT
		"add_player_alias":
			var alias := (params[0] as String)
			aliases[alias] = MessageView.MessageAuthor.PLAYER
		"add_global_alias":
			var alias := (params[0] as String)
			aliases[alias] = MessageView.MessageAuthor.GLOBAL
		"media":
			var alias := (params[0] as String).strip_edges()
			params.remove_at(0)
			var textures : Array[Texture2D] = []
			for path in params:
				if path is String:
					if registered_media.has(path):
						textures.append(registered_media[path])
					else:
						textures.append(null)
			var event_media := EventMedia.new()
			event_media.media = textures
			event_media.contact = main_contact
			event_media.as_player = read_alias_token(alias)
			pointer.add_child(event_media)
	return null

class LineLabel extends RefCounted:
	var name : String = ""
	func _init(name):
		self.name = name
