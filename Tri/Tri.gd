extends Node2D

#tool #so it will show itself in the editor

var _points_arr = []

var _gold_position

var _label_sides = [-80,80]

func _ready():
	$SpeedBoostLabel.visible = false
	
	_gold_position = randi()%2

	if _gold_position == 0:
		$Gold0.visible = true
		$Gold1.visible = false
	else:
		$Gold0.visible = false
		$Gold1.visible = true
	
	for i in [$L0, $L1]:
		_points_arr.append(i.points)

func _get_line(l:int):
	return get_node("L" + str(l))

#returns if the gold is on the same side as l (0 = left, 1 = right)
func _is_gold_on_line(l:int):
	#print("_gold_position:", _gold_position, ", current_line: ", l)
	return _gold_position == l

var _speed_bost_label_already_faded = false

func _show_speed_boost(side):
	$SpeedBoostLabel.visible = true
	$SpeedBoostLabel.position.x = _label_sides[side]
	$SpeedBoostTween.interpolate_property($SpeedBoostLabel,"scale",Vector2(0.8,0.8),Vector2(1,1),0.5)
	$SpeedBoostTween.interpolate_property($SpeedBoostLabel,"modulate",Color(1,1,1,0),Color(1,1,1,1),0.5)
	$SpeedBoostTween.start()

func _on_SpeedBoostTween_tween_completed(_object, _key):
	if not _speed_bost_label_already_faded:
		$SpeedBoostTween.interpolate_property($SpeedBoostLabel,"modulate",Color(1,1,1,1),Color(1,1,1,0),0.5,Tween.TRANS_LINEAR,Tween.EASE_IN,0.5)
		$SpeedBoostTween.start()
		_speed_bost_label_already_faded = true
	
func _collect_gold(l):
	get_node("Gold" + str(l))._collect()
	
func _fade_out_line(l):
	$FadeOutTween.interpolate_property(get_node("L" + str(l)),"modulate",Color(1,1,1,1),Color(1,1,1,0),0.8,Tween.TRANS_LINEAR,Tween.EASE_IN,0.5)
	$FadeOutTween.interpolate_property(get_node("Gold" + str(l)),"modulate",Color(1,1,1,1),Color(1,1,1,0),0.8,Tween.TRANS_LINEAR,Tween.EASE_IN,0.5)
	$FadeOutTween.start()
	
func _fade_out_whole_tri():
	$FadeOutTween.interpolate_property(self,"modulate",Color(1,1,1,1),Color(1,1,1,0),0.8,Tween.TRANS_LINEAR,Tween.EASE_IN,0.5)
	$FadeOutTween.start()
