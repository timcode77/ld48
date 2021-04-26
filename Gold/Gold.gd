extends Node2D

func _process(_delta):
	pass

func _collect():
	for g in $Nuggets.get_children():
		$Tween.interpolate_property(g,"position",g.position,g.position-Vector2(0,100) + (100*Vector2(randf(),randf())-Vector2(50,50)),0.5,Tween.TRANS_BOUNCE,Tween.EASE_IN_OUT)
		$Tween.interpolate_property(g,"scale",g.scale,Vector2(0,0),0.3)
		$Tween.start()
