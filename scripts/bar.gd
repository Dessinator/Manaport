class_name Bar extends Control

@export var _progress_bar_gradient: GradientTexture1D
@export var _name: String

@onready var _texture_progress_bar = $TextureProgressBar
@onready var _label = $TextureProgressBar/Label

func _ready():
	_texture_progress_bar.texture_progress = _progress_bar_gradient
	_label.text = _name + ": ???"

func set_label_value(value: int):
	_label.text = "{name}: {v}".format({name = _name, v = value})
func set_max_value(value: int):
	_texture_progress_bar.max_value = value
func set_value(value: int):
	_texture_progress_bar.value = value
