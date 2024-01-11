class_name MessageEvent extends Node

@export var next_event : MessageEvent

func play():
	print("msg_event playing: " + name)
	await _play()
	if is_instance_valid(next_event):
		await next_event.play()

func _play():
	push_error("_play not implemented in " + self.get_script().get_path())
