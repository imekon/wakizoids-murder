extends Node2D

onready var hostPort = $Panel/Host/Port
onready var joinAddress = $Panel/Join/Address
onready var joinPort = $Panel/Join/Port

func _ready():
	randomize()
	
	Global.load_high_score()

func on_readme_pressed():
	get_tree().change_scene("res://scenes/Readme.tscn")

func on_settings_pressed():
	get_tree().change_scene("res://scenes/Settings.tscn")

func on_host_pressed():
	var port = int(hostPort.text)
	Global.create_server(port)

func on_join_pressed():
	var address = joinAddress.text
	var port = int(joinPort.text)
	Global.create_client(address, port)
