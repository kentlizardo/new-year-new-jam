extends Button

@export var scene : PackedScene

func _ready():
	self.pressed.connect(func(): App.stage(scene))
