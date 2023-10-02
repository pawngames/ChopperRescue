extends Spatial

class_name EnemyBase

signal enemy_base_clear

var base_opened:bool = true
onready var hostages_target:Spatial = $HostageSpawn
export var hostage_scene:PackedScene

var enabled:bool = true

func _ready():
	#_spawn_hostage(0,0, $HostageSpawn.global_transform.origin)
	_spawn_hostages()
	pass

func _on_LandingArea_area_entered(area:Area):
	if area.is_in_group("Player") and base_opened:
		print("Landed")
		hostages_target = area
		for child in $Hostages.get_children():
			child.set_follow(
				$Navigation, 
				$Navigation.to_local(
					area.global_transform.origin
			))
	pass

func _on_LandingArea_area_exited(area:Area):
	if area.is_in_group("Player") and base_opened:
		print("Exited")
		for child in $Hostages.get_children():
			child.set_follow(
				$Navigation, 
				$Navigation.to_local(
					$HostageSpawn.global_transform.origin))
	enabled = $Hostages.get_child_count() > 0
	if !enabled:
		emit_signal("enemy_base_clear")
	pass

func _spawn_hostages():
	for x in range(-5, 5):
		#for y in range(-1, 2):
		_spawn_hostage(x, 0, $HostageSpawn.global_transform.origin)
	pass

func _spawn_hostage(x:int, y:int, position:Vector3):
	var hostage:Spatial = hostage_scene.duplicate(true).instance()
	$Hostages.add_child(hostage)
	hostage.global_transform.origin = position
	hostage.global_transform.origin.x += x
	hostage.global_transform.origin.z += y
	hostage.on_base = false
	pass
