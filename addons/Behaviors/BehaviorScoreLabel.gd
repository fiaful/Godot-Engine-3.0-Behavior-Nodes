extends Node

export var score = 0
export var animate = false
export var increment_wait = 0.01
export var increment_step = 7
export var padding_length = 0
export var can_be_less_than_0 = false
export var evidence_score = false
export var evidence_at = 500
#export var use_evidence_color = false
#export(Color) var evidence_color = Color(1,1,1,1)
#export(Vector2) var evidence_scale_offset = Vector2(0.2, 0.2)
#export var duration = 1.0
export var extralife_at = 0
export var hi_score_node = ""	# percorso ad un altro nodo di tipo BehaviorScoreLabel che contiene l'hi score
export var lives_behavior_node = ""
export var evidence_behavior_node = ""

signal evidence
signal extralife

var _parent = null
var _timer = null
var _o_hi_score = null
var _lives = null
var _anim_score = 0

func _ready():
	_parent = get_parent()
	_timer = Timer.new()
	add_child(_timer)
	_timer.connect("timeout", self, "_on_timer_timeout")
	if hi_score_node != "":
		_o_hi_score = get_node(hi_score_node)
	if lives_behavior_node != "":
		_lives = get_node(lives_behavior_node)
	_parent.text = ("%0*d" % [padding_length, score])
	_anim_score = score

func set_score(num):
	if animate:
		anim_score(num)
		return
			
	score = num
	if !can_be_less_than_0 and score < 0:
		score = 0
	_anim_score = score
	_parent.text = ("%0*d" % [padding_length, score])
	
	if evidence_score and score >= evidence_at:
		_evidence()
		
	if extralife_at != 0 and score >= extralife_at:
		_extralife()
		if lives_behavior_node != "":
			_lives.add_life(1.0)
			_lives.evidence()

	if _o_hi_score and _o_hi_score.score != 0 and score >= _o_hi_score.score:
		_set_hi_score()
		

func anim_score(num):
	score = num
	if !can_be_less_than_0 and score < 0:
		score = 0

	if _timer.is_stopped():
		_timer.wait_time = increment_wait
		_timer.start()

func add_score(num):
	if animate:
		anim_score(score + num)
	else:
		set_score(score + num)

func sub_score(num):
	if animate:
		anim_score(score - num)
	else:
		set_score(score - num)
	
func _on_timer_timeout():
	if _anim_score < score:
		_anim_score += increment_step
		if _anim_score > score:
			_anim_score = score
		_parent.text = ("%0*d" % [padding_length, _anim_score])
	elif _anim_score > score:
		_anim_score -= increment_step
		if _anim_score < score:
			_anim_score = score
		_parent.text = ("%0*d" % [padding_length, _anim_score])
	else:
		_timer.stop()

	if evidence_score and _anim_score >= evidence_at:
		_evidence()
		
	if extralife_at != 0 and _anim_score >= extralife_at:
		_extralife()
		if lives_behavior_node != "":
			_lives.add_life(1.0)
			_lives.evidence()

	if _o_hi_score and _o_hi_score.score != 0 and score >= _o_hi_score.score:
		_set_hi_score()

func evidence():
	_evidence()

func _evidence():
	evidence_score = false

	if evidence_behavior_node != "":
		var text_size = _parent.get_font("font").get_string_size(_parent.text)
		var _evidence = get_node(evidence_behavior_node)
		_evidence.position = text_size / 2
		_evidence.start()
		
#	var new_label = _parent.duplicate()
#	for n in new_label.get_children():
#		new_label.remove_child(n)
#	_parent.get_parent().add_child(new_label)
#	if use_evidence_color:
#		new_label.add_color_override("font_color", evidence_color)
#	new_label.rect_global_position = _parent.rect_global_position
#	new_label.text = ("%0*d" % [padding_length, evidence_at])
#
#	var _tween = Tween.new()
#	new_label.add_child(_tween)
#	_tween.connect("tween_completed", self, "_on_tween_completed")
#
#	_tween.interpolate_property(new_label, "modulate", Color(1, 1, 1, _parent.modulate.a), Color(1, 1, 1, 0), duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
##
#	var sc = _parent.rect_scale + evidence_scale_offset
#	_tween.interpolate_property(new_label, "rect_scale", _parent.rect_scale, sc, duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
#
#	var text_size = _parent.get_font("font").get_string_size(new_label.text)
#	var new_pos = (text_size / 2 - ((text_size * sc) / 2)) + _parent.rect_global_position
#	_tween.interpolate_property(new_label, "rect_global_position", _parent.rect_global_position, new_pos, duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
#
#	_tween.start()
	
	emit_signal("evidence")

func _extralife():
	extralife_at = 0
	emit_signal("extralife")

func _on_tween_completed(object, property):
	object.queue_free()
	
func _set_hi_score():
	_o_hi_score.set_score(score)
