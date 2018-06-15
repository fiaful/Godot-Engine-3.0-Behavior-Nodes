###[ INFO ]######################################################################################################

# Component: BehaviorMoveTo2D
# Author: Francesco Iafulli (fiaful)
# Version: 1.0
# Last modify: 2018-06-15

# Requirements:
# 	- for object mode = parent, parent have to be Node2D (or derivate) or Control (or derivate)
# 	- for object mode = another object, parent can be any, object to move have to be Node2D (or derivate) or 
#		Control (or derivate)
# 	- for move target = another object, target object have to be Node2D (or derivate) or Control (or derivate)

# Changelog:
#
#

###[ BEGIN ]#####################################################################################################

extends "res://addons/Behaviors/BaseBehavior.gd"

###[ EXPORTED VARIABLES ]########################################################################################

# define the object to move (behavior parent or another object)
enum BEHAVIOR_MOVE_TO_OBJECT { _PARENT, _ANOTHER_OBJECT }

# define the target of movement
enum BEHAVIOR_MOVE_TO_TARGET { _FIXED_POSITION, _ANOTHER_OBJECT_POSITION, _MOUSE_POSITION }

# define the transition type (same as Tween object transition type)
enum BEHAVIOR_MOVE_TO_TRANSITION_TYPE { _TRANS_LINEAR, _TRANS_SINE, _TRANS_QUINT, _TRANS_QUART, _TRANS_QUAD, _TRANS_EXPO, _TRANS_ELASTIC, _TRANS_CUBIC, _TRANS_CIRC, _TRANS_BOUNCE, _TRANS_BACK }

# define the ease tyoe (same as Tween object ease type)
enum BEHAVIOR_MOVE_TO_EASE_TYPE { _EASE_IN, _EASE_OUT, _EASE_IN_OUT, _EASE_OUT_IN }

# behavior is enabled or not
export var enabled = true

# behavior auto start at ready
export var active_at_start = false

# define the object to move (behavior parent or another object). default is parent
export(BEHAVIOR_MOVE_TO_OBJECT) var object_mode = BEHAVIOR_MOVE_TO_OBJECT._PARENT

# define the target of movement. default is fixed position
export(BEHAVIOR_MOVE_TO_TARGET) var move_target = BEHAVIOR_MOVE_TO_TARGET._FIXED_POSITION

# if target of movement is fixed position, this is the fixed position
export(Vector2) var end_position = Vector2(0, 0)

# define if end position have to be consider as offset (relative) of start position
export var relative = false

# if object mode is another object, this indicates the node path of object to move
export(NodePath) var object_to_move

# if target ov movement is another object, this indicates the node path of target object
export(NodePath) var target_object

# define if moving object have to be automatically destroyed at the end of movement
export var destroy_at_end = false

# define if behavior have to be automatically destroyed ad the end of movement (for example, if object mode is
# another object and destroy at end is true, moving object will be destroyed at the end of movement, but behavior node
# if it is not child of destroyed object... by this set to true, behavior will be always destroyed)
export var destroy_behavior = false

# define duration of movement (in seconds)
export var duration = 1.0

# define the tween transition type (see transition type of Tween object). default is linear
export(BEHAVIOR_MOVE_TO_TRANSITION_TYPE) var trans_type = BEHAVIOR_MOVE_TO_TRANSITION_TYPE._TRANS_LINEAR

# define the tween ease type (see ease type of Tween object). default is in
export(BEHAVIOR_MOVE_TO_EASE_TYPE) var ease_type = BEHAVIOR_MOVE_TO_EASE_TYPE._EASE_IN

# define a delay (in seconds) between start command and real start movement. very useful with active at start.
export var delay = 0.0

###[ SIGNALS ]###################################################################################################

# signal emitted when movement starts
signal move_start

# signal emitted when call start and previous movement is not completed
signal move_interrupted

# signal emitted when movement is completed
signal move_finish

###[ PRIVATE VARIABLES ]########################################################################################

# object to move
var _object = null

# internal Tween object for moving
var _tween = null

# state (moving or not)
var _moving = false

# start object position
var _start_pos = Vector2()

# end object position
var _end_pos = Vector2()

# property name (because some object has global_position property and others has rect_global_position property)
var _propname = ""

###[ METHODS ]###################################################################################################

func _ready():
	_class_name = "BehaviorMoveTo2D"
	_moving = false
	
	# if active_at_start is true, start movement as soon as possible
	if active_at_start:
		call_deferred("start")

# returns if movement is in progress or not
func is_moving():
	return _moving

# starts the movement
func start():
	# only is behavior is enabled
	if !enabled:
		return 

	# if a movement is in progress, stop previous movement		
	if _moving:
		stop()

	# define in _object the object to move (parent or another object stored in object_to_move)
	if object_mode == BEHAVIOR_MOVE_TO_OBJECT._PARENT:
		_object = get_parent()
	else:
		if object_to_move:
			_object = get_node(object_to_move)
		else:
			_object = null
	
	# if there isn't a valid object to move, quit
	if !_object:
		return
	
	# retrieve the object start position
	if "global_position" in _object:
		_propname = "global_position"
		_start_pos = _object.global_position
	elif "rect_global_position" in _object:
		_propname = "rect_global_position"
		_start_pos = _object.rect_global_position
	else:
		_propname = ""
		_start_pos = Vector2(0, 0)

	# define end position by move_target
	if move_target == BEHAVIOR_MOVE_TO_TARGET._ANOTHER_OBJECT_POSITION:
		var o = get_node(target_object)
		
		# retrieve the target object position
		if "global_position" in o:
			_end_pos = o.global_position
		elif "rect_global_position" in o:
			_end_pos = o.rect_global_position
		else:
			_end_pos = Vector2(0, 0)
			
		_end_pos = o.get_global_position()
	elif move_target == BEHAVIOR_MOVE_TO_TARGET._MOUSE_POSITION:
		# retrieve the mouse position
		_end_pos = get_viewport().get_mouse_position()
	else:
		# end position is fixed
		_end_pos = end_position

	# adjust end position is this have to be relative
	if relative:
		_end_pos = _start_pos + _end_pos

	# then create a new tween object to perform the movement
	_tween = Tween.new()
	_tween.connect("tween_completed", self, "_on_tween_completed")
	add_child(_tween)
	
	_tween.interpolate_property(_object, _propname, _start_pos, _end_pos, duration, trans_type, ease_type, delay)	
	_tween.start()

	# then the movement is started and we can communicate it
	_moving = true
	emit_signal("move_start")

# stop the current movement
func stop():

	# if a movement is in progress		
	if _moving:
		_tween.stop(_object, _propname)
		# communicate the interruption
		emit_signal("move_interrupted")
		_moving = false
		_destroy()

# the Tween is completed successfull
func _on_tween_completed (object, key):
	# communicate the finish
	emit_signal("move_finish")
	_moving = false
	_destroy()

# destroy all object to destroy
func _destroy():
	# destroy _object if destroy_at_end is true
	if destroy_at_end:
		_object.queue_free()
		object_to_move = null
	else:
		# or simply destroy the Tween child (so a new Tween child can be create to next start request)
		_tween.queue_free()
	# finally destroy behavior also, if destroy_behavior is true
	if destroy_behavior:
		queue_free()
	
###[ END ]#######################################################################################################
