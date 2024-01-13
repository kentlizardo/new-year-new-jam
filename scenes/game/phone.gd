class_name Phone extends Draggable

@export var notif_pivot : Node2D
@export var notif : Sprite2D

func _enter_tree():
	App.message_events_added.connect(show_notifs)
	App.message_events_done.connect(hide_notifs)
func _exit_tree():
	App.message_events_added.disconnect(show_notifs)
	App.message_events_done.disconnect(hide_notifs)

func show_notifs():
	var tw := notif.create_tween()
	tw.tween_property(notif, "scale", Vector2.ONE, 0.2)

func hide_notifs():
	var tw := notif.create_tween()
	tw.tween_property(notif, "scale", Vector2.ZERO, 0.2)

func _ready():
	super()
	self.double_clicked.connect(open)

func _process(delta):
	notif_pivot.global_rotation = 0

func open():
	if !MessageView.current.visible:
		MessageView.current.reveal()
		get_viewport().set_input_as_handled()
