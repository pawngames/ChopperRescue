extends MeshInstance

onready var direction:Vector3 = Vector3.DOWN/10

var enabled:bool = true

func _ready():
	pass

func _physics_process(delta):
	if enabled:
		global_transform.origin += direction
	pass

func _on_Timer_timeout():
	queue_free()
	pass

func _on_Area_body_entered(body:Spatial):
	if !body.is_in_group("Player") and \
		!body.is_in_group("EnemyWeapon") and \
		!body.is_in_group("PlayerWeapon"):
		if body.get_parent().has_method("hit"):
			body.get_parent().hit(5)
		$Smoke.emitting = true
		enabled = false
		$Model.visible = false
		yield(get_tree().create_timer(1.0), "timeout")
		queue_free()
	pass
