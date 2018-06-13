tool
extends "res://addons/Behaviors/BaseBehavior.gd"

export var active_at_start = false
export var start_with_fade_in = true
export var min_opacity = 0.0
export var max_opacity = 1.0
export var fade_in_time = 1.0
export var wait_in_time = 0.0
export var fade_out_time = 1.0
export var wait_out_time = 0.0
export var destroy = false
export var repeat = false

signal fade_start
signal fade_in_finish
signal wait_in_finish
signal fade_out_finish
signal wait_out_finish
signal fade_finish

var _parent = null
var _tween = null
var _timer = null
var _stopping = false

var state = 0					# 0 : before start, 1 : fading in, 2 : wait in -> out, 3 : fading out, 4 : wait out -> in, 5 : after end
var cycle_count = 0

func _ready():
	_class_name = "BehaviorFade2D"
	state = 0
	_parent = get_parent()
	_tween = Tween.new()
	_tween.connect("tween_completed", self, "_on_tween_completed")
	add_child(_tween)
	_timer = Timer.new()
	_timer.connect("timeout", self, "_on_timer_timeout")
	add_child(_timer)
	if active_at_start:
		call_deferred("start")

func start():
	cycle_count = 0
	emit_signal("fade_start")
	_stopping = false
	if start_with_fade_in:
		_fade_in()
	else:
		_fade_out()

func stop(deferred):
	if deferred:				# attende che termini l'operazione corrente
		_stopping = true
	else:
		state = 5
		_tween.stop(_parent, "modulate")
		_timer.stop()		
		emit_signal("fade_finish")
		if destroy:
			_parent.queue_free()

func _fade_in():
	state = 1
	if fade_in_time > 0.0:
		_tween.interpolate_property(_parent, "modulate", Color(1, 1, 1, min_opacity), Color(1, 1, 1, max_opacity), fade_in_time, Tween.TRANS_LINEAR, Tween.EASE_IN)
		_tween.start()
	else:
		_on_tween_completed(null, "")

func restore():
	_parent.modulate = Color(1, 1, 1, max_opacity)

func _fade_out():
	state = 3
	if fade_out_time > 0.0:
		_tween.interpolate_property(_parent, "modulate", Color(1, 1, 1, max_opacity), Color(1, 1, 1, min_opacity), fade_out_time, Tween.TRANS_LINEAR, Tween.EASE_IN)
		_tween.start()	
	else:
		_on_tween_completed(null, "")
		
func _on_tween_completed (object, key):
	if state == 1:
		emit_signal("fade_in_finish")
	elif state == 3:
		emit_signal("fade_out_finish")
	
	if _stopping:
		emit_signal("fade_finish")
		if destroy:
			_parent.queue_free()		
		return 
		
	if object:
		_tween.stop(object, key)
	else:
		state += 1
		_on_timer_timeout()
		return
		
	if state == 1:							# è terminato il fade in
		if destroy and !start_with_fade_in:	# se ho iniziato con un fade out e devo distruggere il nodo al termine
			state = 5						# ho finito
			_parent.queue_free()				# distruggo il nodo
		else:
			state = 2							# mi metto in attesa per poi fare il fade out
			#_timer.wait_time = clamp(wait_in_time, 0.000001, 999999.0) 		# attendo il tempo necessario tra il fade in e il fade out
			_timer.wait_time = safe_timer(wait_in_time) 		# attendo il tempo necessario tra il fade in e il fade out
			_timer.start()
	elif state == 3:						# è terminato il fade out
		if destroy and start_with_fade_in:	# se ho iniziato con un fade in e devo distruggere il nodo al termine
			state = 5						# ho finito
			_parent.queue_free()				# distruggo il nodo
		else:
			state = 4							# mi metto in attesa per poi fare il fade in
			#_timer.wait_time = clamp(wait_out_time, 0.000001, 999999.0)	# attendo il tempo necessario tra il fade out e il fade in
			_timer.wait_time = safe_timer(wait_out_time)	# attendo il tempo necessario tra il fade out e il fade in
			_timer.start()
	
func _on_timer_timeout():
	_timer.stop()
	if state == 2:
		if !start_with_fade_in:
			cycle_count += 1
		emit_signal("wait_in_finish")
	elif state == 4:
		if start_with_fade_in:
			cycle_count += 1
		emit_signal("wait_out_finish")
	
	if _stopping:
		emit_signal("fade_finish")
		if destroy:
			_parent.queue_free()
		return 
	
	if state == 2:							# ho appena terminato l'attesa tra il fade in e il fade out
		if repeat:							# se devo ripetere
			_fade_out()						# avvio il fade out
		else:								# se non devo ripetere devo controllare con quale ho iniziato
			if start_with_fade_in:			# se ho iniziato con un fade in, 
				_fade_out()					# devo avviare il fade out
			else:							# se ho iniziato con un fade out, non devo avviare un altro fade out
				state = 5					# quindi finisco
				emit_signal("fade_finish")		# comunico che ho terminato
				if destroy:
					_parent.queue_free()
				
	elif state == 4:							# ho appena terminato l'attesa tra il fade out e il fade in
		if repeat:							# se devo ripetere
			_fade_in()						# avvio il fade in
		else:								# se non devo ripetere devo controllare con quale ho iniziato
			if start_with_fade_in:			# se ho iniziato con un fade in, 
				state = 5					# finisco
				emit_signal("fade_finish")		# comunico che ho terminato
				if destroy:
					_parent.queue_free()
			else:							# se ho iniziato con un fade out,
				_fade_in()					# devo avviare il fade in
