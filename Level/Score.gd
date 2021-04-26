extends Label

var _score = 0

func _ready():
	_change_score(_score)
	Global.connect("_score_changed",self,"_change_score")
	Global.connect("_game_over",self,"_level_fin")

func _change_score(amount):
	_score += amount
	text = str(_score).pad_zeros(3)

func _level_fin():
	Global._level_fin(_score)
