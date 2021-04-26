extends Node2D

onready var _arrow_array = [$LeftArrow,$RightArrow]

var _hide_arrow_timer = Timer.new()

var _circle_radius = 8.0
const ARC_RADIUS = 16
var _arc_radius = ARC_RADIUS

func _ready():
	
	_show_arrow(null)
	
	_hide_arrow_timer.wait_time = 0.2
	_hide_arrow_timer.one_shot = true
	_hide_arrow_timer.connect("timeout", self, "_show_arrow",[null])
	add_child(_hide_arrow_timer)

func _process(_delta):
	update()

func _draw():
	#draw a circle arc around me 
	draw_arc(Vector2(0,0),_arc_radius,0,2*PI,24,Color(0.9,0.9,0.9,1),1,false)

	draw_circle(Vector2(0,0),_circle_radius,Color(0.9,0.9,0.9,1))

func _boost_build_up(duration,when): #args are msecs
	#print("_boost_build_up", duration,when)
	$BoostTween.interpolate_property(self,"_arc_radius",ARC_RADIUS,_circle_radius,duration/1000.0,Tween.TRANS_LINEAR,Tween.EASE_IN,when/1000.0)
	$BoostTween.start()

func _boost_build_up_reset():
	_arc_radius = ARC_RADIUS

func _emit_particles(emit):
	$CPUParticles2D.emitting = emit
	
func _show_arrow(which):
	for i in _arrow_array:
		i.visible = false
	if which != null:
		_arrow_array[which].visible = true
		_hide_arrow_timer.start()
