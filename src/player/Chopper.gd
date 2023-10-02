extends RigidBody

signal hostage_io(count)

var force:Vector3 = Vector3.ZERO
var torque:Vector3 = Vector3.ZERO

export var force_intensity:float = 0.0
export var torque_intensity:float = 0.0

var rotation_body:float = PI/4

var bullet = load("res://src/player/weapons/Bullet.tscn")
var bomb = load("res://src/player/weapons/Bomb.tscn")
var firing:bool = false

var MAX_HOSTAGES:int = 5
var hostages:int = 1

func _ready():
	$AudioStreamPlayer.play()
	pass

func _process(delta):
	var rot_body = Vector3.ZERO
	if global_transform.origin.y < 30:
		if Input.is_action_pressed("throttle_up"):
			force.y += force_intensity/2
		if Input.is_action_pressed("throttle_down"):
			force.y -= force_intensity/2
	else:
		force.y = lerp(force.y, 0.0, 0.1)

	if Input.is_action_just_pressed("camera_change"):
		$BodyMesh/Camera.current = !$BodyMesh/Camera.current
	
	if !_is_on_floor():
		var pitch = Input.get_action_strength("pitch_down")
		pitch -= Input.get_action_strength("pitch_up")
		if pitch != 0:
			force += global_transform.basis.z*force_intensity*pitch
			rot_body.x += rotation_body/2*pitch
		
		var roll = Input.get_action_strength("roll_left")
		roll -= Input.get_action_strength("roll_right")
		if roll != 0:
			force += global_transform.basis.x*force_intensity*roll
			rot_body.z -= rotation_body*roll
		
		#keyboard controls
		if Input.is_action_pressed("ui_up"):
			force += global_transform.basis.z*force_intensity
			rot_body.x += rotation_body/2
		elif Input.is_action_pressed("ui_down"):
			force -= global_transform.basis.z*force_intensity
			rot_body.x -= rotation_body/2
		
		if Input.is_action_pressed("ui_left"):
			force += global_transform.basis.x*force_intensity
			rot_body.z -= rotation_body
		elif Input.is_action_pressed("ui_right"):
			force -= global_transform.basis.x*force_intensity
			rot_body.z += rotation_body
		
		if Input.is_action_pressed("yaw_left"):
			torque.y += torque_intensity
		elif Input.is_action_pressed("yaw_right"):
			torque.y -= torque_intensity
		
		if Input.is_action_just_pressed("weapon_2"):
			_bomb()
		
	firing = Input.is_action_pressed("weapon_1")
	
	rot_body.x = clamp(rot_body.x, -PI, PI)
	rot_body.z = clamp(rot_body.z, -PI, PI)
	rot_body.y = PI
		
	$BodyMesh.rotation = $BodyMesh.rotation.linear_interpolate(-rot_body, 0.05)
	$BodyMesh/CopterTop.rotation.y += force.length() + 0.3
	$BodyMesh/CopterTop2.rotation.x += torque.length() + 0.3
	
	force = force.linear_interpolate(Vector3.ZERO, 0.03)
	torque = torque.linear_interpolate(Vector3.ZERO, 0.3)
	
	$AudioStreamPlayer.pitch_scale = force.y/15 + 0.75
	
	pass

func _is_on_floor()->bool:
	var on_floor = $RayCast.is_colliding()
	axis_lock_angular_y = on_floor
	var smoke:bool = $BodyMesh/RayCastSmoke.is_colliding()
	$LandingSmoke.emitting = smoke
	if smoke:
		$LandingSmoke.global_transform.origin = $BodyMesh/RayCastSmoke.get_collision_point()
		$LandingSmoke.global_transform = align_with_y(
			$LandingSmoke.global_transform,
			$BodyMesh/RayCastSmoke.get_collision_normal()
		)
	return on_floor

func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform

func _bomb():
	var _bomb = bomb.duplicate(true)
	var bomb_instance:Spatial = _bomb.instance()
	$BombDrop.add_child(bomb_instance)
	bomb_instance.set_as_toplevel(true)
	pass

func _physics_process(delta):
	apply_central_impulse(force)
	apply_torque_impulse(torque)

func _on_Area_area_entered(area):
	if area.is_in_group("EnemyWeapon"):
		print("hit")
		$SmokeDamage.restart()
		$SmokeDamage.emitting = true
		torque += Vector3(
				rand_range(-1.0, 1.0),
				rand_range(-1.0, 1.0),
				rand_range(-1.0, 1.0)
			)*25.0
	pass # Replace with function body.

func set_hostages(_hostages):
	hostages = _hostages
	emit_signal("hostage_io", hostages)
	pass

func _on_TimerShots_timeout():
	if firing:
		var _bullet = bullet.duplicate(true)
		var bullet_l:Spatial = _bullet.instance()
		$BodyMesh/CanonLeft.add_child(bullet_l)
		bullet_l.set_as_toplevel(true)
		var bullet_r:Spatial = _bullet.instance()
		$BodyMesh/CanonRight.add_child(bullet_r)
		bullet_r.set_as_toplevel(true)
	$MachineGun.playing = firing
	pass
