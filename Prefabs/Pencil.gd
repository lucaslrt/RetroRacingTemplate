extends Line2D

func _process(delta: float) -> void:
	if Input.is_action_just_released("draw"):
		$Timer.stop()
	pass


func _on_Timer_timeout() -> void:
	print("Desenhando")
	var point = get_global_mouse_position()
	add_point(Vector2(point.x+5, point.y-25))
	$Timer.start()
	pass # Replace with function body.
