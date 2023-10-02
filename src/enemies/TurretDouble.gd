extends Spatial

class_name Turret

signal turret_down

var target:Spatial = null
var bullet = load("res://src/enemies/weapons/BulletEnemy.tscn")

var nozzle_turn:int = 0
onready var nozzle_list:Array = [
	$turret_double/hinge/turret/NzLd,
	$turret_double/hinge/turret/NzLu,
	$turret_double/hinge/turret/NzRd,
	$turret_double/hinge/turret/NzRu
]

var health:int = 4
var enabled:bool = true

func _ready():
	pass

func _physics_process(delta):
	if target != null and enabled:
		$turret_double/hinge.look_at(
			target.global_transform.origin,
			Vector3.UP
		)
	pass

func _on_Area_body_entered(body):
	if body.is_in_group("Player"):
		target = body
	pass

func _on_Area_body_exited(body):
	if body.is_in_group("Player"):
		target = null
		$turret_double/hinge/turret/Smoke.emitting = false
	pass

func _on_TimerShots_timeout():
	if target != null and enabled:
		if nozzle_turn < nozzle_list.size() - 1:
			nozzle_turn += 1
		else:
			nozzle_turn = 0
		_fire(nozzle_list[nozzle_turn])
	pass

func _fire(from:Position3D):
	$turret_double/hinge/turret/Smoke.global_transform.origin = from.global_transform.origin
	$turret_double/hinge/turret/Smoke.restart()
	$turret_double/hinge/turret/Smoke.emitting = true
	var _bullet = bullet.duplicate(true)
	var bullet_r:Spatial = bullet.instance()
	from.add_child(bullet_r)
	bullet_r.set_as_toplevel(true)
	pass

func hit(damage:int):
	health -= 1
	if health <= 0 and enabled:
		enabled = false
		$Explosion.emitting = true
		$Smoke.emitting = true
		emit_signal("turret_down")
	pass
