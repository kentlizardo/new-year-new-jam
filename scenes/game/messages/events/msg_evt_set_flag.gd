extends MessageEvent

@export var flag_id := ""
@export var val := "" 

func _play():
	DataManager.game_data.flags[flag_id] = val
