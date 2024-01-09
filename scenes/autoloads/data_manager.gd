extends Node

var game_data : GameData = load("res://scenes/data/new_game.tres")

func get_data() -> GameData:
	return game_data
