class_name CharacterAggroManager extends Node

signal on_aggro_changed(value: float)

@export var _build_speed_seconds: float = 3.0
@export var _decay_speed_seconds: float = 5.0

# aggro is an internal value that ranges from 0 to 100
var _aggro: float = 0:
	set(value):
		_aggro = value
		on_aggro_changed.emit(_aggro)
var _is_aggroed: bool = false

func build_aggro(delta: float):
	_aggro = _aggro + ((100.0 / _build_speed_seconds) * delta)
	if _aggro > 100.0:
		_aggro = 100.0
		_is_aggroed = true
func decay_aggro(delta: float):
	_aggro = _aggro - ((100.0 / _decay_speed_seconds) * delta)
	if _aggro < 0.0:
		_aggro = 0.0
		_is_aggroed = false

func is_aggroed() -> bool:
	return _is_aggroed
func get_aggro() -> float:
	return _aggro
