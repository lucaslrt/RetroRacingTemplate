extends Node2D

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


func _process(delta: float) -> void:
	if Input.is_action_pressed("draw"):
		_draw_on_tilemap()
	if Input.is_action_pressed("erase"):
		_erase_tile()
	pass

func _draw_on_tilemap() -> void:
	var point = get_local_mouse_position()
#	print("desenhando tile na posição ", point)
	var tile_point = $TileMap.world_to_map(point)
#	print("tile_point = ", tile_point)
	if ![Vector2(12,0), Vector2(12,1), Vector2(13,0), Vector2(13,1)].has(tile_point): #Local onde o button está
		$TileMap.set_cellv(tile_point,0)
		$TileMap.update_bitmask_area(tile_point)
		
		if road_tile_pos.find(tile_point) == -1:
			road_tile_pos.push_back(tile_point)
#		print("cell_autotile_coord = ", $TileMap.get_cell_autotile_coord(tile_point.x,tile_point.y))
#		print("road_tile_pos = ", road_tile_pos)
		road_conf = _set_road_segment()
	pass

func _erase_tile() -> void:
	var point = get_local_mouse_position()
#	print("desenhando tile na posição ", point)
	var tile_point = $TileMap.world_to_map(point)
	$TileMap.set_cellv(tile_point,-1)
	$TileMap.update_bitmask_area(tile_point)
	road_conf = _set_road_segment()
	road_tile_pos.erase(tile_point)
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
		print("direction = ", direction)
		match(autotile_coord):
#			END_E:
#				new_road_conf.push_back({curve = 0, seg_size = 100})
#			END_W:
#				new_road_conf.push_back({curve = 0, seg_size = 100})
#			END_N:
#				new_road_conf.push_back({curve = 0, seg_size = 100})
#			END_S:
#				new_road_conf.push_back({curve = 0, seg_size = 100})
			ROAD_NW:
				if direction == -1:
					new_road_conf.push_back({curve = 0.9, seg_size = 100})
				else:
					new_road_conf.push_back({curve = -0.9, seg_size = 100})
#			ROAD_NS:
#				new_road_conf.push_back({curve = 0, seg_size = 100})
			ROAD_NE:
				if direction == 1:
					new_road_conf.push_back({curve = 0.9, seg_size = 100})
				else:
					new_road_conf.push_back({curve = -0.9, seg_size = 100})
#			ROAD_EW:
#				new_road_conf.push_back({curve = 0, seg_size = 100})
			ROAD_SW:
				if direction == -2:
					new_road_conf.push_back({curve = -0.9, seg_size = 100})
				else:
					new_road_conf.push_back({curve = 0.9, seg_size = 100})
			ROAD_ES:
				if direction == 1:
					new_road_conf.push_back({curve = -0.9, seg_size = 100})
				else:
					new_road_conf.push_back({curve = 0.9, seg_size = 100})
			_:
				new_road_conf.push_back({curve = 0, seg_size = 100})
	print("\n\n")
	return new_road_conf

func _on_Button_pressed() -> void:
	print("Button pressed")
	var track_size = 0
	for i in road_conf:
		i.seg_size += track_size
		track_size += i.seg_size - track_size
	SceneSwitcher.change_scene("Scenes/Road.tscn", {"road_conf":road_conf})
	pass # Replace with function body.
