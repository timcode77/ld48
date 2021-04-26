extends Label

var _time = Global._level_duration

func _ready():
	_display_time()

func _display_time():
	text = str(_time).pad_zeros(2)

func _start():
	$CountDownTimer.start()

func _on_CountDownTimer_timeout():
	_time -= 1
	
	if _time == 10:
		modulate = Color(1,0,0,1)
	
	if _time == 0:
		Global.emit_signal("_game_over") 
	_display_time()
