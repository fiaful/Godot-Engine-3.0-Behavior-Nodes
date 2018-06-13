extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

onready var fade = $Player/BehaviorFade2D
onready var item = $Item/BehaviorTakeItem2D
onready var score = $Label/BehaviorScoreLabel
onready var evidence = $Lives/BehaviorEvidence2D

onready var lives = null

var last_count = 0

func _ready():
	lives = get_node("/root/Test/Lives/BehaviorLives2D")
	lives.connect("die", self, "_on_lives_die")
	lives.connect("finish", self, "_on_lives_finish")
	
	# Called every time the node is added to the scene.
	# Initialization here
#	fade.connect("fade_start", self, "_on_fade_start")
#	fade.connect("fade_in_finish", self, "_on_fade_in_finish")
#	fade.connect("wait_in_finish", self, "_on_wait_in_finish")
#	fade.connect("fade_out_finish", self, "_on_fade_out_finish")
#	fade.connect("wait_out_finish", self, "_on_wait_out_finish")
#	fade.connect("fade_finish", self, "_on_fade_finish")
	
	item.connect("add_score", self, "_on_add_score")
	
#func _process(delta):
#	if fade.cycle_count != last_count:
#		last_count = fade.cycle_count
#		print ("count ", last_count)

func _on_lives_die():
	print ("die", lives.lives_number)

func _on_lives_extra():
	print ("extra", lives.lives_number)

func _on_lives_finish():
	print ("finish", lives.lives_number)

func _on_Button_pressed():
	score.evidence()


func _on_Button2_pressed():
	fade.stop(true)

func _on_fade_start():
	print ("fade start")
	
func _on_fade_in_finish():
	print ("fade in finish")
	
func _on_wait_in_finish():
	print ("wait in finish")
	
func _on_fade_out_finish():
	print ("fade out finish")
	
func _on_wait_out_finish():
	print ("wait out finish")
	
func _on_fade_finish():
	print ("fade finish")
	
	

func _on_Button3_pressed():
	evidence.start()

func _on_add_score():
	print ("add score ", item.score)

func _on_Button4_pressed():
	score.sub_score(300)
	score.evidence_score = true


func _on_Button5_pressed():
	lives.add_life(lives.get_standard_step())


func _on_Button6_pressed():
	lives.sub_life(lives.get_standard_step())
