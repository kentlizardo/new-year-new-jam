class_name Workday extends Node

static var current : Workday

@export var papers : Node2D

func _enter_tree():
	current = self

func _exit_tree():
	if current == self:
		current = null

static var faux_save : Dictionary = {}

var workday_load : Dictionary = {}
func _ready():
	if !faux_save.is_empty():
		workday_load = faux_save
	else:
		workday_load = DataManager.get_data().get_workday()
	load_workday(workday_load)

func save():
	faux_save = workday_load

func save_and_quit():
	save()
	App.stage(load("res://scenes/stages/main_menu.tscn"))

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		$Pause.show()

func load_workday(data : Dictionary):
	var packs : Array[PackedScene] = data["packs"]
	var dates : Array = data["dates"]
	print(packs)
	print(dates)
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

func organize():
	for profile in get_tree().get_nodes_in_group("profiles"):
		profile.reparent(papers)
		var node_2d := profile as Node2D
		if node_2d:
			node_2d.global_position = papers.global_position + Vector2(randi_range(-200, 200), randi_range(-100, 100))
