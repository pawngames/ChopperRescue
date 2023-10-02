extends Control

var labels:Array = []
var targets:Dictionary = {}
onready var camera:Camera = get_viewport().get_camera()

onready var turret_marker = $Target

func _ready():
	_add_targets(get_tree().get_nodes_in_group("Turrets"), $TurretMarker)
	_add_targets(get_tree().get_nodes_in_group("Enemy_Base"), $EnemyBaseMarker)
	pass

func _add_targets(_targets:Array, _marker:Sprite):
	for target in _targets:
		var new_marker = _marker.duplicate(true)
		var position = camera.unproject_position(
				target.global_transform.origin
			)
		targets[target] = new_marker
		add_child(new_marker)
		new_marker.show()
		new_marker.set_global_position(position)
	pass

func _process(delta):
	camera = get_viewport().get_camera()
	for target in targets:
		if !camera.is_position_behind(target.global_transform.origin):
			var position = camera.unproject_position(
					target.global_transform.origin
				)
			targets[target].set_global_position(position)
			if target.get_parent() is Turret:
				if !target.get_parent().enabled:
					targets[target].visible = false
			elif target is EnemyBase:
				if !target.enabled:
					targets[target].visible = false
				var hostage_count = target.get_node("Hostages").get_child_count()
				targets[target].get_node("Label").text = "Hostages: " + str(hostage_count)
				
	pass

