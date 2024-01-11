class_name UserIcon extends TextureRect

signal clicked

@export var notification_label : Label

var notifications := 0:
	set(x):
		notifications = x
		notification_label.text = str(notifications)

func add_notification():
	notifications += 1
	notification_label.visible = true
	notification_label.text = str(notifications)

func clear_notifications():
	notifications = 0
	notification_label.visible = false

func _gui_input(event):
	if Input.is_action_just_pressed("click"):
		clicked.emit()
