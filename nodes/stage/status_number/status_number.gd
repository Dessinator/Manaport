class_name StatusNumber extends Node3D

signal end

@onready var _label = $SubViewport/Label

const STATUS_NUMBER_SCENE = preload("res://nodes/stage/status_number/status_number.tscn")

# key data dict:
# {
#	heal: bool
#	amount: int
#	crit: bool
#	element: Element.Type
# }
static func create_status_number(parent: Node, data: Dictionary):
	var status_number = STATUS_NUMBER_SCENE.instantiate()
	parent.add_child(status_number)

	var string = str(data["amount"])
	string = string + "!" if data["crit"] else string + ""
	status_number._label.text = string

	var rand_x = randf_range(-1, 1)
	var rand_y = randf_range(-1, 1)
	var rand_z = randf_range(-1, 1)
	var tween = status_number.create_tween()
	tween.tween_property(status_number, "position", Vector3(rand_x, rand_y, rand_z), 1)

func _on_end():
	end.emit()
