extends MessageEvent

@export var key : String

func _play():
	if !DataManager.user_history.has(key):
		DataManager.user_history.append(key)
		DataManager.save_history()
