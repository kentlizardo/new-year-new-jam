class_name Profile extends Draggable

@export var label : Label
@export var label_root : Node2D

var stamped := false
var profile_texture : Texture2D

func _init():
	add_to_group("profiles")

func _ready():
	super()
	label.text = name
	label.modulate.a = 0
	profile_texture = ResourceLoader.load(MessageParser.PROFILES_PATH + get_profile_id() + ".png")
	double_clicked.connect(popup)

func _process(delta):
	label_root.global_rotation = 0

func get_profile_id() -> String:
	return name.to_lower().replace(" ", "")

func popup():
	if profile_texture:
		var overlay := preload("res://scenes/game/overlay.tscn").instantiate() as Overlay
		overlay.profile_tex = profile_texture
		Workday.current.add_child(overlay)
	var tw := create_tween()
	tw.tween_property(label, "modulate:a", 1.0, 0.2).from(0.0).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
