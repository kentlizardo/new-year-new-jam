extends VSlider

var bus_id := -1
# Called when the node enters the scene tree for the first time.
func _ready():
	bus_id = AudioServer.get_bus_index("Master")
	await get_tree().process_frame
	value = 5


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_value_changed(value):
	AudioServer.set_bus_volume_db(bus_id, linear_to_db(value * 0.01))
