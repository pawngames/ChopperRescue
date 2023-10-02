extends Spatial

signal hostage_rescued()

export var hostage_scene:PackedScene

func _ready():
	pass

func _on_LandingArea_area_entered(area):
	if area.is_in_group("Player"):
		var player = area.get_parent()
		while (player.hostages > 0):
			print(player.hostages)
			_spawn_hostage(
				0.0, 0.0, 
				$HostageLanding.global_transform.origin)
			player.set_hostages(player.hostages - 1)
			yield(get_tree().create_timer(1.0), "timeout")
	pass

func _spawn_hostage(x:int, y:int, position:Vector3):
	var hostage:Spatial = hostage_scene.duplicate(true).instance()
	$Hostages.add_child(hostage)
	hostage.global_transform.origin = position
	hostage.global_transform.origin.x += x
	hostage.global_transform.origin.z += y
	hostage.set_follow(
		$Navigation, 
		$Navigation.to_local(
			$RescueArea.global_transform.origin))
	pass

func rescued():
	emit_signal("hostage_rescued")
