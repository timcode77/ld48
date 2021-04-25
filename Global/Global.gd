extends Node

signal _score_changed(amount)
signal _game_over()

var _score

var _level_duration = 60

func _level_fin(score):
	_score = score
	get_tree().change_scene("res://FinishScreen/FinishScreen.tscn")
