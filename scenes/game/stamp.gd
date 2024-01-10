extends Draggable

@export var stamp_top : Draggable
@export var spring : DampedSpringJoint2D

func _ready():
	super()
	stamp_top.drag_started.connect(start_stamp)
	stamp_top.drag_ended.connect(end_stamp)

func start_stamp():
	linear_damp = 500
	spring.stiffness = 1

func end_stamp():
	linear_damp = 5
	spring.stiffness = 40
