extends Spatial

export var follow_obj_path:NodePath
onready var follow_obj:Spatial = get_node(follow_obj_path)
var camera_pitch = 0.0
var camera_yaw = 0.0
var sensitivity:float = 50.0

func _ready():
	pass

func _physics_process(delta):
	
	global_transform.origin = global_transform.origin.linear_interpolate(
		follow_obj.global_transform.origin,
		0.5
	)
	
	if 	Input.is_action_pressed("cam_pitch_up") or \
		Input.is_action_pressed("cam_pitch_down") or \
		Input.is_action_pressed("cam_yaw_right") or \
		Input.is_action_pressed("cam_yaw_left"):
		camera_pitch += Input.get_action_strength("cam_pitch_up")/sensitivity
		camera_pitch -= Input.get_action_strength("cam_pitch_down")/sensitivity
		camera_yaw += Input.get_action_strength("cam_yaw_right")/sensitivity
		camera_yaw -= Input.get_action_strength("cam_yaw_left")/sensitivity
	else:
		camera_pitch = lerp_angle(camera_pitch, 0.0, .1)
		camera_yaw = lerp_angle(camera_yaw, 0.0, .1)
	
	camera_pitch = clamp(camera_pitch, 0, PI/3)
	camera_yaw = clamp(camera_yaw, -PI/3, PI/3)
	
	rotation.y = lerp_angle(rotation.y, follow_obj.rotation.y + camera_yaw, 0.1)
	rotation.x = lerp_angle(rotation.x, camera_pitch, 0.1)

