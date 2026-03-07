extends Node


func get_node_path(node: Node) -> String:
	var names: Array[String] = []
	var current_node = node
	while current_node and current_node.has_method("get_name"):
		names.append(current_node.get_name())
		current_node = current_node.get_parent()
	names.reverse()
	return "->".join(names)
