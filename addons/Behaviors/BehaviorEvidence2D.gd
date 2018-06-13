tool
extends Position2D

export var duration = 1.0
export(Color) var start_color = Color(1,1,1,1)
export(Color) var finish_color = Color(1,1,1,0)
export(Vector2) var scale_offset = Vector2(1.0, 1.0)
export(Vector2) var position_offset = Vector2(0.0, 0.0)
export var duplicate = true

signal evidence
signal evidence_start(object)
signal evidence_finish

var _parent = null
var _startpos = Vector2(0, 0)
var _subevidence = null
var _class_name = "BehaviorEvidence2D"

var _scale
var _position
var _rectp = false
var _rects = false

func _ready():
	_parent = get_parent()
	_rects = false
	if ("scale" in _parent):
		_scale = _parent.scale
	elif ("rect_scale" in _parent):
		_scale = _parent.rect_scale
		_rects = true
	else:
		_scale = Vector2(1, 1)
		
	_rectp = false
	if ("position" in _parent):
		_position = _parent.position
	elif ("rect_position" in _parent):
		_position = _parent.rect_position
		_rectp = true
	else:
		_position = Vector2(0, 0)
	

func start():
	var dup_parent = _parent
	if duplicate:
		dup_parent = _parent.duplicate()
	for n in dup_parent.get_children():
		if n.has_method("check_class_name") and n.check_class_name("BehaviorEvidence2D"):
			_subevidence = n
			_subevidence._startpos = get_global_position()
	if duplicate:
		_parent.get_parent().add_child(dup_parent)
	
	var _tween = Tween.new()
	dup_parent.add_child(_tween)
	_tween.connect("tween_completed", self, "_on_tween_completed")
	_tween.connect("tween_step", self, "_on_tween_step")
	
	emit_signal("evidence_start", dup_parent)

	_tween.interpolate_property(dup_parent, "modulate", Color(start_color.r, start_color.g, start_color.b, start_color.a), Color(finish_color.r, finish_color.g, finish_color.b, finish_color.a), duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
	
	var sc = _scale + scale_offset
	if _rects:
		_tween.interpolate_property(dup_parent, "rect_scale", _scale, sc, duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
	else:
		_tween.interpolate_property(dup_parent, "scale", _scale, sc, duration, Tween.TRANS_LINEAR, Tween.EASE_IN)

#	if !_subevidence:
#		if _rectp:
#			_tween.interpolate_property(dup_parent, "rect_position", _position, _position + position_offset, duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
#		else:
#			_tween.interpolate_property(dup_parent, "position", _parent.position, _parent.position + position_offset, duration, Tween.TRANS_LINEAR, Tween.EASE_IN)

	_tween.start()
	
	emit_signal("evidence")

func _on_tween_completed(object, property):
	emit_signal("evidence_finish")
	object.queue_free()
	
func _on_tween_step(object, key, elapsed, value):
	if key == ":scale" or key == ":rect_scale":
		var offset = position_offset * elapsed
		if _subevidence:
			if _rectp:
				object.rect_position += _subevidence._startpos - _subevidence.get_global_position() + offset
			else:
				object.position += _subevidence._startpos - _subevidence.get_global_position() + offset

func check_class_name(name):
	return name == _class_name
