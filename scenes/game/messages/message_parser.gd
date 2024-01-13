class_name MessageParser extends MessageGroup

# Used to signal when to link nodes and branches
signal built

const CONTACTS_PATH := "res://scenes/game/messages/contacts/"
const MEDIA_PATH := "res://scenes/game/messages/media"
const DATES_PATH := "res://scenes/dates/"

const EventSay := preload("res://scenes/game/messages/events/msg_evt_say.gd")
const EventMedia := preload("res://scenes/game/messages/events/msg_evt_media.gd")
const EventChoices := preload("res://scenes/game/messages/events/msg_evt_choices.gd")
const EventGroup := preload("res://scenes/game/messages/message_group.gd")
const EventMarkHistory := preload("res://scenes/game/messages/events/msg_evt_mark_history.gd")

@export_file("*.txt") var source

var registered_contacts : Dictionary = {} # string -> Resource(Contact)
var registered_media : Dictionary = {} # string -> Resource(Texture2D)

var pointer : Node = EventGroup.new()
var pointer_predecessors : Array[Node] = [] # Used to keep tab scopes
var main_contact : Contact = null
var labeled : Dictionary = {} # string -> Node(most likely MessageEvent)
var aliases : Dictionary = {} # string -> MessageView.MessageAuthor

static func load_index(text : String) -> Array[String]:
	var index : Array[String] = []
	for line : String in text.split("\n"):
		if !line.is_empty():
			index.push_back(line)
	return index

static func save_index(path : String, file_names : Array):
	var file := FileAccess.open(path, FileAccess.WRITE)
	for file_name in file_names:
		file.store_line(file_name)
	file.close()

static func register_resources():
	var not_an_index = func(path : String) -> bool:
		return path != "index.txt"
	var contact_dir_paths := DirAccess.get_files_at(CONTACTS_PATH)
	var media_dir_paths := DirAccess.get_files_at(MEDIA_PATH)
	var dates_dir_paths := DirAccess.get_files_at(DATES_PATH)
	# Save for future exported builds
	print("Running in editor, so writing index files.")
	save_index(CONTACTS_PATH + "index.txt", Array(contact_dir_paths).filter(not_an_index))
	save_index(MEDIA_PATH + "index.txt", Array(media_dir_paths).filter(not_an_index))
	save_index(DATES_PATH + "index.txt", Array(dates_dir_paths).filter(not_an_index))

func _ready():
	var contact_files := []
	var media_files := []
	# Load index files
	var contact_index := FileAccess.open(CONTACTS_PATH + "index.txt", FileAccess.READ)
	if contact_index:
		contact_files = load_index(contact_index.get_as_text())
		contact_index.close()
	else:
		push_error("Error: no index file in " + CONTACTS_PATH + ". Try running a non-standalone version of the editor to generate the index file.")
	var media_index := FileAccess.open(MEDIA_PATH + "index.txt", FileAccess.READ)
	if media_index:
		media_files = load_index(media_index.get_as_text())
		media_index.close()
	else:
		push_error("Error: no index file in " + MEDIA_PATH + ". Try running a non-standalone version of the editor to generate the index file.")
	
	for path in contact_files:
		var res := load(CONTACTS_PATH + path) as Contact
		if res:
			registered_contacts[path.get_file().trim_suffix(".tres")] = res
		else:
			push_error("could not load contact contact resource " + CONTACTS_PATH + path)
	for path in media_files:
		var res := load(MEDIA_PATH + path) as Texture2D
		if res:
			registered_contacts[path.get_file()] = res
		else:
			push_error("could not load contact media resource " + MEDIA_PATH + path)
	if !source.ends_with(".txt"):
		source += ".txt"
	var file := FileAccess.open(source, FileAccess.READ)
	if file:
		parse_file(file)
	else:
		push_error("MessageParser with invalid source: " + source)
	built.emit()
	linearize()
	file.close()
	add_child(pointer)

const WRAP_LENGTH = 40
func clean_message(contents : String):
	contents = contents.replace("\n ", "\n")#.replace("\n", " ")
	var buffer_length := 0
	var newline_injects : Array[int] = []
	var index := 0
	for ch in contents:
		if ch == "\n":
			buffer_length = 0
		if ch == " ": # only wrap after a word ends
			if buffer_length >= WRAP_LENGTH:
				newline_injects.append(index)
				buffer_length = 0
		buffer_length += 1
		index += 1
	var injected := 0
	for i in newline_injects:
		contents = contents.insert(i + injected, "\n")
		injected += 1
	return contents

func parse_file(file : FileAccess):
	var file_content := file.get_as_text()
	var context_indent_level := 0
	var last_created_node : Node = null
	for line : String in file_content.split("\n"):
		line = line.replace("“", "\"")
		line = line.replace("”", "\"")
		var current_indent_level := 0
		var created_node : Node = null
		var line_label := ""
		# Find indent level
		while line.begins_with("    "):
			current_indent_level += 1
			line = line.trim_prefix("    ")
		assert(abs(current_indent_level - context_indent_level) <= 1, "Cannot change indent more than one at a time.")
		if current_indent_level > context_indent_level:
			pointer_predecessors.append(pointer)
			pointer = last_created_node
		elif current_indent_level < context_indent_level:
			pointer = pointer_predecessors.pop_back()
		else: # pointer should stay the same
			pass
		# Create label
		if line.begins_with("<"):
			var left := line.find("<")
			var right := line.find(">")
			line_label = line.substr(left + 1, right - left - 1)
			line = line.replace("<" + line_label + ">", "").strip_edges()
		if line.begins_with("//"): # Comments
			continue
		elif line.begins_with("/"): # If its not a comment, it might be a command
			var command := line.trim_prefix("/")
			#print("found command " + command)
			var left := command.find("(")
			var right := command.rfind(")")
			var raw_params := command.substr(left + 1, right - left - 1).strip_edges().split(",")
			var params : Array = []
			for raw in raw_params:
				var param : Variant = convert_param(raw.strip_edges())
				params.append(param)
			command = command.substr(0, left)
			created_node = command(command, params)
		elif line.find("\"") != line.rfind("\""): # If it's neither, it's most likely a message
			var author : MessageView.MessageAuthor = MessageView.MessageAuthor.AS_LAST
			var result := parse_message_literal(line)
			var message_literal : MessageLiteral = result["message"]
			if message_literal:
				if message_literal.alias != "":
					author = read_alias_token(message_literal.alias)
				var say_event := EventSay.new()
				say_event.as_player = author
				say_event.contact = main_contact
				say_event.message = message_literal.message
				say_event.require_prompt = message_literal.require_prompt
				for i in message_literal.modifiers:
					if i == "skip":
						say_event.skip = true
				pointer.add_child(say_event)
				created_node = say_event
		if line_label != "" and created_node != null:
			labeled[line_label] = created_node
		if created_node:
			last_created_node = created_node
		var modifiers := line.split(" ")
		for modifier in modifiers:
			modifier = modifier.strip_edges()
			if modifier.begins_with("*<"):
				var label := modifier.trim_prefix("*<").trim_suffix(">")
				branch_towards(last_created_node, LineLabel.new(label))
		context_indent_level = current_indent_level

func parse_message_literal(token : String) -> Dictionary: # Tuple(message: MessageLiteral, post_content: String)
	token = token.strip_edges()
	var results := {}
	results["message"] = null
	results["post_content"] = token
	var message_l := token.find("\"")
	var message_r := token.rfind("\"")
	if message_l != -1 and message_r != -1:
		if message_l != message_r:
			var alias := ""
			var message := ""
			var modifiers : Array[String] = []
			var require_prompt := false
			
			message = token.substr(message_l + 1, message_r - message_l - 1)
			message = message.replace("\\n", "\n")
			message = clean_message(message)
			
			var pre_content := token.substr(0, message_l)
			var post_content := token.substr(message_r, -1)	
			# Create alias from pre_content if there is one
			var alias_index := pre_content.find(":")
			if alias_index != -1:
				var split := pre_content.split(":")
				pre_content = split[1].strip_edges()
				var alias_token := split[0].strip_edges()
				if alias_token.ends_with("?"):
					alias_token = alias_token.trim_suffix("?")
					require_prompt = true
				alias = alias_token
			# Create modifiers from post_content
			for possible_modifier in post_content.split(" "):
				if possible_modifier.begins_with("+"):
					var modifier := possible_modifier.trim_prefix("+")
					modifiers.push_back(modifier)
					post_content = post_content.replace(possible_modifier, "")
			# alias message modifiers
			results["message"] = MessageLiteral.new(alias, message, modifiers, require_prompt)
			results["post_content"] = post_content
			return results
		else:
			return results
	else:
		return results

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
		return line_label
	elif token.begins_with("%"):
		var l := token.find("%")
		var r := token.rfind("%")
		if l != -1:
			if l != r:
				var flag_access := token.trim_prefix("%").trim_suffix("%")
				if DataManager.game_data.flags.has(flag_access):
					return DataManager.game_data.flags[flag_access]
				else:
					push_error("Error: Could not convert DataFlag Literal as it was not found. " + flag_access)
	return token.trim_prefix("\"").trim_suffix("\"")

func command(command : String, params : Array) -> Node:
	#print("executing command " + command + " with params " + ", ".join(params))
	match(command):
		"set_main_contact":
			main_contact = registered_contacts[(params[0] as String)]
			aliases = {}
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
			return event_media
		"group":
			var event_group := EventGroup.new()
			event_group.contact = main_contact
			pointer.add_child(event_group)
			return event_group
		"message_parser":
			var file_name := params[0] as String
			if file_name:
				var parser := MessageParser.new()
				parser.source = DATES_PATH + file_name
				pointer.add_child(parser)
				return parser
			else:
				push_error("Invalid formatting for message_parser with params " + str(params))
		"mark_history":
			var key := params[0] as String
			if key:
				var event := EventMarkHistory.new()
				event.key = key
				pointer.add_child(event)
				return event
		"choice":
			var event_choices := EventChoices.new()
			event_choices.contact = main_contact
			pointer.add_child(event_choices)
			return event_choices
		"add_to_choice":
			add_to_choice(params)
		"set_flag":
			var flag_id := params[0] as String
			var data = params[1]
			DataManager.game_data.flags[flag_id] = data
		"push_date":
			var date_filename := params[0] as String
			date_filename = date_filename.trim_suffix(".txt")
			var full_date_path := DATES_PATH + date_filename + ".txt"
			DataManager.game_data.dates_left.push_back(full_date_path)
	return null

func add_to_choice(params : Array):
	await built
	var choice_addr := (params[0] as LineLabel)
	var event_choice := labeled[choice_addr.name] as EventChoices
	
	var text := (params[1] as String)
	
	var link := ChoiceLink.new()
	if params.size() > 2:
		var label := (params[2] as LineLabel)
		if labeled.has(label.name):
			var branch := labeled[label.name] as MessageEvent
			link.branch_event = event_choice.get_path_to(branch)
		else:
			push_error("Could not find label " + label.name)
	link.text = text
	event_choice.choices.append(link)

func branch_towards(event : MessageEvent, from : LineLabel):
	await built
	if labeled.has(from.name):
		var branch := labeled[from.name] as MessageEvent
		event.next_event = branch;
	else:
		push_error("Could not find label " + from.name)

class LineLabel extends RefCounted:
	var name : String = ""
	func _init(name):
		self.name = name

class MessageLiteral extends RefCounted:
	var alias := ""
	var message := ""
	var modifiers : Array[String] = []
	var require_prompt := false
	func _init(alias : String, message : String, modifiers : Array[String], require_prompt: bool):
		self.alias = alias
		self.message = message
		self.modifiers = modifiers
		self.require_prompt = require_prompt
