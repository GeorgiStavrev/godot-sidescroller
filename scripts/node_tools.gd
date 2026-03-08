extends Node


func get_node_path(node: Node) -> String:
	var names: Array[String] = []
	var current_node = node
	while current_node and current_node.has_method("get_name"):
		names.append(current_node.get_name())
		current_node = current_node.get_parent()
	names.reverse()
	return "->".join(names)


func get_ancestor_by_class(node: Node, target_class: Object) -> Node:
	var curr = node.get_parent()
	while curr != null:
		if is_instance_of(curr, target_class):
			return curr
		curr = curr.get_parent()
	return null
