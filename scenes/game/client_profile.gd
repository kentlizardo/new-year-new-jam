class_name ClientProfile extends Profile

static var current : ClientProfile :# assume only one
	set(x):
		current = x
		if current == null:
			App.submitted_to_client.emit()

@export var label : Label
@export var label_root : Node2D

var recipes : Dictionary = {} # String -> String

func _ready():
	super()
	label.text = name
	populate_recipes()

func _enter_tree():
	current = self 
func _exit_tree():
	if current == self:
		current = null

func _process(delta):
	label_root.global_rotation = 0

func populate_recipes():
	var all_files : Array[String] = []
	var date_index := FileAccess.open(MessageParser.DATES_PATH + "index.txt", FileAccess.READ)
	if date_index:
		all_files = MessageParser.load_index(date_index.get_as_text())
		date_index.close()
	else:
		push_error("Error: no index file in " + MessageParser.DATES_PATH + ". Try running a non-standalone version of the editor to generate the index file.")
	for file_name in all_files:
		if file_name.ends_with(".txt"):
			var date_identifier := file_name.trim_suffix(".txt")
			var date_tokens := date_identifier.split("_")
			if date_tokens.size() >= 3:
				if date_tokens[2] == "1": # only link first dates
					if date_tokens[0] == name.to_lower():
						var suitor := date_tokens[1]
						var dummy_recipe := suitor
						recipes[dummy_recipe] = file_name
