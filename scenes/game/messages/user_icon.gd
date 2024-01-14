class_name UserIcon extends Control

signal clicked

@export var notification_label : Label
@export var icon : TextureRect
@export var mask : TextureRect

var notifications := 0:
	set(x):
		notifications = x
		notification_label.text = str(notifications)

func add_notification():
	notifications += 1
	notification_label.visible = true
	notification_label.text = str(notifications)
	if is_instance_valid(Phone.current_phone):
		if !Phone.current_phone.tap_sound.playing:
			Phone.current_phone.tap_sound.play()

func clear_notifications():
	notifications = 0
	notification_label.visible = false

func _gui_input(event):
	if Input.is_action_just_pressed("click"):
		clicked.emit()

const HOVER_OFFSET := Vector2(0, -5)
func _on_mouse_entered():
	var tw := create_tween()
	tw.tween_property(mask, "position", HOVER_OFFSET, 0.1).set_trans(Tween.TRANS_CIRC)

func _on_mouse_exited():
	var tw := create_tween()
	tw.tween_property(mask, "position", Vector2.ZERO, 0.1).set_trans(Tween.TRANS_CIRC)
