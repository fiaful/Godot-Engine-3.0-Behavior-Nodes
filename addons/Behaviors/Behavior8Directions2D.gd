extends "res://addons/Behaviors/BaseBehavior.gd"

const to_deg = (180.0 / PI)

enum BEHAVIOR_8_DIRECTIONS { _UP_DOWN, _LEFT_RIGHT, _4_DIRECTIONS, _8_DIRECTIONS }
enum BEHAVIOR_8_DIRECTIONS_ANGLES { _NONE, _90_DEGREE_INTERVALS, _45_DEGREE_INTERVALS, _360_DEGREE_SMOOTH }
enum BEHAVIOR_8_DIRECTIONS_MOVE_TYPE { _SLIDE, _COLLIDE }

export var enabled = true
export var max_speed = 200
export var acceleration = 600
export var deceleration = 500
export(BEHAVIOR_8_DIRECTIONS) var directions = BEHAVIOR_8_DIRECTIONS._8_DIRECTIONS
export(BEHAVIOR_8_DIRECTIONS_ANGLES) var angles = BEHAVIOR_8_DIRECTIONS_ANGLES._360_DEGREE_SMOOTH
export(BEHAVIOR_8_DIRECTIONS_MOVE_TYPE) var move_type = BEHAVIOR_8_DIRECTIONS_MOVE_TYPE._SLIDE
export var auto_mirror = true			# funziona solo se directions = _LEFT_RIGHT e angles = _NONE
export var default_controls = true
export var control_left = "ui_left"
export var control_right = "ui_right"
export var control_up = "ui_up"
export var control_down = "ui_down"

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

var _orient_left = false

var current_velocity = Vector2()
var current_direction = Vector2()
var left = false
var right = false
var up = false
var down = false

func _ready():
	_class_name = "Behavior8Directions2D"
	_parent = get_parent()
	_parent.rotation_degrees = 0
	set_process(false)
	set_physics_process(true)

func to_JSON():
	return {
		"enabled": enabled,
		"maxspeed": max_speed,
		"acc": acceleration,
		"dec": deceleration,
		"ignore": _ignore_input,
		"dir": directions,
		"angles": angles,
		"movetype": move_type,
		"curvel": current_velocity,
		"curdir": current_direction,
		"left": left,
		"right": right,
		"up": up,
		"down": down
	}
	
func from_JSON(o):
	enabled = o["enabled"]
	max_speed = o["maxspeed"]
	acceleration = o["acc"]
	deceleration = o["dec"]
	_ignore_input = o["ignore"]
	directions = o["dir"]
	angles = o["angles"]
	move_type = o["movetype"]
	current_velocity = o["curvel"]
	current_direction = o["curdir"]
	left = o["left"]
	right = o["right"]
	up = o["up"]
	down = o["down"]
	
	_upkey = false
	_downkey = false
	_leftkey = false
	_rightkey = false
	
	_simup = false
	_simdown = false
	_simleft = false
	_simright = false
	
#func _process(delta):
func _physics_process(delta):
	if !enabled:
		return
		
	_process_input()
	_filter_directions()
	var coll
	if move_type == BEHAVIOR_8_DIRECTIONS_MOVE_TYPE._SLIDE:
		var v = _set_velocity_and_direction()
		current_velocity = _parent.move_and_slide(v)
	else:
		var v = _set_velocity_and_direction() * delta
		coll = _parent.move_and_collide(v)
		if coll:
			current_velocity = Vector2(0, 0)
	_rotate()

	
func _process_input():
	if Input.is_action_pressed(control_left):
		_leftkey = true
	if Input.is_action_pressed(control_right):
		_rightkey = true
		
	if Input.is_action_pressed(control_up):
		_upkey = true
	if Input.is_action_pressed(control_down):
		_downkey = true
		
	if Input.is_action_just_released(control_left):
		_leftkey = false
	if Input.is_action_just_released(control_right):
		_rightkey = false
		
	if Input.is_action_just_released(control_up):
		_upkey = false
	if Input.is_action_just_released(control_down):
		_downkey = false
		
	left = _leftkey or _simleft
	right = _rightkey or _simright
	up = _upkey or _simup
	down = _downkey or _simdown
	_simleft = false
	_simright = false
	_simup = false
	_simdown = false
		
	# Ignoring input: ignore all keys
	if _ignore_input:
		left = false
		right = false
		up = false
		down = false

#	print (left, " ", right, " ", up, " ", down)

func _filter_directions():
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

func _set_velocity_and_direction():
	# asse X
	if left == right:								# se entrambi i comandi sinistra e destra sono attivi o disattivi
													# vuol dire che mi devo fermare. quindi:
		if current_velocity.x > 0:					# se sto andando verso destra ( > 0 )
			current_velocity.x -= deceleration		# devo decelerare (decrementando)
			if current_velocity.x < 0:				# fino a fermarmi
				current_velocity.x = 0
				
		elif current_velocity.x < 0:				# se sto andando verso sinistra ( < 0 )
			current_velocity.x += deceleration		# devo decelerare (incrementando)
			if current_velocity.x > 0:				# fino a fermarmi
				current_velocity.x = 0
				
	elif left and !right:							# voglio andare a sinistra

		if current_velocity.x > 0:					# se stavo andando a destra
			current_direction.x = 1
			current_velocity.x -= deceleration + acceleration		# devo decelerare
			if current_velocity.x < 0:
				current_direction.x = -1
		else:
			_mirror()
			current_direction.x = -1
			current_velocity.x -= acceleration		# e quando arrivo a 0 iniziare ad accelerare
			if current_velocity.x < -max_speed:
				current_velocity.x = -max_speed		# però non posso accelerare oltre la velocità massima
				
	elif !left and right:							# voglio andare a destra

		if current_velocity.x < 0:					# se stavo andando a sinistra
			current_direction.x = -1
			current_velocity.x += deceleration + acceleration		# devo decelerare
			if current_velocity.x > 0:
				current_direction.x = 1
		else:
			_mirror_back()
			current_direction.x = 1
			current_velocity.x += acceleration		# e quando arrivo a 0 iniziare ad accelerare
			if current_velocity.x > max_speed:
				current_velocity.x = max_speed		# però non posso accelerare oltre la velocità massima
		
	if current_velocity.x == 0:
		current_direction.x = 0
		
	# stessa cosa per l'asse Y
	if up == down:								# se entrambi i comandi su e giù sono attivi o disattivi
													# vuol dire che mi devo fermare. quindi:
		if current_velocity.y > 0:					# se sto andando verso su ( > 0 )
			current_velocity.y -= deceleration		# devo decelerare (decrementando)
			if current_velocity.y < 0:				# fino a fermarmi
				current_velocity.y = 0
				
		elif current_velocity.y < 0:				# se sto andando verso giù ( < 0 )
			current_velocity.y += deceleration		# devo decelerare (incrementando)
			if current_velocity.y > 0:				# fino a fermarmi
				current_velocity.y = 0
			
	elif up and !down:							# voglio andare su

		if current_velocity.y > 0:					# se stavo andando giù
			current_direction.y = 1
			current_velocity.y -= deceleration + acceleration		# devo decelerare
			if current_velocity.y < 0:
				current_direction.y = -1
		else:
			current_direction.y = -1
			current_velocity.y -= acceleration		# e quando arrivo a 0 iniziare ad accelerare
			if current_velocity.y < -max_speed:
				current_velocity.y = -max_speed		# però non posso accelerare oltre la velocità massima
				
	elif !up and down:							# voglio andare giù

		if current_velocity.y < 0:					# se stavo andando su
			current_direction.y = -1
			current_velocity.y += deceleration + acceleration		# devo decelerare
			if current_velocity.y > 0:
				current_direction.y = 1
		else:
			current_direction.y = 1
			current_velocity.y += acceleration		# e quando arrivo a 0 iniziare ad accelerare
			if current_velocity.y > max_speed:
				current_velocity.y = max_speed		# però non posso accelerare oltre la velocità massima

	if current_velocity.y == 0:
		current_direction.y = 0

	if current_velocity.x != 0 or current_velocity.y != 0:
		# Limit to max speed
		var speed = sqrt(current_velocity.x * current_velocity.x + current_velocity.y * current_velocity.y)

		if speed > max_speed:
			# Limit vector magnitude to maxspeed
			var a = atan2(current_velocity.y, current_velocity.x)
			current_velocity.x = max_speed * cos(a)
			current_velocity.y = max_speed * sin(a)

	# restituisco un vettore dato dalla direzione normalizzata moltiplicato i valori assoluti delle velocità

	return current_direction.normalized() * Vector2(abs(current_velocity.x), abs(current_velocity.y))

func _rotate():
	# Apply angle so long as object is still moving and isn't entirely blocked by a solid
	if (current_velocity.x != 0 or current_velocity.y != 0): # and is_roteable
		if angles == BEHAVIOR_8_DIRECTIONS_ANGLES._90_DEGREE_INTERVALS:
			_parent.rotation_degrees = (round(atan2(current_velocity.y, current_velocity.x) * to_deg / 90.0) * 90.0)
		elif angles == BEHAVIOR_8_DIRECTIONS_ANGLES._45_DEGREE_INTERVALS:
			_parent.rotation_degrees = (round(atan2(current_velocity.y, current_velocity.x) * to_deg / 45.0) * 45.0)
		elif angles == BEHAVIOR_8_DIRECTIONS_ANGLES._360_DEGREE_SMOOTH:
			_parent.rotation_degrees = round(atan2(current_velocity.y, current_velocity.x) * to_deg)

func _mirror():
	if directions == BEHAVIOR_8_DIRECTIONS._LEFT_RIGHT and angles == BEHAVIOR_8_DIRECTIONS_ANGLES._NONE:
		if _orient_left:
			_orient_left = false
			_parent.scale.x *= -1
	if directions == BEHAVIOR_8_DIRECTIONS._UP_DOWN and angles == BEHAVIOR_8_DIRECTIONS_ANGLES._NONE:
		if _orient_left:
			_orient_left = false
			_parent.scale.y *= -1

func _mirror_back():
	if directions == BEHAVIOR_8_DIRECTIONS._LEFT_RIGHT and angles == BEHAVIOR_8_DIRECTIONS_ANGLES._NONE:
		if !_orient_left:
			_orient_left = true
			_parent.scale.x *= -1
	if directions == BEHAVIOR_8_DIRECTIONS._UP_DOWN and angles == BEHAVIOR_8_DIRECTIONS_ANGLES._NONE:
		if !_orient_left:
			_orient_left = true
			_parent.scale.y *= -1

func stop():
	current_velocity = Vector2()
	current_direction = Vector2()
	
func simulate_control(horizontal, vertical):
	"""for horizontal: -1 = left; 0 = stop; 1 = right - for vertical: -1 = up; 0 = stop; 1 = down"""
#	_simleft = false
#	_simright = false
#	_simup = false
#	_simdown = false
	if horizontal < 0:
		_simleft = true
	elif horizontal > 0:
		_simright = true
	if vertical < 0:
		_simup = true
	elif vertical > 0:
		_simdown = true
		
func get_angle_of_motion():
	return _parent.rotation_degrees
	

