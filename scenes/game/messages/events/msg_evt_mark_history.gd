extends MessageEvent

@export var key : String

func _play():
	DataManager.user_history.append(key)
	DataManager.save_history()
