class_name Workday extends Node

static var current : Workday

@export var papers : Node2D

func _enter_tree():
	current = self

func _exit_tree():
	if current == self:
		current = null

func _ready():
	var packs : Array[PackedScene] = DataManager.get_data().get_workday()
	for pack in packs:
		var items : Node = pack.instantiate()
		add_child(items)
		print("pack found: " + items.name)
	organize()

func organize():
	for profile in get_tree().get_nodes_in_group("profiles"):
		var node_2d := profile as Node2D
		if node_2d:
			node_2d.global_position = papers.global_position
