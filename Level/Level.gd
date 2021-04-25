extends Node2D

var _debug = false

onready var _player = $Player

onready var _tri_res = preload("res://Tri/Tri.tscn")

onready var _current_tri = $Tri
var _current_line_index = null
#onready var _current_line = _current_tri._get_line(_current_line_index)
var _current_line = null

var _next_tri = null
var _old_tri = null

var _next_line_index = null

var _player_input_registered = false
var _player_stopped = false

var _start_speed = 100 #pixels per second
var _speed = _start_speed #pixels per second
var _speed_inc = 15
var _input_t_threshold = 200 #msecs #the threshold beneath which the player gets a speed boost

var _level_started = false 
var _line_start_time = null

func _ready():
	
	_player.position = _current_tri.position #will be the root of the branch 

func _physics_process(delta):
	if _level_started:
		_process_player_movement(delta)

#moves the player to the correct starting location for the tri.
#sets up a new tri depending on which line player is on
func _start_line():
	#player is starting a new line. flag that they have not inputted anything for this line
	_player_input_registered = false
	#reset a bunch of stuff
	$Player.scale = Vector2(1,1)
	$Player.modulate = Color(1,1,1,1)
	_player._show_arrow(null)
	
	#by definition they are not stopped!
	_player_stopped = false
	
	#has player started or not? if this is the first time, it's a special case
	_current_line_index = _next_line_index
	_next_line_index = null
	
	_current_line = _current_tri._get_line(_current_line_index)
	_player.position = _current_line.points[0] + _current_tri.position
	
	_next_tri = _tri_res.instance()
	_next_tri.position = _current_line.points[1] + _current_tri.position
	add_child(_next_tri)
	
	#fade out the old tri
	if _old_tri != null:
		_old_tri._fade_out_whole_tri()

	_line_start_time = OS.get_ticks_msec()
	
	var traversal_duration = _get_traversal_duration()
	
	#chime stuff
	_chime_inc = 0
	_chimes[_chime_inc].play()
	_chime_timer.wait_time = traversal_duration/3.0 / 1000.0
	_chime_timer.start()
	
	#gold gathered stuff
	_gold_gathered_timer.wait_time = traversal_duration/2.0 / 1000.0
	_gold_gathered_timer.start()
	
	#fade out the other line
	var fade_out 
	if _current_line_index == 1:
		fade_out = 0
	else:
		fade_out = 1
	_current_tri._fade_out_line(fade_out)
	
	#player speed boost available visual feedback
	var threshold = traversal_duration - _input_t_threshold
	var start_boost_tween = threshold - 500 #just a magic number
	$BoostTween.interpolate_property($Player,"scale",Vector2(1,1),Vector2(1.2,1.2),500.0/1000.0,Tween.TRANS_LINEAR,Tween.EASE_IN,start_boost_tween/1000.0)
	$BoostTween.interpolate_property($Player,"modulate",Color(1,1,1,1),Color.turquoise,500.0/1000.0,Tween.TRANS_LINEAR,Tween.EASE_IN,start_boost_tween/1000.0)
	$BoostTween.start()

func _on_BoostTween_tween_completed(_object, _key):
	#$Player.modulate = Color(1,1,0,1)
	pass


var _chime_inc:int = 0
onready var _chimes = $Chimes.get_children()
onready var _chime_timer = $ChimeTimer

onready var _gold_collected_sound = $GoldSounds/GoldCollected0

onready var _gold_gathered_timer = $GoldGatheredTimer

func _on_ChimeTimer_timeout():
	if !_player_stopped:
		_chime_inc += 1
		_chimes[_chime_inc % 3].play()
		_chime_timer.start()

func _on_GoldGatheredTimer_timeout():
	if _current_tri._is_gold_on_line(_current_line_index):
		_current_tri._collect_gold(_current_line_index)
		_gold_collected_sound.play()
		Global.emit_signal("_score_changed",1)
	else:
		pass

func _process_player_movement(delta):
	#move the player from their current position toward the current line's second point.
	#but only if they are not stopped!
	if !_player_stopped:
		$Player._emit_particles(true)
		var dest = _current_line.points[1] + _current_tri.position

		var desired_vel = dest - _player.position
		
		#debug
		if _debug:
			$TestVector.clear_points()
			$TestVector.add_point(_player.position)
			$TestVector.add_point(_player.position+desired_vel)

		var vel = desired_vel.normalized() * _speed * delta 
		
		#don't place the player lower than the destination location
		if (_player.position + vel).y < dest.y:
			_player.position += vel 
	
		if (_player.position + vel) == dest or (_player.position + vel).y > dest.y: #WARNING - should be OR player y position > dest y position
			
			_old_tri = _current_tri
			
			#we reached the end of this line. but did the player input anything?
			if _player_input_registered:
				#ok to move to next line
				#set the current tri to the next tri
				_current_tri = _next_tri
				_start_line()
			else:
				#can't move to next line
				#player should be stopped
				_player_stopped = true
				$OtherSounds/SpeedPenalty.play()
				$Player._emit_particles(false)
				$Player.scale = Vector2(1,1)
				$Player.modulate = Color(1,1,1,1)

#ugh need a state machine?
func _input(event): #WARNING opportunity for breaks or return here?
	if _level_started: #regular gameplay
		if event.is_action_pressed("ui_left"):
			_next_line_index = 0
			_do_timing(OS.get_ticks_msec())
			_player_input_registered = true
			
			# was the player stopped? if so, start 'em.
			if _player_stopped:
				_current_tri = _next_tri
				_start_line()
			else:
				#player isn't stopped and pressed left so show the left arrow
				_player._show_arrow(0)
			
		if event.is_action_pressed("ui_right"):
			_next_line_index = 1
			_do_timing(OS.get_ticks_msec())
			_player_input_registered = true
			
			# was the player stopped? if so, start 'em.
			if _player_stopped:
				_current_tri = _next_tri
				_start_line()
			else:
				#player isn't stopped and pressed left so show the left arrow
				_player._show_arrow(1)
			
	else: #WARNING special case for when the level has not started yet
		if event.is_action_pressed("ui_left"):
			$CanvasLayer_UI/CountDownText._start()
			_next_line_index = 0
			_start_line()
			_level_started = true
		if event.is_action_pressed("ui_right"):
			$CanvasLayer_UI/CountDownText._start()
			_next_line_index = 1
			_start_line()
			_level_started = true

func _do_timing(t):
	#how much time will it take to traverse this line at this speed?
	var traversal_duration = _get_traversal_duration()
	var time_since_start = t - _line_start_time
	var diff = traversal_duration - time_since_start
	#print(diff)
	if diff < 0:
		_speed = _start_speed
	else:
		#how accurate? speed up if accurate enough
		if diff < _input_t_threshold:
			_speed += _speed_inc
			$OtherSounds/SpeedUp.play()
			if(_next_line_index == 0):
				_next_tri._show_speed_boost(1)
			else:
				_next_tri._show_speed_boost(0)
		else:
			pass

func _get_traversal_duration():
	return _get_current_line_length() / _speed * 1000 #msecs

func _get_current_line_length():
	return _current_line.points[0].distance_to(_current_line.points[1])

func _get_tri_point(tri,line,point):
	return tri._points_arr[line][point] + tri.position
