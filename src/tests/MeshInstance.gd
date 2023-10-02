extends MeshInstance

var noise:OpenSimplexNoise = OpenSimplexNoise.new()

var width:int = 100
var height:int = width

const orthogonal_angles = [
	Vector3(0, 0, 0),
	Vector3(0, 0, PI/2),
	Vector3(0, 0, PI),
	Vector3(0, 0, -PI/2),
	Vector3(PI/2, 0, 0),
	Vector3(PI, -PI/2, -PI/2),
	Vector3(-PI/2, PI, 0),
	Vector3(0, -PI/2, -PI/2),
	Vector3(-PI, 0, 0),
	Vector3(PI, 0, -PI/2),
	Vector3(0, PI, 0),
	Vector3(0, PI, -PI/2),
	Vector3(-PI/2, 0, 0),
	Vector3(0, -PI/2, PI/2),
	Vector3(PI/2, 0, PI),
	Vector3(0, PI/2, -PI/2),
	Vector3(0, PI/2, 0),
	Vector3(-PI/2, PI/2, 0),
	Vector3(PI, PI/2, 0),
	Vector3(PI/2, PI/2, 0),
	Vector3(PI, -PI/2, 0),
	Vector3(-PI/2, -PI/2, 0),
	Vector3(0, -PI/2, 0),
	Vector3(PI/2, -PI/2, 0)
]

func _ready():
	generate()
	pass

func _input(event):
	if event is InputEventKey:
		var evt:InputEventKey = event
		if evt.scancode == KEY_SPACE and evt.pressed:
			generate()
	pass

func generate():
	width = 60
	height = width
	$"../Camera".global_transform.origin.y = width*8
	$"../Camera".far = width*1.7*10
	$GridMap.clear()
	(mesh as PlaneMesh).size.x = width*10
	(mesh as PlaneMesh).size.y = height*10
	noise.period = 14.0
	noise.octaves = 8
	noise.lacunarity = 0.1
	randomize()
	noise.seed = randi()
	var _image:Image = Image.new()
	_image.create(width, height, false, Image.FORMAT_RGB8)
	_image.lock()
	for i in range(width):
		for j in range(height):
			var value = noise.get_noise_2d(i, j)
			if value > -0.0:
				_image.set_pixel(i, j, Color.black)
			else:
				_image.set_pixel(i, j, Color.white)
	apply_cellular_automaton(_image, 10)
	find_edges(_image)
	find_corners(_image)
	
	for i in range(_image.get_width()):
		for j in range(_image.get_height()):
			var tile = 0
			var z = 0
			var orientation = 0
			var px:Color = _image.get_pixel(i, j)
			if px == Color.red:
				var vec_rot:Vector2 = Vector2.ZERO
				for x in [-1, 1]:
					var px_l = _image.get_pixel(i + x, j)
					if px_l == Color.white:
						vec_rot.x += x
				for y in [-1, 1]:
					var px_l = _image.get_pixel(i, j + y)
					if px_l == Color.white:
						vec_rot.y += y
				var angle = vec_rot.angle()
				match int(rad2deg(angle)):
					0:
						tile = 10
						orientation = 16
					90:
						tile = 10
						orientation = 0
					-90:
						tile = 10
						orientation = 10
					180:
						tile = 10
						orientation = 22
					45:
						tile = 11
						orientation = 16
					-45:
						tile = 11
						orientation = 10
					135:
						tile = 11
						orientation = 0
					-135:
						tile = 11
						orientation = 22
			elif px == Color.black:
				z = 1
				tile = 6
			elif px == Color.yellow:
				tile = 12
				var vec_rot:Vector2 = Vector2.ZERO
				for x in [-1, 1]:
					var px_l = _image.get_pixel(i + x, j)
					if px_l == Color.red:
						vec_rot.x += x
				for y in [-1, 1]:
					var px_l = _image.get_pixel(i, j + y)
					if px_l == Color.red:
						vec_rot.y += y
				var angle = vec_rot.angle()
				print(int(rad2deg(angle)))
				match int(rad2deg(angle)):
					45: orientation = 16
					-45: orientation = 10
					135: orientation = 0
					-135:orientation = 22
			$GridMap.set_cell_item(
				i - _image.get_width()/2, 
				z, 
				j - _image.get_height()/2, 
				tile, 
				orientation)
			
	_image.unlock()
	var img_tex:ImageTexture = ImageTexture.new()
	img_tex.create_from_image(_image, ImageTexture.FLAG_CONVERT_TO_LINEAR)
	get_surface_material(0).albedo_texture = img_tex
	get_surface_material(0).albedo_color = Color.white
	pass

func apply_cellular_automaton(_image:Image, iterations:int):
	for k in range(iterations):
		var temp_image:Image = _image.duplicate(true)
		temp_image.lock()
		for i in range(_image.get_width()):
			for j in range(_image.get_height()):
				var neighbor_wall_count = 0
				for x in range(i-1, i+2):
					for y in range(j-1, j+2):
						if x >= 0 and x < _image.get_width() and \
						   y >= 0 and y < _image.get_height():
							if temp_image.get_pixel(x, y) == Color.black:
								neighbor_wall_count += 1
						else:
							neighbor_wall_count += 1
				if neighbor_wall_count > 4:
					_image.set_pixel(i, j, Color.black)
				else:
					_image.set_pixel(i, j, Color.white)
		temp_image.unlock()
	pass

func expand(_image:Image):
	for i in range(_image.get_width()):
		for j in range(_image.get_height()):
			if _image.get_pixel(i, j) == Color.red:
				_image.set_pixel(i, j, Color.black)

func find_corners(_image:Image):
	for i in range(_image.get_width()):
		for j in range(_image.get_height()):
			var count_red:int = 0
			if _image.get_pixel(i, j) == Color.black:
				for x in [-1, 1]:
					if _image.get_pixel(i + x, j) == Color.red:
						count_red += 1
				for y in [-1, 1]:
					if _image.get_pixel(i, j + y) == Color.red:
						count_red += 1
			if count_red >= 2:
				_image.set_pixel(i, j, Color.yellow)

func find_edges(_image:Image):
	var img_temp:Image = _image.duplicate(true)
	img_temp.lock()
	for i in range(img_temp.get_width()):
		for j in range(img_temp.get_height()):
			#Horizontal
			if 	img_temp.get_pixel(i - 1, j) == Color.black and \
				img_temp.get_pixel(i, j) == Color.white:
				_image.set_pixel(i, j, Color.red)
			if 	img_temp.get_pixel(i, j) == Color.white and \
				img_temp.get_pixel(i + 1, j) == Color.black:
				_image.set_pixel(i, j, Color.red)
			
			#Vertical
			if 	img_temp.get_pixel(i, j - 1) == Color.black and \
				img_temp.get_pixel(i, j) == Color.white:
				_image.set_pixel(i, j, Color.red)
			if 	img_temp.get_pixel(i, j) == Color.white and \
				img_temp.get_pixel(i, j + 1) == Color.black:
				_image.set_pixel(i, j, Color.red)
	img_temp.unlock()

func _orthogonal_to_index(input:Vector3)->int:
	for i in range(orthogonal_angles.size()):
		if input == orthogonal_angles[i]:
			return i
	return -1
