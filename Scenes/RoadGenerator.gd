extends Node2D

const RoadSegment = preload("res://Scenes/RoadSegment.gd")  

const END_E = Vector2(1,0)
const END_W = Vector2(0,1)
const END_N = Vector2(2,0)
const END_S = Vector2(3,0)
const ROAD_NW = Vector2(0,0)
const ROAD_NS = Vector2(1,3)
const ROAD_NE = Vector2(0,3)
const ROAD_EW = Vector2(2,1)
const ROAD_SW = Vector2(1,2)
const ROAD_ES = Vector2(1,1)

export(Vector2) var tile_size = Vector2(100,50)
var screen_width = ProjectSettings.get_setting("display/window/size/width")#1024
var screen_height = ProjectSettings.get_setting("display/window/size/height")#680

var road_conf = []
var road_tile_pos = []

var create_pressed = false
var map_min_coord = Vector2(0,0)
var map_max_coord = Vector2(0,0)

func _process(delta: float) -> void:
	if not create_pressed:
		$CameraEditor.position = get_global_mouse_position()
		$CameraEditor.update()
		if Input.is_action_pressed("draw"):
			_draw_on_tilemap()
		if Input.is_action_pressed("erase"):
			_erase_tile()
	pass

func _mark_tile(tile_point) -> void:
	if tile_point != null:
		$Selector.show()
		$Selector.position = $TileMap.map_to_world(tile_point)
		$Selector.position.y += 25
	else:
		$Selector.hide()
	pass

func _draw_on_tilemap() -> void:
	var point = get_local_mouse_position()
#	print("desenhando tile na posição ", point)
	var tile_point = $TileMap.world_to_map(point)
#	print("tile_point = ", tile_point)
	if road_tile_pos.has(tile_point):
		_mark_tile(tile_point)
		return
	
	if road_tile_pos.empty(): # Caso não tenha estrada ainda colocada, o player pode adiciona-la em qualquer lugar
#		print("Mapa Vazio")
		$TileMap.set_cellv(tile_point,0)
		$TileMap.update_bitmask_area(tile_point)
		road_tile_pos.push_back(tile_point)
		_mark_tile(tile_point)
		road_conf = _set_road_segment()
	else:
		var last_tile = road_tile_pos.back()
		var possible_points = [Vector2(last_tile.x + 1, last_tile.y), 
							Vector2(last_tile.x - 1, last_tile.y), 
							Vector2(last_tile.x,last_tile.y + 1), 
							Vector2(last_tile.x, last_tile.y - 1)]
#		print("last_tile = ", last_tile)
#		print("possible_points = ", possible_points)
		
		if possible_points.has(tile_point):
			_mark_tile(tile_point)
			$TileMap.set_cellv(tile_point,0)
			$TileMap.update_bitmask_area(tile_point)
			road_tile_pos.push_back(tile_point)
#			print("road_tile_pos = ", road_tile_pos)
			road_conf = _set_road_segment()
	pass

func _erase_tile() -> void:
	var point = get_local_mouse_position()
	var tile_point = $TileMap.world_to_map(point)
#	print("Apagando tile na posição ", tile_point)
#	print("road_tile_pos = ", road_tile_pos.back())
	if road_tile_pos.back() == tile_point:
#		print("Apagando tile...")
		$TileMap.set_cellv(tile_point,-1)
		$TileMap.update_bitmask_area(tile_point)
		road_conf = _set_road_segment()
		road_tile_pos.erase(tile_point)
		_mark_tile(road_tile_pos.back())
	
	pass

func _set_road_segment() -> Dictionary:
	var new_road_conf = []
	var direction = 0
	var last_curve_tile
	var last_pos
	for i in range(road_tile_pos.size()):
#		print("current tile pos = ", road_tile_pos[i])
		var autotile_coord = $TileMap.get_cell_autotile_coord(road_tile_pos[i].x,road_tile_pos[i].y)
		if last_pos != null:
			if last_pos.x != road_tile_pos[i].x:
				if last_pos.x < road_tile_pos[i].x:
					direction = -1
				else:
					direction = -2
			elif last_pos.y != road_tile_pos[i].y:
				if last_pos.y < road_tile_pos[i].y:
					direction = 1
				else:
					direction = 2
					
		last_pos = road_tile_pos[i]
#		print("direction = ", direction)
		match(autotile_coord):
			ROAD_NW:
				if direction == -1:
					new_road_conf.push_back(RoadSegment.new(100, 0.9))
				else:
					new_road_conf.push_back(RoadSegment.new(100, -0.9))
			ROAD_NE:
				if direction == 1:
					new_road_conf.push_back(RoadSegment.new(100, 0.9))
				else:
					new_road_conf.push_back(RoadSegment.new(100, -0.9))
			ROAD_SW:
				if direction == -2:
					new_road_conf.push_back(RoadSegment.new(100, -0.9))
				else:
					new_road_conf.push_back(RoadSegment.new(100, 0.9))
			ROAD_ES:
				if direction == 1:
					new_road_conf.push_back(RoadSegment.new(100, -0.9))
				else:
					new_road_conf.push_back(RoadSegment.new(100, 0.9))
			_:
				new_road_conf.push_back(RoadSegment.new(100))
#	print("\n\n")
	return new_road_conf

func _on_Button_pressed() -> void:
	create_pressed = true
	var track_size = 0
	for i in road_conf:
		i.size += track_size
		track_size += i.size - track_size
#	print("road_tile_conf = ", road_tile_pos)
	SceneSwitcher.change_scene("Scenes/World.tscn", {"road_conf":road_conf, "road_tile_conf":road_tile_pos})
	pass

func _on_Button_button_down() -> void:
	create_pressed = true
	pass
