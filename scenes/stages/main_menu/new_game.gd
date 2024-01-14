extends Button

@export var scene : PackedScene

func _ready():
	self.pressed.connect(_new_game)

func _new_game():
	DataManager.game_data = DataManager.new_game_data.duplicate()
	Workday.faux_save = {}
	MessageView.current.queue_free()
	var message_view := preload("res://scenes/game/messages/message_view.tscn").instantiate() as MessageView
	App.msg_root.add_child(message_view)
	App.stage(scene)
