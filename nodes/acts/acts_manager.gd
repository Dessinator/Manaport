class_name ActsManager extends Node

@export var _basic_move: PackedScene
@export var _enhanced_basic_move: PackedScene
@export var _skill_1: PackedScene
@export var _skill_2: PackedScene

var _use_enhanced_basic_move: bool

var _cached_basic_move_name: String
var _cached_enhanced_basic_move_name: String
var _cached_skill_1_name: String
var _cached_skill_2_name: String

func _ready():
	var pool = ActsPool.get_instance()
	if _basic_move: _cached_basic_move_name = pool.add_to_pool(_basic_move).name
	if _enhanced_basic_move: _cached_enhanced_basic_move_name = pool.add_to_pool(_enhanced_basic_move).name
	if _skill_1: _cached_skill_1_name = pool.add_to_pool(_skill_1).name
	if _skill_2: _cached_skill_2_name = pool.add_to_pool(_skill_2).name

func get_basic_move_instance() -> Act:
	var instance
	if _use_enhanced_basic_move:
		instance = ActsPool.get_instance().take_from_pool(_cached_enhanced_basic_move_name)
	else:
		instance = ActsPool.get_instance().take_from_pool(_cached_basic_move_name)
	add_child(instance)
	return instance as Act
func get_skill_1_instance() -> Act:
	var instance = ActsPool.get_instance().take_from_pool(_cached_skill_1_name)
	add_child(instance)
	return instance as Act
func get_skill_2_instance() -> Act:
	var instance = ActsPool.get_instance().take_from_pool(_cached_skill_2_name)
	add_child(instance)
	return instance as Act

func enhance_basic_attack():
	_use_enhanced_basic_move = true
func revert_basic_attack():
	_use_enhanced_basic_move = false

func set_basic_move(basic_move):
	_basic_move = basic_move
func set_skill_1(skill_1):
	_skill_1 = skill_1
func set_skill_2(skill_2):
	_skill_2 = skill_2

func get_basic_move_packedscene() -> PackedScene:
	return _basic_move
func get_enhanced_basic_move_packedscene() -> PackedScene:
	return _enhanced_basic_move
func get_skill_1_packedscene() -> PackedScene:
	return _skill_1
func get_skill_2_packedscene() -> PackedScene:
	return _skill_2
