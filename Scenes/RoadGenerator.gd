extends Node2D

export(Vector2) var tile_size = Vector2(100,50)
var screen_width = ProjectSettings.get_setting("display/window/size/width")#1024
var screen_height = ProjectSettings.get_setting("display/window/size/height")#680

func _process(delta: float) -> void:
	if Input.is_action_pressed("draw"):
#		var pencil = preload("res://Prefabs/Pencil.tscn").instance()
#		add_child(pencil)
		draw_on_tilemap()
	pass

func draw_on_tilemap() -> void:
	
	var point = get_local_mouse_position()
	print("desenhando tile na posição ", point) #point.x/tile_size.x, ",", point.y/tile_size.y)
	var tile_point = $TileMap.world_to_map(point)
	$TileMap.set_cellv(tile_point,0)
	$TileMap.update_bitmask_area(tile_point)
	pass
