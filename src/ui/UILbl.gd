extends HBoxContainer

tool
class_name UILabel

export var label:String = "label:"

func _ready():
	$Lbl.text = label
	pass

func set_text(_text:String):
	$Text.text = _text
