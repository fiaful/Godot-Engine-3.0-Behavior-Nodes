###[ INFO ]######################################################################################################

# Component: BehaviorSwap2D
# Author: Francesco Iafulli (fiaful)
# Version: 1.0
# Last modify: 2018-06-15

# Requirements:
#	- both object to swap have to contains BehaviorMoveTo2D child
#	- is possibile to indicate BehaviorMoveTo2D child directly (useful if node has more BehaviorMoveTo2D nodes)
#	see also BehaviorMoveTo2D requirements

# Changelog:
#
#

###[ BEGIN ]#####################################################################################################

extends "res://addons/Behaviors/BaseBehavior.gd"

###[ EXPORTED VARIABLES ]########################################################################################

# define the first object to move (behavior parent or another object)
enum BEHAVIOR_SWAP_OBJECT { _PARENT, _ANOTHER_OBJECT }

# behavior is enabled or not
export var enabled = true

# behavior auto start at ready
export var active_at_start = false

# define the first object to move (behavior parent or another object). default is parent
export(BEHAVIOR_SWAP_OBJECT) var first_object_type = BEHAVIOR_SWAP_OBJECT._PARENT

# if first object type is another object, this indicates the node path of first object
export(NodePath) var first_object

# this indicates the node path of object to swap to
export(NodePath) var second_object

# define if behavior have to be automatically destroyed ad the end of swap (for example, if first object type is
# another object and its destroy at end is true, swaaping object will be destroyed at the end of swap, but behavior 
# node if it is not child of destroyed object... by this set to true, behavior will be always destroyed)
export var destroy_behavior = false

###[ SIGNALS ]###################################################################################################

# signal emitted when swap starts
signal swap_start

# signal emitted when call start and previous swap is not completed
signal swap_interrupted

# signal emitted when swap is completed
signal swap_finish

###[ PRIVATE VARIABLES ]########################################################################################

# first BehaviorMoveTo2D object to move
var _first_object = null

# second BehaviorMoveTo2D object to move
var _second_object = null

# state (moving or not)
var _swapping = false

# counts number of terminated movement
var _ending_count = 0

###[ METHODS ]###################################################################################################

func _ready():
	_class_name = "BehaviorSwap2D"
	_swapping = false
	
	# if active_at_start is true, start swap as soon as possible
	if active_at_start:
		call_deferred("start")

# returns if swap is in progress or not
func is_swapping():
	return _swapping

# starts the swap
func start():
	# only is behavior is enabled
	if !enabled:
		return 

	# if a swap is in progress, stop previous swap
	if _swapping:
		stop()

	var o = get_parent()
	if first_object_type == BEHAVIOR_SWAP_OBJECT._ANOTHER_OBJECT and first_object != "":
		o = get_node(first_object)
		
	_first_object = _search_child_by_classname(o, "BehaviorMoveTo2D")

	if second_object != "":
		o = get_node(second_object)
	else:
		o = null
		
	_second_object = _search_child_by_classname(o, "BehaviorMoveTo2D")
	
	# if there isn't a valid object to move, quit
	if !_first_object or !_second_object:
		return
	
	_set_commons(_first_object)
	_set_commons(_second_object)
	
	_first_object.target_object = _second_object.get_target_object_path()
	_second_object.target_object = _first_object.get_target_object_path()

	_first_object.start()
	_second_object.start()

	# then the movement is started and we can communicate it
	_swapping = true
	emit_signal("swap_start")

func _set_commons(o):
	if !o.is_connected("move_finish", self, "_on_move_finish"):
		o.connect("move_finish", self, "_on_move_finish")
	o.enabled = true
	o.move_target = o._ANOTHER_OBJECT
	o.relative = false

# stop the current swap
func stop():

	# if a swap is in progress		
	if _swapping:
		if _first_object:
			_first_object.stop()
		if _second_object:
			_second_object.stop()
		_ending_count = 0
		emit_signal("swap_interrupted")
		_swapping = false
		# finally destroy behavior, if destroy_behavior is true
		if destroy_behavior:
			queue_free()

# the Tween is completed successfull
func _on_move_finish():
	# increment _ending_count
	_ending_count += 1
	# communicate the finish
	if _ending_count > 1:
		emit_signal("swap_finish")
		_swapping = false
		# finally destroy behavior, if destroy_behavior is true
		if destroy_behavior:
			queue_free()
	
###[ END ]#######################################################################################################
