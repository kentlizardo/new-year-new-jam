class_name GameData extends Resource

@export var clients_remaining : Array[ClientJob]

func get_workday() -> Array[PackedScene]:
	var packs : Array[PackedScene] = []
	
	var client := clients_remaining.pick_random() as ClientJob
	clients_remaining.remove_at(clients_remaining.find(client))
	packs.append(client.main_pack)
	return packs
