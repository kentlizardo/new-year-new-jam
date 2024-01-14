class_name MessageEvent extends Node

static var active_events : Array[MessageEvent] = []
static func is_done() -> bool:
	return active_events.size() == 0
static func assure_done():
	if !is_done():
		await App.message_events_done

signal finished

@export var contact : Contact
@export var next_event : MessageEvent

var is_complete := false

func play():
	if active_events.has(self):
		await finished
	active_events.append(self)
	is_complete = false
	await _play()
	is_complete = true
	var successor := _get_next_event()
	if successor:
		successor.play()
	# should be after successor so we do not emit message_events_done in App prematurely
	var i := active_events.find(self)
	active_events.remove_at(i)
	if active_events.size() == 0:
		App.message_events_done.emit()
	finished.emit()

func _get_next_event() -> MessageEvent:
	return next_event

func _play():
	push_error("_play not implemented in " + self.get_script().get_path())
