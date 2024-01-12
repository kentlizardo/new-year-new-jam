extends Button

@export var scene : PackedScene

func _ready():
	self.pressed.connect(_new_game)

func _new_game():
	DataManager.game_data = DataManager.new_game_data.duplicate()
	Workday.faux_save = {}
	App.stage(scene)
