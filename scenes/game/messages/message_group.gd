class_name MessageGroup extends MessageEvent

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

# This will double, since adding a new play() call will basically
# cause there to be 2 executions of a MessageEventTree
#func _play():
	#var children := get_children()
	#await children[0].play()

# Instead, repoint the next event call to be 
func _get_next_event() -> MessageEvent:
	return (get_children()[0] as MessageEvent)
