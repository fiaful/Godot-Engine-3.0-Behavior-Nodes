extends Node

onready var dir8 = $Player/Behavior8Directions2D
onready var mover = $MoveToTest/BehaviorMoveTo2D
onready var swapper = $BehaviorSwap2D

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func _input(event):
	if event.is_pressed():
		# mover.start()
		swapper.start()