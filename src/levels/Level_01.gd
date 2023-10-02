extends Spatial

var rescued:int = 0

func _ready():
	for turret in get_tree().get_nodes_in_group("Turrets"):
		turret.get_parent().connect("turret_down", self, "_update_minimap")
	for turret in get_tree().get_nodes_in_group("Enemy_Base"):
		turret.connect("enemy_base_clear", self, "_update_minimap")
	pass

func _update_minimap():
	print("update")
	$CanvasLayer/MiniMap.update()
	pass

func _process(delta):
	pass

func _on_Chopper_hostage_io(count):
	$CanvasLayer/TopUI/VBoxContainer/Transporting.set_text(str(count))
	pass

func _on_Base_hostage_rescued():
	rescued += 1
	$CanvasLayer/TopUI/VBoxContainer/Rescued.set_text(str(rescued))
	pass # Replace with function body.
