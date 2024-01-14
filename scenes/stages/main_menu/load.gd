extends Button

func _ready():
	self.disabled = Workday.faux_save.is_empty()
	self.pressed.connect(func(): App.stage(load("res://scenes/stages/workday.tscn")))
