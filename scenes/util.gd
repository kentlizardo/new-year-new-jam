class_name Util extends Node

static func get_node_depth(node : Node) -> int:
	assert(node.is_inside_tree(), "Node has no depth if it's inside tree")
	var depth := 0
	var search := node.get_parent()
	while search:
		depth += 1
		search = search.get_parent()
	return depth
