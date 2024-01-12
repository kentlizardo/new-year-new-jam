class_name ClientProfile extends Profile

static var current : ClientProfile # assume only one

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
	var all_files = DirAccess.get_files_at(MessageParser.DATES_PATH)
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
