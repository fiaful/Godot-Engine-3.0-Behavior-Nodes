tool
extends "res://addons/Behaviors/BaseBehavior.gd"

export var enabled = true

export var score = 100
export var life = 0
export var destroy = true

export var auto_take_by_group = false
export(PoolStringArray) var auto_take_groups
export(AudioStreamSample) var audio_sample = null

export var auto_increment_score = ""
export var auto_increment_life = ""

export var evidence_behavior_node = ""

signal taken
signal add_score
signal add_life

var _parent = null
var _audio = null
var _evidence = null

var _tween_end = false
var _audio_end = false

func _ready():
	_class_name = "BehaviorTakeItem2D"
	_parent = get_parent()
	_audio = AudioStreamPlayer2D.new()
	add_child(_audio)
	_audio.connect("finished", self, "_on_audio_finished")
	_parent.connect("area_entered", self, "_on_area_entered")
	if evidence_behavior_node != "":
		_evidence = get_node(evidence_behavior_node)
		_evidence.duplicate = false
		_evidence.connect("evidence_finish", self, "_on_evidence_finish")
	
func start():
	if !enabled:
		return
	_tween_end = false
	_audio_end = false
	if audio_sample:
		_audio.stream = audio_sample
		_audio.play()
	else:
		_audio_end = true
	if evidence_behavior_node != "":
		_evidence.start()
	emit_signal("taken")
	if score != 0:
		emit_signal("add_score")
	if life != 0:
		emit_signal("add_life")
	if auto_increment_score and score != 0:
		var scorelabel = get_node(auto_increment_score)
		scorelabel.add_score(score)
	if auto_increment_life and life != 0:
		var lifelabel = get_node(auto_increment_life)
		lifelabel.add_life(life)

func _on_evidence_finish():
	_tween_end = true
	if destroy:
		if _tween_end and _audio_end:
			queue_free()
		return

func _on_audio_finished():
	_audio_end = true
	if destroy:
		if _tween_end and _audio_end:
			queue_free()
		
func _on_area_entered(area):
	if !enabled:
		return
	if auto_take_by_group:
		for check_area in auto_take_groups:
			if area.is_in_group(check_area):
				start()
				enabled = false
				return