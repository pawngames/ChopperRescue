extends MeshInstance

onready var direction:Vector3 = -global_transform.basis.z

func _ready():
	pass

func _physics_process(delta):
	global_transform.origin += direction
	pass

func _on_Timer_timeout():
	queue_free()
	pass

func _on_Area_body_entered(body):
	$Smoke.emitting = true
	pass
