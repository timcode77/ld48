extends Camera2D

var _timer
var _shake_amount = 1.5
var _shaking = false
onready var _initial_offset = offset

func _ready():
	_timer = Timer.new()
	_timer.connect("timeout",self,"_stop_shaking")
	_timer.wait_time = 0.15
	_timer.one_shot = true
	add_child(_timer)
	

func _process(_delta):
	if _shaking:
		offset = _initial_offset + Vector2(randf()*_shake_amount - _shake_amount/2.0,
											randf()*_shake_amount - _shake_amount/2.0
											)
func _screen_shake():
	_timer.start()
	_shaking = true
	
func _stop_shaking():
	_shaking = false
	offset = _initial_offset
