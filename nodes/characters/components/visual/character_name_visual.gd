extends Node3D

@export var _name_source: Node

@onready var _label: Label = %Label

func _ready() -> void:
	_label.text = _name_source.name
