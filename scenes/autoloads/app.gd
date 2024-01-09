extends Node

var starting_scene : PackedScene = preload("res://scenes/main_menu.tscn")

@onready var root : Node = $/root/Root

var current_scene : Node

func _ready():
	stage(starting_scene)

func unstage() -> bool:
	if is_instance_valid(current_scene):
		current_scene.queue_free()
		return true
	return false

func stage(packed : PackedScene):
	unstage()
	current_scene = packed.instantiate()
	root.add_child(current_scene)
