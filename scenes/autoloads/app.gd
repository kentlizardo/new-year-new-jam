extends Node

var main_menu_scene : PackedScene = preload("res://scenes/stages/main_menu.tscn")

@onready var stage_root : Node = $/root/Root/StageRoot

var current_scene : Node

func _ready():
	stage(main_menu_scene)

func unstage() -> bool:
	if is_instance_valid(current_scene):
		current_scene.queue_free()
		return true
	return false

func stage(packed : PackedScene):
	unstage()
	current_scene = packed.instantiate()
	stage_root.add_child(current_scene)
