class_name CharacterAggroVisual extends Node3D

@onready var _texture_progress_bar: TextureProgressBar = %TextureProgressBar

var _value: float:
	set(value):
		_value = value
		_texture_progress_bar.value = _value

func set_value(value: float):
	_value = value
