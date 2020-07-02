extends Node2D

var minimap_conf

func _ready() -> void:
	minimap_conf = SceneSwitcher.get_param("road_tile_conf")
	print("minimap_conf = ", minimap_conf)
	for tile in minimap_conf:
		$Minimap/TileMap.set_cellv(tile,0)
		$Minimap/TileMap.update_bitmask_area(tile)
	pass
