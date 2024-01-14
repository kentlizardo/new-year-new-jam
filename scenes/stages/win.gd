class_name Win extends Control

@export var label : RichTextLabel

var wins := {
	"Herring": ["ryo", "rose", "joan"],
	"Boss": ["lucian", "rafael", "lichking", "true"],
}

func _ready():
	for i in wins.keys():
		var listed : Array = wins[i]
		var max := listed.size()
		var score := 0
		for goal in listed:
			if DataManager.user_history.has(goal):
				score += 1
		label.text = label.text.replace(i, "%s Routes Found " % i + str(score) + "/" + str(max))
	
