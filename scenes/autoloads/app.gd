extends Node

# No static signal support so using Singleton to store
signal message_events_done

var main_menu_scene : PackedScene = preload("res://scenes/stages/main_menu.tscn")

@onready var stage_root : Node = $/root/Root/StageRoot

var current_scene : Node

func _ready():
	stage(main_menu_scene)

func stage(packed : PackedScene):
	if is_instance_valid(current_scene):
		current_scene.call_deferred("free")
		await current_scene.tree_exited
	_stage(packed)
func _stage(packed : PackedScene):
	current_scene = packed.instantiate()
	if current_scene is Workday:
		Workday.current = current_scene
	stage_root.call_deferred("add_child",current_scene)
