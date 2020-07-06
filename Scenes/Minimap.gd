extends TileMap

var minimap_conf

func set_minimap(value) -> void:
	minimap_conf = value
	pass

func _ready() -> void:
	minimap_conf = SceneSwitcher.get_param("road_tile_conf")
	print("minimap_conf = ", minimap_conf)
	for tile in minimap_conf:
		set_cellv(tile,0)
		update_bitmask_area(tile)
		
#	yield(get_node("/root/World/Road"),"ready")
	pass



