extends Node2D

onready var shields_label = $HUD/ShieldsLabel
onready var health_label = $HUD/HealthLabel
onready var score_label = $HUD/ScoreLabel
onready var thrust_label = $HUD/ThrustLabel
onready var rock_label = $HUD/RockLabel
onready var alien_label = $HUD/AlienLabel

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	shields_label.text = "Shields: %d" % player.shields
	health_label.text = "Health: %d" % player.health
	score_label.text = "Score: %d High score: %d" % [ player.score, Global.high_score ]
	thrust_label.text = "Thrust: %d" % player.thrust
	rock_label.text = "Rocks: %d" % rock_count
	alien_label.text = "Aliens: %d" % alien_count
	
