class_name ActorStats extends Resource

@export var _substat_curves: ActorSubstatCurves

@export var _wards: Array[StatusEffect]
@export var _weaknesses: Array[ActorWeakness]

@export_range(1, 100) var _ATTK: int ## Attack
@export_range(1, 100) var _DFNS: int ## Defense
@export_range(1, 100) var _VTLY: int ## Vitality

var _attk_constant: int = 0
var _dfns_constant: int = 0
var _vtly_constant: int = 0

func initialize():
	_substat_curves = _substat_curves.duplicate()

func set_attk_constant(constant_value: int):
	_attk_constant = constant_value
func set_dfns_constant(constant_value: int):
	_dfns_constant = constant_value
func set_vtly_constant(constant_value: int):
	_vtly_constant = constant_value

func get_attk_constant() -> int:
	return _attk_constant
func get_dfns_constant() -> int:
	return _dfns_constant
func get_vtly_constant() -> int:
	return _vtly_constant

func get_attk(base_value: bool, as_percentage: bool) -> float:
	if base_value:
		if as_percentage:
			return (float(_ATTK) / 100)
		return _ATTK

	if as_percentage:
		return (float(_ATTK  + _attk_constant) / 100)
	return _ATTK + _attk_constant
func get_dfns(base_value: bool, as_percentage: bool) -> float:
	if base_value:
		if as_percentage:
			return (float(_DFNS) / 100)
		return _DFNS

	if as_percentage:
		return (float(_DFNS  + _dfns_constant) / 100)
	return _DFNS + _dfns_constant
func get_vtly(base_value: bool, as_percentage: bool) -> float:
	if base_value:
		if as_percentage:
			return (float(_VTLY) / 100)
		return _VTLY

	if as_percentage:
		return (float(_VTLY  + _vtly_constant) / 100)
	return _VTLY + _vtly_constant

func get_wards() -> Array[StatusEffect]:
	return _wards
func get_weaknesses() -> Array[ActorWeakness]:
	return _weaknesses

func get_substat_curves() -> ActorSubstatCurves:
	return _substat_curves
