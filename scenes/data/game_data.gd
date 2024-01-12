class_name GameData extends Resource

@export var clients_left : Array[ClientJob]
@export var last_client : ClientJob
@export var dates_left : Array[String] = [] # paths to date files
@export var pack_stack : Array[PackedScene] = []

var flags : Dictionary = {}

func get_workday() -> Dictionary:
	var result := {}
	result["packs"] = pack_stack
	result["dates"] = []
	pack_stack = []
	var added_client := false
	var added_date := false
	if clients_left.size() > 0:
		var client := clients_left.pick_random() as ClientJob
		clients_left.remove_at(clients_left.find(client))
		result["packs"].append(client.main_pack)
		added_client = true
	if dates_left.size() > 0:
		var date := dates_left.pick_random() as String
		dates_left.remove_at(dates_left.find(date))
		result["dates"].append(date)
		added_date = true
	if !added_client and !added_date:
		if clients_left.size() == 0 and dates_left.size() == 0: # extra assertions
			if last_client:
				result["packs"].append(last_client.main_pack)
				last_client == null
			else:
				print("won the game!")
				return {}
	print("starting new workday with " + str(result))
	return result
