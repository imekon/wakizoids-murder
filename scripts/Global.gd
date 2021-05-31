extends Node

const EDGE_UNIVERSE = 20000
const EDGE_UNIVERSE2 = 40000
const SCORING_FILENAME = "scoring.data"

onready var explosion = preload("res://scenes/Explosion.tscn")

var player
var main

var engine_playing = false
var sounds_enabled = true
var music_enabled = true

var music_gain = 0.7
var sound_gain = 0.7
var player_score = 0
var high_score = 0

func _ready():
	pass

func convert_gain_to_db(gain):
	if gain < 0.0:
		return -90.0
	else:
		return 20.0 * log(gain) / log(10)
		
func create_explosion(pos):
	var explode = explosion.instance()
	explode.position = pos
	explode.emitting = true
	main.add_child(explode)
	
	if sounds_enabled:
		main.play_explosion_sound()
	
func play_engine_sound():
	if !sounds_enabled:
		return
		
	if engine_playing:
		return
		
	main.play_engine_sound()
	engine_playing = true
	
func stop_engine_sound():
	if !sounds_enabled:
		return

	if !engine_playing:
		return
		
	main.stop_engine_sound()
	engine_playing = false
		
func game_won():
	player_score = player.score
	if player.score > high_score:
		high_score = player.score
	save_high_score(SCORING_FILENAME)
	get_tree().change_scene("res://scenes/GameOver.tscn")

func game_lost():
	player_score = player.score
	if player.score > high_score:
		high_score = player.score
#	if sounds_enabled:
#		main.play_explosion_sound()
	save_high_score(SCORING_FILENAME)
	get_tree().change_scene("res://scenes/GameLost.tscn")

func save_high_score(filename):
	var data = {
		"HighScore": high_score
	}

	var file = File.new()
	file.open(filename, File.WRITE)
	file.store_line(to_json(data))
	file.close()
	
func load_high_score():
	var file = File.new()
	if !file.file_exists(SCORING_FILENAME):
		return false
		
	file.open(filename, File.READ)
	var data = parse_json(file.get_line())
	if data != null:
		high_score = data["HighScore"]
	file.close()
	return true
