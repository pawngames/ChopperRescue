extends TextureRect

#based on kids can code minimap tutorial

export (NodePath) var player

var turrets:Array
var enemy_bases:Array
var bases:Array
var landing_zones:Array

onready var player_marker = $PlayerMarker
onready var turret_marker = $TurretMarker
onready var base_marker = $BaseMarker
onready var enemy_base_marker = $EnemyBaseMarker
onready var landing_marker = $LandingZoneMarker
onready var turret_down_marker = $LandingZoneMarker
onready var icons = {
	"turret": turret_marker, 
	"base":base_marker,
	"enemy_base":enemy_base_marker,
	"landing_zone":landing_marker,
	"turret_down":turret_down_marker,
}
var markers = {}

var grid_scale:float = 0.5

func _ready():
	player_marker.position = rect_size / 2
	_create_markers()
	pass

func _create_markers():
	_get_markers(
		get_tree().get_nodes_in_group("Turrets"), 
		"turret")
	
	_get_markers(
		get_tree().get_nodes_in_group("Base"), 
		"base")
	
	_get_markers(
		get_tree().get_nodes_in_group("Enemy_Base"), 
		"enemy_base")
	
	_get_markers(
		get_tree().get_nodes_in_group("Landing_Zone"), 
		"landing_zone")
	pass

func _get_markers(elements:Array, type:String):
	for element in elements:
		var new_marker = icons[type].duplicate(true)
		$Markers.add_child(new_marker)
		new_marker.show()
		markers[element] = new_marker
	pass

func update():
	for marker in markers:
		if marker.get_parent().has_signal("turret_down") and !marker.get_parent().enabled:
			var _tex:Texture = load("res://assets/2d/down_marker.png")
			markers[marker].texture = _tex
		elif marker is EnemyBase:
			if !marker.enabled:
				var _tex:Texture = load("res://assets/2d/down_marker.png")
				markers[marker].texture = _tex
	pass

func _process(delta):
	# Arrow texture points upwards, so add 90 degrees.
	player_marker.rotation = -get_node(player).rotation.y + PI
	for item in markers:
		var item_pos:Vector2 = Vector2(
			item.global_transform.origin.x,
			item.global_transform.origin.z)
		var player_pos:Vector2 = Vector2(
			get_node(player).global_transform.origin.x,
			get_node(player).global_transform.origin.z)
		var obj_pos = (item_pos - player_pos) * grid_scale + rect_size / 2
		# If marker is outside grid, hide or shrink it.
		if get_rect().has_point(obj_pos + rect_position):
			markers[item].scale = Vector2(1, 1)
#			markers[item].show()
		else:
			markers[item].scale = Vector2(0.75, 0.75)
#			markers[item].hide()
		# Don't draw markers outside grid rectangle.
		obj_pos.x = clamp(obj_pos.x, 0, rect_size.x)
		obj_pos.y = clamp(obj_pos.y, 0, rect_size.y)
		markers[item].position = obj_pos
