class_name Item extends Resource

signal quantity_increased(old: int, new: int)
signal quantity_decreased(old: int, new: int)

@export_category("Metadata")
@export var _item_name: String
@export var _item_icon: Texture2D
@export_multiline var _item_description: String

@export_category("Functional")
@export var _consumable: bool
@export var _friendly_fire: bool = true
@export var _use_type: Act.Type

@export var _item_components: Array[ItemComponent]

var _quantity: int = 1

func initialize() -> Dictionary:
	var dict = {}
	for comp in _item_components:
		dict.merge(comp.initialize(self))
	return dict

func consume() -> Dictionary:
	if not _consumable:
		return {}
	
	var dict = {}
	for comp in _item_components:
		dict.merge(comp.consume(self))
	return dict

func add(quantity: int):
	var old = _quantity
	_quantity += quantity
	quantity_increased.emit(old, _quantity)
func remove(quantity: int):
	var old = _quantity
	_quantity -= quantity
	if _quantity < 0:
		_quantity = 0
	quantity_decreased.emit(old, _quantity)

func get_item_name() -> String:
	return _item_name
func get_item_description() -> String:
	return _item_description

func is_consumable() -> bool:
	return _consumable
func is_friendly_fire() -> bool:
	return _friendly_fire
func get_use_type() -> Act.Type:
	return _use_type

func get_item_components() -> Array[ItemComponent]:
	return _item_components

func get_quantity() -> int:
	return _quantity

# returns a random 6-digit long integer
static func create_modification_id() -> String:
	var s = ""
	for i in range(6):
		var num = randi_range(0, 9)
		s = s + str(num)
	return s