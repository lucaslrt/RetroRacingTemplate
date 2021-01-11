extends Node2D

var screen_width = ProjectSettings.get_setting("display/window/size/width")#1024
var screen_height = ProjectSettings.get_setting("display/window/size/height")#680

const RoadSegment = preload("Scenes/RoadSegment.gd")  

var road_width = 2000
var acceleration_view = 200 # Campo de visão da pista (quanto maior, mais afinada fica)
var track_size = 0 # Número total de segmentos
var render_seg_num = 175 # Número de segmentos renderizados na tela

var speed = 200
var step = float(1) / 60 # Delta time
var top_speed#seg / delta * 1.5
var acceleration
var breaking
var decel
var field_of_view = 100.0
var cam_zoom = 1000 #Profundidade da câmera
var lines = []
var grass
var road
var border
var divid_line
var pos = 0 setget set_pos, get_pos
var skyline
var skln_pos = 0
var skln_height = 0
var playerX = 0
var speedX = .7

var road_conf = []

func set_pos(value) -> void:
	pos = value
	pass

func get_pos() -> int:
	return pos

func _ready():
	top_speed = float(acceleration_view) / step * 2
	acceleration = float(top_speed) / 4
	breaking = -top_speed
	decel = float(-top_speed) / 5
	cam_zoom = 1 / tan((field_of_view / 2) * PI / 180)
	
#	_create_road()
	_mock_road()
	pass

func _create_road():
	road_conf = SceneSwitcher.get_param("road_conf")
#	print("road_conf = ", road_conf)
	
	track_size = road_conf[road_conf.size() - 1].seg_size
#	print("track_size = ", track_size)
	var road_conf_index = 0
	for i in range(track_size):
		lines.push_back({x = 0, y = 0, z = 0, X = 0, Y = 0, W = 0, scale = 0, 
			curve = 0, sprite = null, spriteX = 0, clip = 0.0})
		lines[i].z = i * acceleration_view
		if i > road_conf[road_conf_index].seg_size:
			road_conf_index += 1
		lines[i].curve = road_conf[road_conf_index].curve
	pass

func _mock_road():
	# Drawing Road
	track_size = 2600
#	print("Criando pista...")
	var last_y = 0
	var x = -((2600 - 1200)/2)
	for i in range(track_size):# Quantity of horizontal lines on the road
#		lines.push_back({x = 0, y = 0, z = 0, X = 0, Y = 0, W = 0, scale = 0, 
#			curve = 0, sprite = null, spriteX = 0, clip = 0.0})
		lines.push_back(RoadSegment.new())
		lines[i].pos_z = i * acceleration_view
		if i != 0 and track_size % i == 0:
			var new_sprite = Sprite.new()
			new_sprite.texture = load("res://icon.png")
			new_sprite.hide()
			var sprite_position_x = -3.5
			lines[i].sprite_decorations.push_back({sprite = new_sprite, 
				pos_x = sprite_position_x, pos_y = 0})
			$YSort.add_child(lines[i].sprite_decorations[0].sprite)
		if i > 300 and i < 700: #Right curve
			lines[i].curve_degrees = 0.9
		if i > 800 and i < 1200: #Left curve
			lines[i].curve_degrees = -0.7
		if i > 750 and i < 1200: #Cliffs
#			lines[i].y = sin(i / 30.0 - 25) * 1500
			lines[i].pos_y = sin((i / 30.0) - 25) * 4500
			last_y = lines[i].pos_y
#			print("last_y cliff = ", last_y)
		if i >= 1200: #Down Cliff
#			lines[i].y = ((-last_y/(track_size-1200)) * (i - 1200)) + last_y # f(x) = ax + b
			lines[i].pos_y = _sigmoid(x,-last_y,0,0.009,last_y) 
			x += 1
#			print("lines[i].y = ", lines[i].y)

	track_size = lines.size()
	set_process(true)
	pass

func _sigmoid(x,a,b,c,d):
	return a/(1 + exp(c*(-x + b))) + d

# Posiciona o segmento levando em conta a distância da câmera
func line(segment, cam_x, cam_y, cam_z):
	if ((segment.pos_z) - cam_z) != 0:
		segment.scale = abs(cam_zoom / (segment.pos_z - cam_z)) 
	segment.x_3d = (1 + segment.scale * (segment.pos_x - cam_x)) * screen_width/ 2
	segment.y_3d = (1 - segment.scale * (segment.pos_y - cam_y)) * screen_height/ 2
	segment.width_3d = segment.scale * road_width * (screen_width / 2)
	return segment


func drawRoad(col, x1, y1, w1, x2, y2, w2):
	var point = [Vector2(int(x1-w1), int(y1)), Vector2(int(x2-w2), int(y2)),
	Vector2(int(x2+w2), int(y2)), Vector2(int(x1+w1), int(y1))]
	
	draw_primitive(PoolVector2Array(point), 
		PoolColorArray([col, col, col, col, col]), PoolVector2Array([]))
	pass

func _draw_sprite(line):
	if !line.sprite_decorations.empty():
		var w = 64
		var h = 64

		var destX = line.x_3d + line.scale * line.sprite_decorations[0].pos_x * screen_width/2
		var destY = line.y_3d + 4
		var destW = 64 * line.width_3d / 266
		var destH = 64 * line.width_3d / 266

		destX += destW * line.sprite_decorations[0].pos_x
		destY += destH * (-1)

		var clipH = destY + destH - line.clip
		if clipH < 0:
			clipH = 0

		if clipH >= destH:
			line.sprite_decorations[0].sprite.hide()
			return

		#Setar as configurações de sprite aqui
		line.sprite_decorations[0].sprite.scale = Vector2(destW/w, destH/h)
		line.sprite_decorations[0].sprite.position = Vector2(destX, destY)
		line.sprite_decorations[0].sprite.show()
		print("Sprite aparece.")
	pass

func _draw():
	var result = pos + (speed * step) # Cálculo da posição levando em conta a velocidade

	#if result == 20000:#320000:
	#	result = 0
	print("result = ", result)
	var n_max = track_size * acceleration_view
	
	if(result >= n_max):
		result -= n_max
#	while result >= n_max:
#		result -= n_max
#
#	while result < 0:
#		result += n_max

	print("result depois das contas = ", result)
	pos = round(result)

	var start_point = (float(pos) / acceleration_view) - 1
	var cam_h = 1500 + lines[start_point].pos_y
	var cutoff = screen_height
	var track_curve = 0
	var x = 0
	var dx = 0
	playerX -= lines[start_point].curve_degrees * speed/ (top_speed/2) * step
#	print("current curve = ", lines[start_point].curve)
#	print("playerX = ", playerX)
#	print("speed = ", speed)

	for n in range(start_point, start_point + render_seg_num): #400 = field of view (quantidade de segmentos carregados)
		var num_pos = 0.0	
		if n >= track_size:
			num_pos = track_size * acceleration_view

		var l = line(lines[fmod(n, track_size)], 
			(playerX * road_width) - x, cam_h, pos - num_pos)

		var p = lines[fmod((n-1), track_size)]

		x += dx
		dx += l.curve_degrees
		l.clip = cutoff

		if l.y_3d >= cutoff:
			continue

		cutoff = l.y_3d

		# changing colors by position on screen
		if fmod((n/3), 2):
			border = Color(1,1,1)
			road = Color(0.42, 0.42, 0.42)
		else:
			border = Color(0,0,0)
			road = Color(0.4, 0.4, 0.4)

		if fmod((n/9), 2): 
			divid_line = Color(0,0,0,0)
			grass = Color(0.2, 0.2, 0.2)
		else:
			divid_line = Color(1,1,1)
			grass = Color(0.8, 0.8, 0.8)

		drawRoad(grass, 0, p.y_3d, screen_width, 0, l.y_3d, screen_width)
		drawRoad(border, p.x_3d, p.y_3d, p.width_3d * 1.2, l.x_3d, l.y_3d, l.width_3d * 1.2)
		drawRoad(road, p.x_3d, p.y_3d, p.width_3d, l.x_3d, l.y_3d, l.width_3d)
		drawRoad(divid_line, p.x_3d, p.y_3d, p.width_3d * 0.01, l.x_3d, l.y_3d, l.width_3d * 0.01)

	for n in range(start_point + render_seg_num, start_point, -1):
		_draw_sprite(lines[fmod(n, track_size)])
	pass

func _physics_process(delta):
	if Input.is_action_pressed("ui_up"):
		speed = speed + (acceleration * delta)
	elif Input.is_action_pressed("ui_down"):
		speed = speed + (breaking * delta)
	else:
		if speed > 0:
			speed = speed + (decel * delta) 
	speed = clamp(speed, 0, top_speed)

	if Input.is_action_pressed("ui_left"):
		playerX -= speedX * delta * 4
	elif Input.is_action_pressed("ui_right"):
		playerX += speedX * delta * 4

	update()
	pass
