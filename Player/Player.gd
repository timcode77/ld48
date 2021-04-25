extends Node2D

onready var _arrow_array = [$LeftArrow,$RightArrow]

# Called when the node enters the scene tree for the first time.
func _ready():
	_show_arrow(null)
	
func _draw():
	draw_circle(Vector2(0,0),8,Color(1,1,1,1))
	
func _emit_particles(emit):
	$CPUParticles2D.emitting = emit
	
func _show_arrow(which):
	for i in _arrow_array:
		i.visible = false
	if which != null:
		_arrow_array[which].visible = true
