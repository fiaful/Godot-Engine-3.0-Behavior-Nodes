extends Label

onready var score = $BehaviorScoreLabel
onready var evidence = $BehaviorEvidence2D

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_BehaviorScoreLabel_evidence():
	score.evidence_at += 10
	score.evidence_score = true


func _on_BehaviorEvidence2D_evidence_start(object):
	object.add_color_override("font_color", evidence.start_color)
