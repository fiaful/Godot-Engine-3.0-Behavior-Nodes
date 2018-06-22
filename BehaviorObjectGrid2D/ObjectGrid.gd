extends Node

onready var object_grid = $BehaviorObjectGrid2D

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func _on_RedimButton_pressed():
	object_grid.redim(5, 5)


func _on_object_pressed(which):
	print ("clicked on button at ", which.text)


# esempio in cui creo io gli oggetti da inserire
#func _on_new_cell_object(x, y):
#	var o = Button.new()
#	o.rect_size = Vector2(50, 50)
#
#	var object_grid = get_node("BehaviorObjectGrid2D")
#	object_grid.set_object_at_xy(x, y, o)
#
#	o.text = str(x) + "," + str(y)
#	o.connect("pressed", self, "_on_object_pressed", [o])


# esempio in cui gli oggetti vengono allocati dalla proprietà filler_object
func _on_new_cell_object(x, y):
	var object_grid = get_node("BehaviorObjectGrid2D")
	var o = object_grid.get_object_at_xy(x, y)
	var btn = o.get_node("Button")
	btn.text = str(x) + "," + str(y)
	btn.connect("pressed", self, "_on_object_pressed", [btn])


func _on_ToggleCursorVisibilityButton_toggled(button_pressed):
	var object_grid = get_node("BehaviorObjectGrid2D")
	object_grid.cursor_visible = button_pressed


func _on_HoleButton_pressed():
	var object_grid = get_node("BehaviorObjectGrid2D")
	var pos = object_grid.get_selected_position()
	var o = object_grid.get_object_at_xy(pos.x, pos.y)
	var btn = o.get_node("Button")
	if object_grid.get_cell_type_at_xy(pos.x, pos.y) == object_grid._HOLE:
		object_grid.set_cell_type_at_xy(pos.x, pos.y, object_grid._OBJECT)
		btn.text = str(pos.x) + "," + str(pos.y)
		btn.add_color_override("font_color", Color("dddddd"))
	else:
		object_grid.set_cell_type_at_xy(pos.x, pos.y, object_grid._HOLE)
		btn.text = "HOLE"
		btn.add_color_override("font_color", Color("000000"))
	


func _on_ObstacleButton_pressed():
	var object_grid = get_node("BehaviorObjectGrid2D")
	var pos = object_grid.get_selected_position()
	var o = object_grid.get_object_at_xy(pos.x, pos.y)
	var btn = o.get_node("Button")
	if object_grid.get_cell_type_at_xy(pos.x, pos.y) == object_grid._OBSTACLE:
		object_grid.set_cell_type_at_xy(pos.x, pos.y, object_grid._OBJECT)
		btn.text = str(pos.x) + "," + str(pos.y)
		btn.add_color_override("font_color", Color("dddddd"))
	else:
		object_grid.set_cell_type_at_xy(pos.x, pos.y, object_grid._OBSTACLE)
		btn.text = "OBST"
		btn.add_color_override("font_color", Color("993300"))


func _on_BehaviorObjectGrid2D_swipe(x_src, y_src, x_dst, y_dst):
	print ("swipe: ", x_src, " - ", y_src, " - ", x_dst, " - ", y_dst)


func _on_BehaviorObjectGrid2D_continuous_swipe(x_src, y_src, x_dst, y_dst):
	#print (x_src, " - ", y_src, " - ", x_dst, " - ", y_dst)
	var object_grid = get_node("BehaviorObjectGrid2D")
	object_grid.swap_object(x_src, y_src, x_dst, y_dst)
	object_grid.adjust_object_position_at_xy(x_src, y_src)
	object_grid.adjust_object_position_at_xy(x_dst, y_dst)


func _on_BehaviorObjectGrid2D_continuous_swipe_end():
	print ("end")
