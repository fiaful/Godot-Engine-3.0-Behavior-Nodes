tool
extends Node

var _class_name = "BaseBehavior"

func check_class_name(name):
	return name == _class_name
	
func round6(num):
	return int(num * 1000000) / 1000000
	
func safe_timer(wait):
	return clamp(wait, 0.0001, 9999.9)

func get_node_by_path(path):
	var node = get_tree().get_root().get_node(path)
	if !node:
		if path.begins_with("/"):
			path.substr(1, path.length())
		node = get_tree().get_root().get_node(path)
	return node
