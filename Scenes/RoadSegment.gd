class_name RoadSegment

var size
var curve_degrees
var pos_x = 0
var pos_y = 0
var pos_z = 0
var scale = 0
var clip = 0.0

# Posição e tamanho levando em conta a distância
var x_3d = 0
var y_3d = 0
var width_3d = 0

var is_start
var is_end
var is_checkpoint

var sprite_decorations = []
var sprite_items = []

var road_colors = []
var grass_colors = []
var border_colors = []
var divid_line_colors = []

func _init(size = 100, curve_degrees = 0.0, is_start = false, is_end = false,
	is_checkpoint = false):
	
	self.size = size
	self.curve_degrees = curve_degrees
	self.is_start = is_start
	self.is_end = is_end
	self.is_checkpoint = is_checkpoint
	
	pass
