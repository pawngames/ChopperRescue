extends KinematicBody

var path:Array = []
var path_node:int = 0

var nav:Navigation = null
var target:Vector3

var speed:float = 6.0
var on_base:bool = true

func _ready():
	pass

func set_follow(_nav:Navigation, _target_new:Vector3):
	target = _target_new
	nav = _nav
	_move_to(target)
	pass

func _physics_process(delta):
	if path_node < path.size():
		var direction:Vector3 = transform.origin.direction_to(path[path_node])
		#Navmesh does not rotate afetr baked
		#Rotation is necessary for maintaining correct direction
		direction = direction.rotated(
			Vector3.UP, get_parent().get_parent().rotation.y)
		direction += Vector3.DOWN
		if transform.origin.distance_to(path[path_node]) < 1:
			path_node += 1
		else:
			move_and_slide(direction.normalized()*speed, Vector3.UP)
			var from:Vector2 = Vector2(
				direction.x, 
				direction.z)
			var to:Vector2 = Vector2(
				target.x, 
				target.z)
			var angle = from.angle_to(to)
			rotation.y = angle - PI/2

func _move_to(_target_pos:Vector3):
	if is_instance_valid(nav):
		path = nav.get_simple_path(
			transform.origin,
			_target_pos)
		path_node = 0

func _on_Area_area_entered(area):
	if area.is_in_group("Player") and not on_base:
		var chopper = area.get_parent()
		if chopper.hostages < chopper.MAX_HOSTAGES:
			chopper.set_hostages(chopper.hostages + 1)
			queue_free()
		else:
			set_follow(nav, transform.origin)
	
	if area.is_in_group("RescueZone") and on_base:
		area.get_parent().rescued()
		queue_free()
	pass

