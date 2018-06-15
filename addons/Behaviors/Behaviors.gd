tool
extends EditorPlugin


func _enter_tree():
	# 230 - 73 - 78 (colora)
	# Initialization of the plugin goes here
	# Add the new type with a name, a parent type, a script and an icon
	add_custom_type("Behavior8Directions2D", "Node2D", preload("Behavior8Directions2D.gd"), preload("icon8.png"))
	add_custom_type("BehaviorFade2D", "Node2D", preload("BehaviorFade2D.gd"), preload("iconfade.png"))
	add_custom_type("BehaviorTakeItem2D", "Node2D", preload("BehaviorTakeItem2D.gd"), preload("icontakeitem.png"))
	add_custom_type("BehaviorLives2D", "Node2D", preload("BehaviorLives2D.gd"), preload("iconlives.png"))
	add_custom_type("BehaviorEvidence2D", "Position2D", preload("BehaviorEvidence2D.gd"), preload("iconevidence.png"))
	add_custom_type("BehaviorMoveTo2D", "Node2D", preload("BehaviorMoveTo2D.gd"), preload("iconmoveto.png"))

	add_custom_type("BehaviorScoreLabel", "Control", preload("BehaviorScoreLabel.gd"), preload("iconscorelabel.png"))

func _exit_tree():
	# Clean-up of the plugin goes here
	# Always remember to remove it from the engine when deactivated
	remove_custom_type("Behavior8Directions2D")
	remove_custom_type("BehaviorFade2D")
	remove_custom_type("BehaviorTakeItem2D")
	remove_custom_type("BehaviorLives2D")
	remove_custom_type("BehaviorEvidence2D")
	remove_custom_type("BehaviorMoveTo2D")
	
	remove_custom_type("BehaviorScoreLabel")
	