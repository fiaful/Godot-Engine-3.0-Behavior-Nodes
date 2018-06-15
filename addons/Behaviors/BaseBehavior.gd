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

# search a child of type class_name in object o
func _search_child_by_classname(o, class_name):
	# if base object is invalid returns null
	if !o:
		return null
	# if base object is of type class_name returns base object
	if o.has_method("check_class_name") and o.check_class_name(class_name):
		return o
	# searching start
	for n in o.get_children():
		# found: returns n
		if n.has_method("check_class_name") and n.check_class_name(class_name):
			return n
	# not found: returns null
	return null
	