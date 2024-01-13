extends Node

# No static signal support so using Singleton to store
signal message_events_done
signal message_events_added

signal submitted_to_client

var main_menu_scene : PackedScene = preload("res://scenes/stages/main_menu.tscn")

@onready var stage_root : Node = $/root/Root/StageRoot
@onready var msg_root = $/root/Root/MessageViewRoot
var current_scene : Node

func _ready():
	if OS.has_feature("editor"):
		MessageParser.register_resources()
	stage(main_menu_scene)

func _process(delta):
	if stage_queue.size() > 0:
		var scene := stage_queue.pop_front() as PackedScene
		_stage(scene)

func stage(packed : PackedScene):
	if !stage_queue.has(packed):
		stage_queue.append(packed)
var stage_queue : Array[PackedScene] = []

func _stage(packed : PackedScene):
	if is_instance_valid(current_scene):
		current_scene.call_deferred("free")
		await current_scene.tree_exited
	current_scene = packed.instantiate()
	if current_scene is Workday:
		Workday.current = current_scene
	stage_root.call_deferred("add_child",current_scene)
