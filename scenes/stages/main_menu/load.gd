extends Button

var overlay := preload("res://scenes/game/overlay.tscn")

func _ready():
	self.pressed.connect(func():
		var x : Overlay = overlay.instantiate()
		x.items = preload("res://scenes/game/messages/message_view.tscn")
		App.current_scene.add_child(x)
		)
