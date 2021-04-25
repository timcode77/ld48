extends Node2D

func _ready():
	$FinScore.text = str(Global._score).pad_zeros(3)


func _on_Button_pressed():
	get_tree().change_scene("res://Level/Level.tscn")
