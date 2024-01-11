extends MessageEvent

func _ready():
	linearize()

func linearize():
	var children := get_children()
	var length := children.size()
	for node in children:
		if node is MessageEvent:
			if node.next_event == null:
				var i := node.get_index()
				if (i + 1) <= length - 1:
					node.next_event = children[i + 1] as MessageEvent

func _play():
	await (get_children()[0] as MessageEvent).play()

