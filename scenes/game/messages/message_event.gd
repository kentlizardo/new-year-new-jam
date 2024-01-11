class_name MessageEvent extends Node

signal finished

@export var contact : Contact
@export var next_event : MessageEvent

var is_complete := false

func play():
	is_complete = false
	await _play()
	is_complete = true
	finished.emit()
	var successor := _get_next_event()
	if successor:
		successor.play()

func _get_next_event() -> MessageEvent:
	return next_event

func _play():
	push_error("_play not implemented in " + self.get_script().get_path())
