extends KinematicBody

export (NodePath) var perimeter_path
onready var perimeter:Path = get_node(perimeter_path)
onready var perimeter_curve:Curve3D = perimeter.curve

var path_index:int = 0
var speed:float = 8.0

func _ready():
	pass

func _process(delta):
	var _actual_pos = global_transform.origin
	var next_pos = perimeter_curve.get_point_position(
		path_index) + get_parent().global_transform.origin
	next_pos.y = _actual_pos.y
	look_at(next_pos, Vector3.UP)
	if _actual_pos.distance_to(next_pos) < 0.5:
		if path_index < perimeter_curve.get_point_count():
			path_index += 1
		if path_index >= perimeter_curve.get_point_count():
			path_index = 0
	var direction:Vector3 = -transform.basis.z*speed
	direction += Vector3.DOWN*30
	move_and_slide(direction)
	pass
