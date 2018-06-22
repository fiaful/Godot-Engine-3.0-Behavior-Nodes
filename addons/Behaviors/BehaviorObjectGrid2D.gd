###[ INFO ]######################################################################################################

# Component: BehaviorObjectGrid2D
# Author: Francesco Iafulli (fiaful)
# Version: 1.0
# Last modify: 2018-06-22

# Requirements:

# Changelog:
#
#

###[ BEGIN ]#####################################################################################################

extends "res://addons/Behaviors/BaseBehavior.gd"

###[ ENUMS ]#####################################################################################################

# object can be selected and moved; 
# hole can't be selected and can't be moved; 
# obstacle can be selected but can't be moved
enum BEHAVIOR_OBJECT_GRID_2D_CELL_TYPE { _OBJECT, _HOLE, _OBSTACLE }

# to consider player move cursor to obstacle or hole cell type
# stop: move in this direction is disabled
# jump: move in this direction jumps one or more cell, to first valid object cell
# normal: move in this direction select obstacle or hole cell type also (as normal object)
enum BEHAVIOR_OBJECT_GRID_2D_CELL_TYPE_CURSOR_MODE { _STOP, _JUMP, _NORMAL }

###[ EXPORTED VARIABLES ]########################################################################################

# size of grid in cells. starts with 9x9 grid size
export (Vector2) var grid_size = Vector2(9, 9)

# cell size in pixel. starts with 32x32 cell size
export (Vector2) var cell_size = Vector2(32, 32)

# indicates scene to use as grid filler
export (PackedScene) var filler_object = null

# scene to use to evidence the selected cell
export (PackedScene) var selected_object = null

# scene to use to evidence current selection
export (PackedScene) var cursor_object = null

# indicate mapped input to use to select cell (can be configured as mouse click, keyboard key, controller button, etc.)
export var select_mapped_input = ""

# indicated mapped input to move selecion to direction
export var move_selection_left_mapped_input = ""
export var move_selection_up_mapped_input = ""
export var move_selection_right_mapped_input = ""
export var move_selection_down_mapped_input = ""

# if true, when selection go over a bound, reappear to opposite side
export var move_selection_circular = false

# cursor movement delay
export var cursor_movement_delay = 0.15

# determine if cursor have to be visible or not
export var cursor_visible = true	setget 	_set_cursor_visible, _get_cursor_visible

# if true, keep cursor under mouse (mouse movement)
export var cursor_under_mouse = false

# determine if selected have to be visible or not
export var selected_visible = true	setget 	_set_selected_visible, _get_selected_visible

# cursor - hole behavior (see BEHAVIOR_OBJECT_GRID_2D_CELL_TYPE_CURSOR_MODE)
export(BEHAVIOR_OBJECT_GRID_2D_CELL_TYPE_CURSOR_MODE) var cursor_hole = BEHAVIOR_OBJECT_GRID_2D_CELL_TYPE_CURSOR_MODE._STOP

# cursor - obstacle behavior (see BEHAVIOR_OBJECT_GRID_2D_CELL_TYPE_CURSOR_MODE)
export(BEHAVIOR_OBJECT_GRID_2D_CELL_TYPE_CURSOR_MODE) var cursor_obstacle = BEHAVIOR_OBJECT_GRID_2D_CELL_TYPE_CURSOR_MODE._STOP

###[ SIGNALS ]##################################################################################################

signal new_cell_object(x, y)

signal selected(x, y, x_prev, y_prev)

signal swipe(x_src, y_src, x_dst, y_dst)

signal continuous_swipe(x_src, y_src, x_dst, y_dst)

signal continuous_swipe_end

###[ PRIVATE VARIABLES ]########################################################################################

# grid: bidimensional array of objects
var _grid = []

# grid types (see BEHAVIOR_OBJECT_GRID_2D_CELL_TYPE)
var _grid_types = []

# position (cell) of selecion cursor
var _cursor_pos = Vector2(0, 0)

# position (cell) of selected cell (-1, -1) = not selected
var _selected_pos = Vector2(-1, -1)

var _cursor_move_timer = null
var _can_move = 0

var _cursor_object = null
var _selected_object = null

var _prev_swipe_pos = Vector2(-1, -1)
var _swipeing = false

###[ PUBLIC VARIABLES ]##########################################################################################

var ignore_input = false	setget 	_set_ignore_input, _get_ignore_input

###[ METHODS ]###################################################################################################

func _ready():
	_cursor_move_timer = Timer.new()
	add_child(_cursor_move_timer)
	_cursor_move_timer.connect("timeout", self, "_on_cursor_move_timer_timeout")
	_can_move = true
	redim (grid_size.x, grid_size.y)
	if cursor_object:
		_cursor_object = cursor_object.instance()
		_cursor_object.visible = cursor_visible and _cursor_pos.x >= 0 and _cursor_pos.y >= 0
		set_position(_cursor_object, _cursor_pos * cell_size)
		add_child(_cursor_object)
	if selected_object:
		_selected_object = selected_object.instance()
		_selected_object.visible = selected_visible and _selected_pos.x >= 0 and _selected_pos.y >= 0
		set_position(_selected_object, _selected_pos * cell_size)
		add_child(_selected_object)

func _on_cursor_move_timer_timeout():
	_cursor_move_timer.stop()
	_can_move = true

func _delay_move():
	_can_move = false
	_cursor_move_timer.wait_time = cursor_movement_delay
	_cursor_move_timer.start()

func redim(width, height):
	if _grid != []:
		for x in range(_grid.size()):
			for y in range(_grid[x].size()):
				if _grid[x][y]:
					_grid[x][y].queue_free()
	_grid.clear()

	for x in range(width):
		_grid.append([])
		_grid_types.append([])
		_grid[x].resize(height)
		_grid_types[x].resize(height)

		for y in range(height):
			_grid[x][y] = _filler_factory(x, y)
			_grid_types[x][y] = BEHAVIOR_OBJECT_GRID_2D_CELL_TYPE._OBJECT
			emit_signal("new_cell_object", x, y)
			if _grid[x][y]:
				self.add_child(_grid[x][y])


func pos_to_cell(pos):
	var p = pos / cell_size
	return Vector2(floor(p.x), floor(p.y))

func cell_to_pos(cell):
	var p = cell * cell_size
	return Vector2(floor(p.x), floor(p.y))

func get_object_at_xy(x, y):
	return _grid[x][y]

func set_object_at_xy(x, y, obj, set_position=true):
	if set_position:
		var pos = Vector2(x, y) * cell_size
		set_position(obj, pos)
	_grid[x][y] = obj

func adjust_object_position_at_xy(x, y):
	var o = _grid[x][y]
	if o:
		set_position(o, cell_to_pos(Vector2(x, y)))

func get_cell_type_at_xy(x, y):
	return _grid_types[x][y]

func set_cell_type_at_xy(x, y, cell_type):
	_grid_types[x][y] = cell_type


func get_cursor_position():
	return _cursor_pos
	
func set_cursor_position(x, y):
	_cursor_pos = Vector2(x, y)
	

func get_selected_position():
	return _selected_pos
	
func set_selected_position(x, y):
	_selected_pos = Vector2(x, y)


func is_valid_position(x, y):
	return x >= 0 and x <= _grid.size()-1 and y >= 0 and y <= _grid[0].size()-1

func is_normal(x, y):
	# se le coordinate della cella sono fuori dalla griglia ritorno false
	if !is_valid_position(x, y):
		return false
	
	# se la cella non contiene un oggetto ritorno false
	if !_grid[x][y]:
		return false
	
	# la cella è una cella normale se il suo tipo è di tipo object	
	if _grid_types[x][y] == BEHAVIOR_OBJECT_GRID_2D_CELL_TYPE._OBJECT:
		return true

	# oppure se il suo tipo è hole e il comportamento cursore - hole è normal
	elif _grid_types[x][y] == BEHAVIOR_OBJECT_GRID_2D_CELL_TYPE._HOLE and \
			cursor_hole == BEHAVIOR_OBJECT_GRID_2D_CELL_TYPE_CURSOR_MODE._NORMAL:
		return true
		
	# oppure se il suo tipo è obstacle e il comportamento cursore - obstacle è normal
	elif _grid_types[x][y] == BEHAVIOR_OBJECT_GRID_2D_CELL_TYPE._OBSTACLE and \
			cursor_obstacle == BEHAVIOR_OBJECT_GRID_2D_CELL_TYPE_CURSOR_MODE._NORMAL:
		return true
		
	# altrimenti la cella non è una cella normale
	return false

func swap_object(x_src, y_src, x_dst, y_dst):
	if is_valid_position(x_src, y_src) and is_valid_position(x_dst, y_dst):
		var tmp = _grid[x_src][y_src]
		_grid[x_src][y_src] = _grid[x_dst][y_dst]
		_grid[x_dst][y_dst] = tmp
		return true
	else:
		return false

func swap_object_and_cell_type(x_src, y_src, x_dst, y_dst):
	if is_valid_position(x_src, y_src) and is_valid_position(x_dst, y_dst):
		var tmp = _grid[x_src][y_src]
		_grid[x_src][y_src] = _grid[x_dst][y_dst]
		_grid[x_dst][y_dst] = tmp
		tmp = _grid_types[x_src][y_src]
		_grid_types[x_src][y_src] = _grid_types[x_dst][y_dst]
		_grid_types[x_dst][y_dst] = tmp
		return true
	else:
		return false


func _process(delta):
	var maxy = _grid[0].size()-1
	var maxx = _grid.size()-1
	var distance = 0
	var cell_mouse
	if cursor_object:
		if cursor_under_mouse or (Input.is_action_just_pressed(select_mapped_input) and Input.get_mouse_button_mask() != 0):
			var mouse_pos = get_viewport().get_mouse_position() - self.position + (cell_size / 2)
			cell_mouse = pos_to_cell(mouse_pos)
			distance = _get_cursor_mouse_distance(cell_mouse)
		
		if Input.is_action_pressed(move_selection_up_mapped_input) and _can_move:
			distance = _get_cursor_distance(maxy, Vector2(0, -1))
			_delay_move()
			
		elif Input.is_action_pressed(move_selection_down_mapped_input) and _can_move:
			distance = _get_cursor_distance(maxy, Vector2(0, 1))
			_delay_move()
			
		elif Input.is_action_pressed(move_selection_left_mapped_input) and _can_move:
			distance = _get_cursor_distance(maxx, Vector2(-1, 0))
			_delay_move()
			
		elif Input.is_action_pressed(move_selection_right_mapped_input) and _can_move:
			distance = _get_cursor_distance(maxx, Vector2(1, 0))
			_delay_move()
					
		if Input.is_action_just_released(move_selection_up_mapped_input) or \
			Input.is_action_just_released(move_selection_down_mapped_input) or \
			Input.is_action_just_released(move_selection_left_mapped_input) or \
			Input.is_action_just_released(move_selection_right_mapped_input) or \
			Input.is_action_just_released(select_mapped_input):
			_on_cursor_move_timer_timeout()
		
		if distance != 0:
			_cursor_object.visible = cursor_visible and _cursor_pos.x >= 0 and _cursor_pos.y >= 0
			set_position(_cursor_object, _cursor_pos * cell_size)

	if Input.is_action_just_pressed(select_mapped_input):
#		if invalid_mouse_pos:
		if distance < 0:
			return
		else:
			var prev_pos = _selected_pos
			_selected_pos = _cursor_pos
			_prev_swipe_pos = _selected_pos
			_swipeing = true
			if _selected_object:
				_selected_object.visible = selected_visible and _selected_pos.x >= 0 and _selected_pos.y >= 0
				set_position(_selected_object, _selected_pos * cell_size)
			emit_signal("selected", _selected_pos.x, _selected_pos.y, prev_pos.x, prev_pos.y)

	if _swipeing and Input.is_action_just_released(select_mapped_input):
		_swipeing = false
		emit_signal("continuous_swipe_end")
		
	_handle_single_swipe(cell_mouse)
	_handle_continuous_swipe(cell_mouse)
	
	
func _handle_single_swipe(cell_mouse):
	if Input.is_action_just_released(select_mapped_input) and Input.get_mouse_button_mask() == 0:
		if cell_mouse != _selected_pos:
			if _grid[_selected_pos.x][_selected_pos.y]:
				if cell_mouse.x > _selected_pos.x:
					# swipe a destra
					if is_normal(_selected_pos.x + 1, _selected_pos.y):
						emit_signal("swipe", _selected_pos.x, _selected_pos.y, _selected_pos.x + 1, _selected_pos.y)
				elif cell_mouse.x < _selected_pos.x:
					# swipe a sinistra
					if is_normal(_selected_pos.x - 1, _selected_pos.y):
						emit_signal("swipe", _selected_pos.x, _selected_pos.y, _selected_pos.x - 1, _selected_pos.y)
				elif cell_mouse.y > _selected_pos.y:
					# swipe in basso
					if is_normal(_selected_pos.x, _selected_pos.y + 1):
						emit_signal("swipe", _selected_pos.x, _selected_pos.y, _selected_pos.x, _selected_pos.y + 1)
				elif cell_mouse.y < _selected_pos.y:
					# swipe in alto
					if is_normal(_selected_pos.x, _selected_pos.y - 1):
						emit_signal("swipe", _selected_pos.x, _selected_pos.y, _selected_pos.x, _selected_pos.y - 1)

func _handle_continuous_swipe(cell_mouse):
	if _swipeing and Input.is_action_pressed(select_mapped_input) and Input.get_mouse_button_mask() != 0:
		if is_normal(cell_mouse.x, cell_mouse.y) and cell_mouse != _prev_swipe_pos:
			if _grid[_prev_swipe_pos.x][_prev_swipe_pos.y]:
				if cell_mouse.x > _prev_swipe_pos.x:
					# swipe a destra
					if is_normal(_prev_swipe_pos.x + 1, _prev_swipe_pos.y):
						emit_signal("continuous_swipe", _prev_swipe_pos.x, _prev_swipe_pos.y, _prev_swipe_pos.x + 1, _prev_swipe_pos.y)
						_prev_swipe_pos = Vector2(_prev_swipe_pos.x + 1, _prev_swipe_pos.y)
					else:
						return
				elif cell_mouse.x < _prev_swipe_pos.x:
					# swipe a sinistra
					if is_normal(_prev_swipe_pos.x - 1, _prev_swipe_pos.y):
						emit_signal("continuous_swipe", _prev_swipe_pos.x, _prev_swipe_pos.y, _prev_swipe_pos.x - 1, _prev_swipe_pos.y)
						_prev_swipe_pos = Vector2(_prev_swipe_pos.x - 1, _prev_swipe_pos.y)
					else:
						return
				elif cell_mouse.y > _prev_swipe_pos.y:
					# swipe in basso
					if is_normal(_prev_swipe_pos.x, _prev_swipe_pos.y + 1):
						emit_signal("continuous_swipe", _prev_swipe_pos.x, _prev_swipe_pos.y, _prev_swipe_pos.x, _prev_swipe_pos.y + 1)
						_prev_swipe_pos = Vector2(_prev_swipe_pos.x, _prev_swipe_pos.y + 1)
					else:
						return
				elif cell_mouse.y < _prev_swipe_pos.y:
					# swipe in alto
					if is_normal(_prev_swipe_pos.x, _prev_swipe_pos.y - 1):
						emit_signal("continuous_swipe", _prev_swipe_pos.x, _prev_swipe_pos.y, _prev_swipe_pos.x, _prev_swipe_pos.y - 1)
						_prev_swipe_pos = Vector2(_prev_swipe_pos.x, _prev_swipe_pos.y - 1)
					else:
						return
			#_prev_swipe_pos = cell_mouse

func _pos_in_bounds(new_pos, limit, dir_vector):
	if dir_vector.x != 0:
		if new_pos.x < 0:
			if move_selection_circular:
				new_pos.x = limit
			else:
				return Vector2(-1, -1)
		if new_pos.x > limit:
			if move_selection_circular:
				new_pos.x = 0
			else:
				return Vector2(-1, -1)
				
	if dir_vector.y != 0:
		if new_pos.y < 0:
			if move_selection_circular:
				new_pos.y = limit
			else:
				return Vector2(-1, -1)
		if new_pos.y > limit:
			if move_selection_circular:
				new_pos.y = 0
			else:
				return Vector2(-1, -1)

	return new_pos

# determina la possibilità di movimento del cursore
# tenendo conto anche dei comportamenti tra cursore e buchi e tra cursore e ostacoli
func _get_cursor_distance(limit, dir_vector):
	# la distanza percorribile minima è 1 (salvo che se non mi posso muovere diventa 0)
	var ret = 1
	# calcolo la cella di spostamento in vase al vettore di movimento
	# sinistra = (-1, 0) - destra = (1, 0) - su = (0, -1) - giù = (0, 1)
	# nel calcolo della nuova posizione, tengo conto anche se raggiungo i bordi della
	# griglia e se il movimento del cursore deve essere circolare
	# (new_pos è la nuova cella in cui mi sto spostando)
	var new_pos = _pos_in_bounds(_cursor_pos + dir_vector, limit, dir_vector)
	# se _pos_in_bounds ritorna (-1, -1) vuol dire che lo spostamento non può essere effettuato
	# in tale direzione
	if new_pos.x < 0 and new_pos.y < 0:
		# quindi ritorno 0 per indicare che non c'è stato spostamento del cursore
		return 0
	
	# la nuova posizione è una posizione valida, quindi controllo se la cella è una cella
	# normale (ovvero non è nè un buco nè un ostacolo) 
	if _grid_types[new_pos.x][new_pos.y] != BEHAVIOR_OBJECT_GRID_2D_CELL_TYPE._HOLE and \
			_grid_types[new_pos.x][new_pos.y] != BEHAVIOR_OBJECT_GRID_2D_CELL_TYPE._OBSTACLE:
		# in questo caso la posizione è sicuramente corretta e la imposto come nuova posizione
		# del cursore
		_cursor_pos = new_pos
		# quindi ritorno 1 perchè mi sono mosso di una casella
		return ret
	
	# se invece la nuova posizione è un buco, dipende dal comportamento impostato per
	# il cursore rispetto al buco:
	elif _grid_types[new_pos.x][new_pos.y] == BEHAVIOR_OBJECT_GRID_2D_CELL_TYPE._HOLE:
		# se mi devo fermare
		if cursor_hole == BEHAVIOR_OBJECT_GRID_2D_CELL_TYPE_CURSOR_MODE._STOP:
			# ritorno 0 per indicare che non c'è stato spostamento del cursore
			# senza aggiornare la posizione del cursore
			return 0
		# se invece devo trattarlo come una cella normale, mi ci sposto sopra e quindi
		elif cursor_hole == BEHAVIOR_OBJECT_GRID_2D_CELL_TYPE_CURSOR_MODE._NORMAL:
			# imposto la posizione come nuova posizione del cursore
			_cursor_pos = new_pos
			# e ritorno 1 perchè mi sono mosso di una casella
			return ret
			
	# se invece la nuova posizione è un ostacolo, dipende dal comportamento impostato per
	# il cursore rispetto agli ostacoli:
	elif _grid_types[new_pos.x][new_pos.y] == BEHAVIOR_OBJECT_GRID_2D_CELL_TYPE._OBSTACLE:
		# se mi devo fermare
		if cursor_obstacle == BEHAVIOR_OBJECT_GRID_2D_CELL_TYPE_CURSOR_MODE._STOP:
			# ritorno 0 per indicare che non c'è stato spostamento del cursore
			# senza aggiornare la posizione del cursore
			return 0
		# se invece devo trattarlo come una cella normale, mi ci sposto sopra e quindi
		elif cursor_obstacle == BEHAVIOR_OBJECT_GRID_2D_CELL_TYPE_CURSOR_MODE._NORMAL:
			# imposto la posizione come nuova posizione del cursore
			_cursor_pos = new_pos
			# e ritorno 1 perchè mi sono mosso di una casella
			return ret
	
	# imposto una condizione forzata per uscire dal ciclo (mi servirà più avanti)
	var run_cycle = true
	
	# ora devo gestire i casi in cui le celle diverse da quelle normali devono essere saltate
	# quindi se la nuova cella in cui mi sto spostando non è una cella normale, devo ciclare
	# fino a trovarne una valida:
	# (ciclo fintanto che la nuova cella non è una cella normale)
	while run_cycle and _grid_types[new_pos.x][new_pos.y] != BEHAVIOR_OBJECT_GRID_2D_CELL_TYPE._OBJECT:
		# sposto la cella di destinazione (new_pos) di una casella nella direzione indicata da (dir_vector)
		new_pos = _pos_in_bounds(new_pos + dir_vector, limit, dir_vector)
		# se la cella non è una cella valida, vuol dire che non esiste una cella su cui possa saltare,
		if new_pos.x < 0 and new_pos.y < 0:
			# quindi ritorno 0 ad indicare che non c'è stato spostamento
			# e non aggiorno la posizione del cursore
			return 0
		
		# se la nuova cella è valida, quindi il salto di una cella è riuscito, devo comunque
		# valutare se la cella su cui sto atterrando è valida oppure no
		# se la cella su cui sto atterrando è un buco e come comportamento cursore - buco ho
		# impostato che mi devo fermare:
		if _grid_types[new_pos.x][new_pos.y] == BEHAVIOR_OBJECT_GRID_2D_CELL_TYPE._HOLE and \
				cursor_hole == BEHAVIOR_OBJECT_GRID_2D_CELL_TYPE_CURSOR_MODE._STOP:
			# il salto non può essere considerato valido e quindi annullo tutto il movimento
			# quindi ritorno 0 ad indicare che non c'è stato spostamento
			# e non aggiorno la posizione del cursore
			return 0
		# se la cella su cui sto atterrando è un buco e come comportamento cursore - buco ho
		# impostato che devo gestirlo come una cella normale:
		elif _grid_types[new_pos.x][new_pos.y] == BEHAVIOR_OBJECT_GRID_2D_CELL_TYPE._HOLE and \
				cursor_hole == BEHAVIOR_OBJECT_GRID_2D_CELL_TYPE_CURSOR_MODE._NORMAL:
			# esco forzatamente dal ciclo e lascio continuare lo script che aggiornerà
			# la posizione del cursore e la distanza percorsa
			run_cycle = false
		# stesso dicasi se la cella di destinazione è di tipo ostacolo
		# se la cella su cui sto atterrando è un ostacolo e come comportamento cursore - ostacolo ho
		# impostato che mi devo fermare:
		elif _grid_types[new_pos.x][new_pos.y] == BEHAVIOR_OBJECT_GRID_2D_CELL_TYPE._OBSTACLE and \
				cursor_obstacle == BEHAVIOR_OBJECT_GRID_2D_CELL_TYPE_CURSOR_MODE._STOP:
			# il salto non può essere considerato valido e quindi annullo tutto il movimento
			# quindi ritorno 0 ad indicare che non c'è stato spostamento
			# e non aggiorno la posizione del cursore
			return 0
		# se la cella su cui sto atterrando è un ostacolo e come comportamento cursore - ostacolo ho
		# impostato che devo gestirlo come una cella normale:
		elif _grid_types[new_pos.x][new_pos.y] == BEHAVIOR_OBJECT_GRID_2D_CELL_TYPE._OBSTACLE and \
				cursor_obstacle == BEHAVIOR_OBJECT_GRID_2D_CELL_TYPE_CURSOR_MODE._NORMAL:
			# esco forzatamente dal ciclo e lascio continuare lo script che aggiornerà
			# la posizione del cursore e la distanza percorsa
			run_cycle = false

		# se tutto è andato a buon fine aumento la distanza di una casella			
		ret += 1
		
		# siccome il ciclo può essere infinito (ad esempio tutta la riga/colonna è costituita da
		# oggetti che non possono essere saltati) imposto una condizione di sicurezza che mi fa
		# uscire forzatamente dal ciclo:
		
		# se la distanza corrente è maggiore della lunghezza della riga/colonna della griglia,
		# vuol dire che ho compiuto un giro completo senza trovare una cella su cui atterrare
		if ret > limit:
			# quindi ritorno 0 ad indicare che non c'è stato spostamento
			# e non aggiorno la posizione del cursore
			return 0
			
	# il salto è andato a buon fine (indipendentemente da quanto lungo esso sia stato)
	# quindi aggiorno la posizione del cursore
	_cursor_pos = new_pos
	# e ritorno la distanza percorsa
	return ret

func _get_cursor_mouse_distance(cell_mouse):
	# preimposto la distanza a 0 (ovvero cella che non può accettare il cursore)
	var distance = 0
	
	# se il mouse si trova su una qualsiasi cella della griglia
	if is_valid_position(cell_mouse.x, cell_mouse.y):
		# e se la cella su cui si trova il mouse è diversa dalla cella su cui attualmente si trova il cursore
		if cell_mouse != _cursor_pos:
			# devo verificare se la cella su cui si trova il mouse può accettare il cursore in
			# base ai comportamenti impostati
			# se la cella è una cella oggetto normale, 
			if _grid_types[cell_mouse.x][cell_mouse.y] == BEHAVIOR_OBJECT_GRID_2D_CELL_TYPE._OBJECT:
				# sposo il cursore senza problemi
				_cursor_pos = cell_mouse
				# ed imposto la distanza ad un valore pari ad una unità (in realtà potrei calcolarla come
				# distanza algebrica tra la posizione attuale e quella precedente, ma dato che non mi serve
				# conoscere esattamente la distanza, evito questo calcolo)
				distance = 1
			else:
				
				# se invece la cella è di tipo buco, posso spostarci il cursore solo se come comportamento
				# ho indicato di voler trattare i buchi come celle normali
				if _grid_types[cell_mouse.x][cell_mouse.y] == BEHAVIOR_OBJECT_GRID_2D_CELL_TYPE._HOLE and \
						cursor_hole == BEHAVIOR_OBJECT_GRID_2D_CELL_TYPE_CURSOR_MODE._NORMAL:
					# se sono in questo caso, aggiorno la posizione del cursore
					_cursor_pos = cell_mouse
					# ed imposto la distanza a 1 (come sopra)
					distance = 1
				
				# se invece la cella è di tipo ostacolo, posso spostarci il cursore solo se come comportamento
				# ho indicato di voler trattare gli ostacoli come celle normali
				elif _grid_types[cell_mouse.x][cell_mouse.y] == BEHAVIOR_OBJECT_GRID_2D_CELL_TYPE._OBSTACLE and \
						cursor_obstacle == BEHAVIOR_OBJECT_GRID_2D_CELL_TYPE_CURSOR_MODE._NORMAL:
					# se sono in questo caso, aggiorno la posizione del cursore
					_cursor_pos = cell_mouse
					# ed imposto la distanza a 1 (come sopra)
					distance = 1					
			
				# in tutti gli altri casi devo considerare la cella non valida (quindi non ci posso spostare
				# sopra il cursore)
				else:
					# ritorno un valore identificativo pari a -1 (in modo che possa verificarlo dall'esterno)
					return -1
	# se il mouse non si trova all'interno della griglia
	else:
		# ritorno un valore identificativo pari a -1 (in modo che possa verificarlo dall'esterno)
		return -1
		
	# ritorno la distanza (che varrà 0 se la cella sotto il mouse non può accettare il cursore,
	# o 1 se invece può accettarlo)
	return distance

func _filler_factory(x, y):
	if !filler_object:
		return null
		
	var o = filler_object.instance()
	var pos = Vector2(x, y) * cell_size
	set_position(o, pos)
	return o

func _set_cursor_visible(value):
	cursor_visible = value
	if _cursor_object:
		_cursor_object.visible = value
	
func _get_cursor_visible():
	if _cursor_object:
		return _cursor_object.visible
	return false

func _set_selected_visible(value):
	selected_visible = value
	if _selected_object:
		_selected_object.visible = value
	
func _get_selected_visible():
	if _selected_object:
		return _selected_object.visible
	return false

func _set_ignore_input(value):
	ignore_input = value
	set_process(!value)
	
func _get_ignore_input():
	return ignore_input

###[ END ]#######################################################################################################
