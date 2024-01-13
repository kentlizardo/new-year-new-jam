extends Node

var new_game_data := load("res://scenes/data/new_game.tres") as GameData
var game_data : GameData = new_game_data.duplicate()

const HISTORY_PATH := "user://history.dat"
var user_history : Array

func _ready():
	user_history = load_history()

func get_data() -> GameData:
	return game_data

func save_history():
	var file := FileAccess.open(HISTORY_PATH, FileAccess.WRITE)
	print("saving with keys: " + str(user_history))
	if file:
		for i in user_history:
			if !i.is_empty():
				file.store_line(i)
		file.close()

func load_history():
	var hist := []
	var file := FileAccess.open(HISTORY_PATH, FileAccess.READ)
	if file:
		print("found existing history.")
		for line in file.get_as_text().split("\n"):
			hist.append(line.strip_edges())
		file.get_line()
		file.close()
	else:
		push_warning("History file not found, starting with blank history")
	return hist
