class_name ChoiceRoot extends VBoxContainer

const BUBBLE_CHOICE_TEMPLATE = preload("res://scenes/game/bubble_choice.tscn")

signal choice_taken(choice : String)

func _ready():
	choice_taken.connect(destroy)

func destroy(choice):
	queue_free()

func setup(choices : Array):
	for i in choices:
		var bubble := BUBBLE_CHOICE_TEMPLATE.instantiate() as BubbleChoice
		bubble.setup(i)
		bubble.read()
		add_child(bubble)
		bubble.meta_clicked.connect(on_meta_clicked.bind(i))

func on_meta_clicked(meta : Variant, id : String):
	choice_taken.emit(id)
