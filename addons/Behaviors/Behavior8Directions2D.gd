tool
extends "res://addons/Behaviors/BaseBehavior.gd"

enum BEHAVIOR_8_DIRECTIONS { _UP_DOWN, _LEFT_RIGHT, _4_DIRECTIONS, _8_DIRECTIONS }
enum BEHAVIOR_8_DIRECTIONS_ANGLES { _NONE, _90_DEGREE_INTERVALS, _45_DEGREE_INTERVALS, _360_DEGREE_SMOOTH }

export var enabled = true
export var max_speed = 200
export var acceleration = 600
export var deceleration = 500
export(BEHAVIOR_8_DIRECTIONS) var directions = BEHAVIOR_8_DIRECTIONS._8_DIRECTIONS
export(BEHAVIOR_8_DIRECTIONS_ANGLES) var angles = BEHAVIOR_8_DIRECTIONS_ANGLES._360_DEGREE_SMOOTH
export var default_controls = true
export var control_left = "ui_left"
export var control_right = "ui_right"
export var control_up = "ui_up"
export var control_down = "ui_down"
export var solid_group_name = "SOLID"

var _parent = null

# Key states
var _upkey = false
var _downkey = false
var _leftkey = false
var _rightkey = false
var _ignore_input = false

# Simulated key states
var _simup = false
var _simdown = false
var _simleft = false
var _simright = false

# attempted workaround for sticky keys bug
var _lastuptick = -1
var _lastdowntick = -1
var _lastlefttick = -1
var _lastrighttick = -1

# Movement
var _dx = 0
var _dy = 0

var _oldx = 0
var _oldy = 0
var _oldangle = 0

###############################################
var _overlapping_areas
var _overlapping_bodies
var _candidates = []
###############################################

func _ready():
	_class_name = "Behavior8Directions2D"
	_parent = get_parent()
	_parent.connect("area_entered", self, "_on_area_entered")
	_parent.connect("body_entered", self, "_on_body_entered")
	
	set_process(false)
	set_physics_process(true)

func to_JSON():
	return {
		"dx": _dx,
		"dy": _dy,
		"enabled": enabled,
		"maxspeed": max_speed,
		"acc": acceleration,
		"dec": deceleration,
		"ignore": _ignore_input
	}
	
func from_JSON(o):
	_dx = o["dx"]
	_dy = o["dy"]
	enabled = o["enabled"]
	max_speed = o["maxspeed"]
	acceleration = o["acc"]
	deceleration = o["dec"]
	_ignore_input = o["ignore"]
	
	_upkey = false
	_downkey = false
	_leftkey = false
	_rightkey = false
	
	_simup = false
	_simdown = false
	_simleft = false
	_simright = false
	
	_lastuptick = -1
	_lastdowntick = -1
	_lastlefttick = -1
	_lastrighttick = -1

func _physics_process(delta):
	_process_input(delta)

	var left = _leftkey or _simleft
	var right = _rightkey or _simright
	var up = _upkey or _simup
	var down = _downkey or _simdown
	_simleft = false
	_simright = false
	_simup = false
	_simdown = false
	
	if !enabled:
		return
	
	var collobj
#	collobj = test_overlap_solid(_parent)
#	if collobj:
##		# this.runtime.registerCollision(this.inst, collobj);
#		if !push_out_solid_nearest(_parent, 10):
#			return		# must be stuck in solid
	
	# Ignoring input: ignore all keys
	if _ignore_input:
		left = false
		right = false
		up = false
		down = false
		
	# Up & down mode: ignore left & right keys
	if directions == BEHAVIOR_8_DIRECTIONS._UP_DOWN:
		left = false
		right = false
		
	# Left & right mode: ignore up & down keys
	elif directions == BEHAVIOR_8_DIRECTIONS._LEFT_RIGHT:
		up = false
		down = false
		
	# 4 directions mode: up/down take priority over left/right
	if directions == BEHAVIOR_8_DIRECTIONS._4_DIRECTIONS and (up or down):
		left = false
		right = false
		
	# Apply deceleration when no arrow key pressed, for each axis
	if left == right:	# both up or both down
		if _dx < 0:
			_dx += deceleration * delta
			
			if _dx > 0:
				_dx = 0
		elif _dx > 0:
			_dx -= deceleration * delta
			
			if _dx < 0:
				_dx = 0
		
	if up == down:
		if _dy < 0:
			_dy += deceleration * delta
			
			if _dy > 0:
				_dy = 0
		elif _dy > 0:
			_dy -= deceleration * delta
			
			if _dy < 0:
				_dy = 0
				
	# Apply acceleration
	if left and !right:
		# Moving in opposite direction to current motion: add deceleration
		if _dx > 0:
			_dx -= (acceleration + deceleration) * delta
		else:
			_dx -= acceleration * delta
	
	if right and !left:
		if _dx < 0:
			_dx += (acceleration + deceleration) * delta
		else:
			_dx += acceleration * delta
	
	if up and !down:
		if _dy > 0:
			_dy -= (acceleration + deceleration) * delta
		else:
			_dy -= acceleration * delta
	
	if down and !up:
		if _dy < 0:
			_dy += (acceleration + deceleration) * delta
		else:
			_dy += acceleration * delta
	
	var ax
	var ay

	if _dx != 0 or _dy != 0:
		# Limit to max speed
		var speed = sqrt(_dx * _dx + _dy * _dy)
		
		if speed > max_speed:
			# Limit vector magnitude to maxspeed
			var a = atan2(_dy, _dx)
			_dx = max_speed * cos(a)
			_dy = max_speed * sin(a)
		
		# Save old position and angle
		_oldx = _parent.global_position.x
		_oldy = _parent.global_position.y
		_oldangle = _parent.rotation_degrees
		
		# Attempt X movement
		_parent.global_position.x += _dx * delta
		
#		collobj = test_overlap_solid(_parent)
#		if collobj:
##			# Try to push back out horizontally for a closer fit to the obstacle.
#			if push_out_solid(_parent, 1 if _dx < 0 else -1, 0, abs(floor(_dx * delta))):
##				# Failed to push out: restore previous (known safe) position.
#				_parent.global_position.x = _oldx
##
#			_dx = 0;
##			#this.runtime.registerCollision(this.inst, collobj);
		
		_parent.global_position.y += _dy * delta
		
#		collobj = test_overlap_solid(_parent)
#		if collobj:
##			# Try to push back out vertically.
#			if push_out_solid(_parent, 0, 1 if _dy < 0 else -1, abs(floor(_dy * delta))):
##				# Failed to push out
#				_parent.global_position.y = _oldy
##
#			_dy = 0
##			#this.runtime.registerCollision(this.inst, collobj);
		
		ax = round6(_dx)
		ay = round6(_dy)
		
		# Apply angle so long as object is still moving and isn't entirely blocked by a solid
		if (ax != 0 or ay != 0): # and is_roteable
			if angles == BEHAVIOR_8_DIRECTIONS_ANGLES._90_DEGREE_INTERVALS:
				_parent.rotation_degrees = (round(to_degrees(atan2(ay, ax)) / 90.0) * 90.0)
			elif angles == BEHAVIOR_8_DIRECTIONS_ANGLES._45_DEGREE_INTERVALS:
				_parent.rotation_degrees = (round(to_degrees(atan2(ay, ax)) / 45.0) * 45.0)
			elif angles == BEHAVIOR_8_DIRECTIONS_ANGLES._360_DEGREE_SMOOTH:
				_parent.rotation_degrees = round(to_degrees(atan2(ay, ax)))
			
#		if _parent.rotation_degrees != oldangle:
#			collobj = test_overlap_solid(_parent)
#			if collobj:
#				_parent.rotation_degrees = oldangle
#				#this.runtime.registerCollision(this.inst, collobj);
	_candidates.clear()
	
	
func _process_input(delta):
	#var tick_count = delta
	if Input.is_action_pressed(control_left):# and _lastlefttick < tick_count:
		_leftkey = true
	if Input.is_action_pressed(control_right):# and _lastrighttick < tick_count:
		_rightkey = true
	if Input.is_action_pressed(control_up):# and _lastuptick < tick_count:
		_upkey = true
	if Input.is_action_pressed(control_down):# and _lastdowntick < tick_count:
		_downkey = true
	if Input.is_action_just_released(control_left):
		_leftkey = false
		#_lastlefttick = tick_count
	if Input.is_action_just_released(control_right):
		_rightkey = false
		#_lastrighttick = tick_count
	if Input.is_action_just_released(control_up):
		_upkey = false
		#_lastuptick = tick_count
	if Input.is_action_just_released(control_down):
		_downkey = false
		#_lastdowntick = tick_count

func _on_area_entered(area):
	if area.is_in_group(solid_group_name):
		_candidates.append(area)
		push_out_solid_nearest(_parent, 10)
		_dx = 0
		_dy = 0
		
func _on_body_entered(body):
	if body.is_in_group(solid_group_name):
		_candidates.append(body)
		push_out_solid_nearest(_parent, 10)
		_dx = 0
		_dy = 0

func stop():
	pass
	
func reverse():
	pass

func set_ignoring_input():
	pass
	
func set_speed():
	pass
	
func set_max_speed():
	pass
	
func set_acceleration():
	pass
	
func set_deceleration():
	pass
	
func simulate_control():
	pass
	
func set_enabled():
	pass
	
func set_vector_x():
	pass
	
func set_vector_y():
	pass
	
func set_vector():
	pass
	
func get_speed():
	pass
	
func get_max_speed():
	pass
	
func get_acceleration():
	pass
	
func get_deceleration():
	pass
	
func get_angle_of_motion():
	pass
	
func get_vector_x():
	pass
	
func get_vector_y():
	pass
	
func get_vector():
	pass
	
##########################################

func test_overlap(a, b):
	var ret = false
	if "overlaps_area" in a:
		ret = ret or a.overlaps_area(b)
	if "overlaps_body" in a:
		ret = ret or a.overlaps_body(b)
	return ret
	
##########################################

func test_overlap_solid(inst):
	if _candidates.size() <= 0:
		return null
	return _candidates[0]	

##########################################

func push_out_solid_nearest(inst, max_dist_):
	var _parent = get_parent()
	# Find nearest position not overlapping a solid
	var max_dist = 100 if max_dist_ <= 0 else max_dist_
	var dist = 0
	var oldx = _parent.global_position.x
	var oldy = _parent.global_position.y

	var dir = 0
	var dx = 0
	var dy = 0
	var last_overlapped = test_overlap_solid(_parent)
	
	if !last_overlapped:
		return true
			
	# 8-direction spiral scan
	while dist <= max_dist:
		print (dist)
		if dir == 0:
			dx = 0
			dy = -1
			dist += 1
		elif dir == 1:
			dx = 1
			dy = -1
		elif dir == 2:
			dx = 1
			dy = 0
		elif dir == 3:
			dx = 1
			dy = 1
		elif dir == 4:
			dx = 0
			dy = 1
		elif dir == 5:
			dx = -1
			dy = 1
		elif dir == 6:
			dx = -1
			dy = 0
		elif dir == 7:
			dx = -1
			dy = -1
		
		dir = (dir + 1) % 8
		
		_parent.global_position = Vector2(floor(oldx + (dx * dist)), floor(oldy + (dy * dist)))
		
		# Test if we've cleared the last instance we were overlapping
		if "overlaps_area" in _parent:
			if !_parent.overlaps_area(last_overlapped):
				last_overlapped = null
		elif "overlaps_body" in _parent:
			if !_parent.operlaps_body(last_overlapped):
				last_overlapped = null
			
		if !last_overlapped:
			return true

	# Didn't get pushed out: restore old position and return false
	_parent.global_position = Vector2(oldx, oldy)
	return false

##########################################

func push_out_solid(inst, xdir, ydir, dist, include_jumpthrus, specific_jumpthru):
	print ("a")
	# Push to try and move out of solid.  Pass -1, 0 or 1 for xdir and ydir to specify a push direction.
	var push_dist = dist or 50

	var oldx = inst.global_position.x
	var oldy = inst.global_position.y;

	var i
	var last_overlapped = null
	var secondlast_overlapped = null

	for i in range(0, push_dist):
		
		inst.global_position = Vector2(oldx + (xdir * i), oldy + (ydir * i))
		
		# Test if we've cleared the last instance we were overlapping
		if !test_overlap(inst, last_overlapped):
			# See if we're still overlapping a different solid
			last_overlapped = test_overlap_solid(inst)
			
			if last_overlapped:
				secondlast_overlapped = last_overlapped
			
			# We're clear of all solids - check jumpthrus
			if !last_overlapped:

				if (include_jumpthrus):
					if (specific_jumpthru):
						last_overlapped = specific_jumpthru if test_overlap(inst, specific_jumpthru) else null
					else:
						last_overlapped = test_overlap_jump_thru(inst)
						
					if last_overlapped:
						secondlast_overlapped = last_overlapped
				
				# Clear of both - completed push out.  Adjust fractionally to 1/16th of a pixel.
				if !last_overlapped:
					if secondlast_overlapped:
						push_in_fractional(inst, xdir, ydir, secondlast_overlapped, 16)
					
					return true

	# Didn't get out a solid: oops, we're stuck.
	# Restore old position.
	inst.global_position = Vector2(oldx, oldy)
	return false

##########################################

func to_degrees(x):
	return x * (180.0 / PI)

func to_clamped_radians(x):
	return clamp_angle(to_radians(x))
	
func clamp_angle(a):
	# Clamp in radians
	var p = a % (2 * PI)       # now in (-2pi, 2pi) range
	if p < 0:
		p += 2 * PI   # now in [0, 2pi) range
	return p

func to_radians(x):
	return x / (180.0 / PI)

func clamp_angle_degrees(a):
	# Clamp in degrees
	a = a % 360       # now in (-360, 360) range

	if a < 0:
		a += 360   # now in [0, 360) range

	return a
	
##########################################


func test_overlap_jump_thru(inst):
	pass
	
func push_in_fractional(a, b, c, d, e):
	pass