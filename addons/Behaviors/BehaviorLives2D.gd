tool
extends "res://addons/Behaviors/BaseBehavior.gd"

enum LIVES_MODE { FULL_ONLY, FULL_EMPTY, HALF, QUARTER }
export(LIVES_MODE) var lives_mode = LIVES_MODE.FULL_ONLY

export(Texture) var texture_empty = null
export(Texture) var texture_first_quarter = null
export(Texture) var texture_half = null
export(Texture) var texture_last_quarter = null
export(Texture) var texture_full = null

export var offset_x = 0

export var lives_number = 1.0

export var max_visible_lives = 5
export var max_lives = 5

export var current_visible_lives = 3

export var auto_label = false
export var use_label = false
export var label_text_prefix = " x "
export var label_text_padding = 1
export var label = ""

export var fade_on_last = false
export var fade_behavior_node = ""

export var evidence_behavior_node = ""

var _parent = null
var _label = null
var _lives_sprite = []
var _save_use_label = false
var _last_int_lives = 0
var _fade = null
var _evidence = null

signal die			# perso una vita
signal finish		# finite le vite

func _ready():
	_class_name = "BehaviorLives2D"
	_parent = get_parent()
	if label != "":
		_label = get_node(label)
		_label.hide()
	if fade_behavior_node != "":
		_fade = get_node(fade_behavior_node)
		if _fade:
			_fade.connect("fade_finish", self, "_on_fade_finish")
	if evidence_behavior_node != "":
		_evidence = get_node(evidence_behavior_node)
	_save_use_label = use_label
	_last_int_lives = floor(lives_number)
	for i in range(max_visible_lives):
		var sprite = Sprite.new()
		sprite.position = Vector2(i * (texture_full.get_width() + offset_x), 0)
		if lives_mode == LIVES_MODE.FULL_ONLY:
			sprite.texture = texture_full
		else:
			sprite.texture = texture_empty
		_parent.call_deferred("add_child", sprite)
		_lives_sprite.append(sprite)
		_update()

func _on_fade_finish():
	_fade.restore()
	_fade.state = 0

func _update():
	if use_label:
		_set_label()
		return
	else:
		_label.hide()
	if lives_mode == LIVES_MODE.FULL_EMPTY:
		_update_full_empty()
	elif lives_mode == LIVES_MODE.FULL_ONLY:
		_update_full_only()
	elif lives_mode == LIVES_MODE.HALF:
		_update_half()
	elif lives_mode == LIVES_MODE.QUARTER:
		_update_quarter()

func _set_label():
	var counter = 0
	for s in _lives_sprite:
		counter += 1
		if counter > 1:
			s.hide()
		else:
			s.show()
	_label.show()
	var ln = floor(lives_number)
	var dec = lives_number - ln
	var num = ln
	if dec > 0:
		num += 1
	_label.text = (label_text_prefix + "%0*d" % [label_text_padding, num])
	_update_with_label(_lives_sprite[0], dec)
	
func _update_with_label(s, dec):
	if lives_mode == LIVES_MODE.HALF:
		if dec > 0.5 or dec == 0:
			s.texture = texture_full
		else:
			s.texture = texture_half
	elif lives_mode == LIVES_MODE.QUARTER:
		if dec >= 0.25 and dec < 0.5:
			s.texture = texture_first_quarter
		elif dec >= 0.5 and dec < 0.75:
			s.texture = texture_half
		elif dec >= 0.75 and dec < 1.0:
			s.texture = texture_last_quarter
		else:
			s.texture = texture_full
	else:
		s.texture = texture_full

func _update_full_only():
	var l = int(lives_number)
	var counter = 0
	for s in _lives_sprite:
		counter += 1
		if counter > l:
			s.hide()
		else:
			s.show()
			
func _update_full_empty():
	var l = floor(lives_number)
	var counter = 0
	for s in _lives_sprite:
		s.show()
		counter += 1
		if counter > l:
			s.texture = texture_empty
		else:
			s.texture = texture_full
		if counter > current_visible_lives and counter > l:
			s.hide()

func _update_half():
	var l = floor(lives_number)
	var dec = lives_number - l
	var counter = 0
	for s in _lives_sprite:
		s.show()
		var hide = true
		counter += 1
		if counter == l + 1:
			if dec < 0.25:
				s.texture = texture_empty
			elif dec > 0.75:
				s.texture = texture_full
				hide = false
			else:
				s.texture = texture_half
				hide = false
		else:
			if counter > l:
				s.texture = texture_empty
			else:
				s.texture = texture_full
		if counter > current_visible_lives and counter <= l:
			hide = false
		if counter > current_visible_lives and hide:
			s.hide()

func _update_quarter():
	var l = floor(lives_number)
	var dec = lives_number - l
	var counter = 0
	for s in _lives_sprite:
		s.show()
		var hide = true
		counter += 1
		if counter == l + 1 and dec > 0:
			if dec > 0 and dec < 0.25:
				s.texture = texture_empty
			elif dec >= 0.25 and dec < 0.5:
				s.texture = texture_first_quarter
				hide = false
			elif dec >= 0.5 and dec < 0.75:
				s.texture = texture_half
				hide = false
			elif dec >= 0.75 and dec < 1.0:
				s.texture = texture_last_quarter
				hide = false
			else:
				s.texture = texture_full
				hide = false
		else:
			if counter > l:
				s.texture = texture_empty
			else:
				s.texture = texture_full
		if counter > current_visible_lives and counter <= l:
			hide = false
		if counter > current_visible_lives and hide:
			s.hide()

func get_standard_step():
	if lives_mode == LIVES_MODE.HALF:
		return 0.5
	elif lives_mode == LIVES_MODE.QUARTER:
		return 0.25
	return 1.0

func add_life(life):	
	lives_number += life
	if lives_number <= 1 and fade_on_last and _fade.state == 0:
		_fade.start()
	elif lives_number > 1 and fade_on_last:
		_fade.stop(false)
	if lives_number > max_visible_lives and auto_label:
		use_label = true
	elif lives_number <= max_visible_lives and auto_label:
		use_label = _save_use_label
	var ln = floor(lives_number)
	var dec = lives_number - ln
	var die = false
	if ln < _last_int_lives and dec == 0:
		die = true
		_last_int_lives = ln
	if lives_number > max_lives:
		lives_number = max_lives
		_last_int_lives = floor(max_lives)
	if lives_number < 0:
		lives_number = 0
		_last_int_lives = 0
	_update()
	if die:
		emit_signal("die")
	if lives_number <= 0.0:
		emit_signal("finish")
		
func sub_life(life):
	add_life(life * -1)
	
func evidence():
	if evidence_behavior_node != "":
		_evidence.start()
