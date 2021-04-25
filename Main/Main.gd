extends Node2D


#var _level = preload("res://Level/Level.gd")


func _on_Button_pressed():
	get_tree().change_scene("res://Level/Level.tscn")
