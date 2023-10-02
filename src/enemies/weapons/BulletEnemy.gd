extends MeshInstance

onready var direction:Vector3 = -global_transform.basis.z
var enabled:bool = true

func _ready():
	pass

func _physics_process(delta):
	if enabled:
		global_transform.origin += direction/15
	pass

func _on_Timer_timeout():
	queue_free()
	pass

func _on_Area_body_entered(body):
	enabled = false
	queue_free()
	pass
