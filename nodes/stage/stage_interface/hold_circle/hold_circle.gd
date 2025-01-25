class_name HoldCircle extends Control

@onready var _progress_bar: TextureProgressBar = %TextureProgressBar

func _process(_delta):
	position = get_viewport().get_mouse_position()

func set_progress(value: float, istart: float, istop: float):
	_progress_bar.value = remap(value, istart, istop, 0.0, 1.0)
