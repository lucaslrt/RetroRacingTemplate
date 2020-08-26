extends Node2D

var player_pos
var road_conf

func _ready() -> void:
	road_conf = get_node("/root/World/Road").road_conf
	pass

func _process(delta: float) -> void:
	update()
	pass

var player_color = Color(1,0,0)
func _draw() -> void:
	player_pos = get_node("/root/World/Road").pos
	if road_conf != null:
		for i in range(road_conf.size()):
			if player_pos < road_conf[i].seg_size * 200:
				var tilemap = get_parent().get_node("TileMap")
				var point_pos = Vector2(tilemap.minimap_conf[i].x, tilemap.minimap_conf[i].y)
				draw_circle(tilemap.map_to_world(point_pos), 10, player_color)
				break
#	draw_circle(minimap_conf)
	pass
