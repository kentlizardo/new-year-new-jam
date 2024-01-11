class_name MessageEvent extends Node

signal finished

@export var contact : Contact
@export var next_event : MessageEvent

var is_complete := false

func play():
	is_complete = false
	print("msg_event playing: " + name)
	if next_event:
		print("  with next: " + next_event.name)
	await _play()
	is_complete = true
	finished.emit()
	if next_event:
		next_event.play()

func _play():
	push_error("_play not implemented in " + self.get_script().get_path())
