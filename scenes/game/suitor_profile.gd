class_name SuitorProfile extends Profile

@export_file var first_date_source
@export var label : Label
@export var label_root : Node2D

func _ready():
	super()
	label.text = name

func _process(delta):
	label_root.global_rotation = 0
