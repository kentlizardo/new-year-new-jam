class_name Workday extends Node

signal finished

static var current : Workday
static var faux_save : Dictionary = {}

@export var papers : Node2D
@export var finish_button : Button
@export var opening : Opening

var workday_load : Dictionary = {}
func _ready():
	if !faux_save.is_empty():
		workday_load = faux_save
		push_error("Should never reach here.")
	else:
		workday_load = DataManager.get_data().get_workday()
	if workday_load.is_empty():
		await opening.finished
		App.stage(load("res://scenes/stages/win.tscn"))
	else:
		load_workday(workday_load)
	finish_button.pressed.connect(finish_workday)

func save():
	pass
	#faux_save = workday_load

func save_and_quit():
	save()
	App.stage(load("res://scenes/stages/main_menu.tscn"))

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		$Pause.visible = !$Pause.visible
		if $Pause.visible:
			MessageView.current.unreveal()

var client_required := false:
	set(x):
		client_required = x
		check_progress()
var messages_queued := false:
	set(x):
		messages_queued = x
		check_progress()

func check_progress():
	if !client_required and !messages_queued:
		var tw := finish_button.create_tween()
		finish_button.visible = true
		tw.tween_property(finish_button, "modulate:a", 1.0, 0.2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
	else:
		var tw := finish_button.create_tween()
		tw.tween_property(finish_button, "modulate:a", 0.0, 0.2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
		tw.finished.connect(func(): finish_button.visible = false)

func load_workday(data : Dictionary):
	var packs : Array[PackedScene] = data["packs"]
	var dates : Array = data["dates"]
	for pack in packs:
		var items : Node = pack.instantiate()
		add_child(items)
		print("pack found: " + items.name)
	for date in dates:
		if date is String:
			var date_parser = MessageParser.new()
			date_parser.source = date
			add_child(date_parser)
			date_parser.play()
	organize()
	if ClientProfile.current != null:
		client_required = true
	if !MessageEvent.is_done():
		messages_queued = true
	App.submitted_to_client.connect(func(): client_required = false)
	App.message_events_done.connect(func(): messages_queued = false)

func finish_workday():
	MessageView.current.unreveal()
	if !client_required and !messages_queued:
		App.call_deferred("stage", load("res://scenes/stages/workday.tscn"))

func organize():
	for profile in get_tree().get_nodes_in_group("profiles"):
		profile.reparent(papers)
		var node_2d := profile as Node2D
		if node_2d:
			node_2d.global_position = papers.global_position + Vector2(randi_range(-200, 200), randi_range(-100, 100))
			node_2d.global_rotation_degrees = randf_range(-30, 30)
	if ClientProfile.current == null:
		Tray.current.queue_free()
