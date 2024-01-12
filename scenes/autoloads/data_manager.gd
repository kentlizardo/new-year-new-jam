extends Node

var new_game_data := load("res://scenes/data/new_game.tres") as GameData
var game_data : GameData = new_game_data.duplicate()

func get_data() -> GameData:
	return game_data
