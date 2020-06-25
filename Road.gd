extends Node2D

var screen_width = 1024
var screen_height = 680

var road_width = 2000
var seg = 200 #Velocity (smaller number = faster)
var track_size = 1600 # Number of road segments
var render_seg_num = 300

var speed = 200
var step = float(1) / 60
var top_speed#seg / delta * 1.5
var acceleration
var breaking
var decel
var field_of_view = 100.0
var cam = 0.8 #Depth of the camera
var lines = []
var grass
var road
var border
var divid_line
var pos = 0
var skyline
var skln_pos = 0
var skln_height = 0
var playerX = 0
var speedX = .7

func _ready():
	top_speed = float(seg) / step * 1.5
	acceleration = float(top_speed) / 4
	breaking = -top_speed
	decel = float(-top_speed) / 5
	cam = 1 / tan((field_of_view / 2) * PI / 180)
	
	# Drawing Road
#	print("Criando pista...")
	for i in range(track_size):# Quantity of horizontal lines on the road
		lines.push_back({x = 0, y = 0, z = 0, X = 0, Y = 0, W = 0, scale = 0, curve = 0, sprite = null, spriteX = 0, clip = 0.0})
		lines[i].z = i * seg
		if i != 0 and track_size % i == 0:
			lines[i].sprite = Sprite.new()
			lines[i].sprite.texture = load("res://icon.png")
			lines[i].sprite.hide()
			$YSort.add_child(lines[i].sprite)
		lines[i].spriteX = -3.5
		if i > 300 and i < 700: #Right curve
			lines[i].curve = 0.5
		if i > 800 and i < 1200: #Left curve
			lines[i].curve = -0.7
		if i > 750: #Cliffs
			lines[i].y = sin(i / 30.0 - 25) * 1500
		if i > 1200: #Right curve
			lines[i].curve = 0.2

	track_size = lines.size()
	set_process(true)
	pass

func line(segment, cam_x, cam_y, cam_z):
	if ((segment.z) - cam_z) != 0:
		segment.scale = abs(cam / (segment.z - cam_z)) 
	segment.X = (1 + segment.scale * (segment.x - cam_x)) * screen_width/ 2
	segment.Y = (1 - segment.scale * (segment.y - cam_y)) * screen_height/ 2
	segment.W = segment.scale * road_width * (screen_width / 2)
	return segment
	
func drawRoad(col, x1, y1, w1, x2, y2, w2):
	var point = [Vector2(int(x1-w1), int(y1)), Vector2(int(x2-w2), int(y2)),
	Vector2(int(x2+w2), int(y2)), Vector2(int(x1+w1), int(y1))]
	
	draw_primitive(PoolVector2Array(point), PoolColorArray([col, col, col, col, col]), PoolVector2Array([]))
	pass

func _draw_sprite(line):
	if line.sprite != null:
		var w = 64
		var h = 64
		
		var destX = line.X + line.scale * line.spriteX * screen_width/2
		var destY = line.Y + 4
		var destW = 64 * line.W / 266
		var destH = 64 * line.W / 266
		
		destX += destW * line.spriteX
		destY += destH * (-1)
		
		var clipH = destY + destH - line.clip
		if clipH < 0:
			clipH = 0
		
		if clipH >= destH:
			line.sprite.hide()
			return
		
		#Setar as configurações de sprite aqui
		line.sprite.scale = Vector2(destW/w, destH/h)
		line.sprite.position = Vector2(destX, destY)
		line.sprite.show()
	pass

func _draw():
	var result = pos + (speed * step)#200

	if result == 320000:#320000:
		result = 0
	var n_max = track_size * seg
	while result >= n_max:
		result -= n_max

	while result < 0:
		result += n_max
#	
	pos = round(result)
	
	var start_point = (float(pos) / seg) - 1
	var cam_h = 1500 + lines[start_point].y
	var cutoff = screen_height
	var track_curve = 0
	var x = 0
	var dx = 0
	playerX -= lines[start_point].curve * speed/top_speed * step
#	print("current curve = ", lines[start_point].curve)
#	print("playerX = ", playerX)
#	print("speed = ", speed)
	
	for n in range(start_point, start_point + render_seg_num): #400 = field of view (quantidade de segmentos carregados)
		var num_pos = 0.0	
		if n >= track_size:
			num_pos = track_size * seg

		var l = line(lines[fmod(n, track_size)], (playerX * road_width) - x, cam_h, pos - num_pos)
		var p = lines[fmod((n-1), track_size)]

		x += dx
		dx += l.curve
		l.clip = cutoff

		if l.Y >= cutoff:
			continue

		cutoff = l.Y

		# changing colors by position on screen
		if fmod((n/3), 2):
			border = Color(1,1,1)
			road = Color(0.42, 0.42, 0.42)
		else:
			border = Color(0,0,0)
			road = Color(0.4, 0.4, 0.4)

		if fmod((n/9), 2): 
			divid_line = Color(0,0,0)
			grass = Color(0.2, 0.2, 0.2)
		else:
			divid_line = Color(1,1,1)
			grass = Color(0.8, 0.8, 0.8)
			
		drawRoad(grass, 0, p.Y, screen_width, 0, l.Y, screen_width)
		drawRoad(border, p.X, p.Y, p.W * 1.2, l.X, l.Y, l.W * 1.2)
		drawRoad(road, p.X, p.Y, p.W, l.X, l.Y, l.W)
		drawRoad(divid_line, p.X, p.Y, p.W * 0.01, l.X, l.Y, l.W * 0.01)
	
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
		playerX -= speedX * step
	elif Input.is_action_pressed("ui_right"):
		playerX += speedX * step
		
	update()
	pass
