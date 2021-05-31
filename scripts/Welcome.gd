extends Node2D

func _ready():
	randomize()
	
	Global.load_high_score()

func on_start_pressed():
	get_tree().change_scene("res://scenes/Main.tscn")

func on_readme_pressed():
	get_tree().change_scene("res://scenes/Readme.tscn")

func on_settings_pressed():
	get_tree().change_scene("res://scenes/Settings.tscn")
