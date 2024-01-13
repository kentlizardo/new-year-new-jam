class_name SuitorProfile extends Profile

@export var label : Label
@export var label_root : Node2D

var profile_texture : Texture2D

func _ready():
	super()
	label.text = name
	profile_texture = ResourceLoader.load(MessageParser.PROFILES_PATH + get_suitor_id() + ".png")
	print(null)
	double_clicked.connect(popup)

func _process(delta):
	label_root.global_rotation = 0

func get_suitor_id() -> String:
	return name.to_lower().replace(" ", "")

func popup():
	if profile_texture:
		var overlay := preload("res://scenes/game/overlay.tscn").instantiate() as Overlay
		overlay.profile_tex = profile_texture
