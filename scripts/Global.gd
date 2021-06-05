extends Node

const EDGE_UNIVERSE = 20000
const EDGE_UNIVERSE2 = 40000
const SCORING_FILENAME = "scoring.data"

const MAX_CLIENTS = 4

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

var networkPeer = NetworkedMultiplayerENet.new()
var peers = []
var levelScene = preload("res://scenes/Main.tscn")
var playerScene = preload("res://scenes/PlayerShip.tscn")

var levelInstance

signal levelLoaded

func _ready():
	networkPeer.connect("peer_connected", self, "peer_connected")
	networkPeer.connect("peer_disconnected", self, "peer_disconnected")
	get_tree().connect("connected_to_server", self, "connected_to_server")
	networkPeer.connect("server_disconnected", self, "server_disconnected")
	get_tree().connect("connection_failed", self, "connection_failed")

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

# NETWORK STUFF

func create_server(port):
	connect("levelLoaded", self, "server_setup_after_load")
	get_tree().change_scene_to(levelScene)
	networkPeer.create_server(port, MAX_CLIENTS)
	
func server_setup_after_load():
	levelInstance = get_tree().current_scene
	get_tree().network_peer = networkPeer
	peers.append(1)
	create_player(1)

func create_client(address, port):
	connect("levelLoaded", self, "client_setup_after_load")
	get_tree().change_scene_to(levelScene)
	networkPeer.create_client(address, port)

func client_setup_after_load():
	levelInstance = get_tree().current_scene
	get_tree().network_peer = networkPeer

func peer_connected(peerId):
	# print("peer_connected")
	# print(peerId)
	peers.append(peerId)
	create_player(peerId)

func peer_disconnected(peerId):
	# print("peer_disconnected")
	# print(peerId)
	peers.remove(peers.find(peerId))
	destroy_player(peerId)

func connected_to_server():
	create_player(get_tree().get_network_unique_id())

func connection_failed():
	server_disconnected()

func server_disconnected():
	peers.clear()
	get_tree().change_scene("res://Welcome.tscn")

# NEEDS UPDATING FOR WAKIZOIDS	
func create_player(peerId):
	var x = randi() % 1024
	var y = randi() % 600
	var player = playerScene.instance()
	player.set_network_master(peerId)
	player.name = String(peerId)
	player.position = Vector2(x, y)
	# player.rotation_degrees = float(randi() % 360)
	levelInstance.add_child(player)
	return player

func destroy_player(peerId):
	var player = levelInstance.get_node(String(peerId))
	player.queue_free()
