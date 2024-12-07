class_name Act extends Node

enum Type 
{
	SINGLE_TARGET = 0,
	MULTI_TARGET = 1,
	BLAST = 2,
	BOUNCE = 3,

	RESTORE_SINGLE_TARGET = 4,
	RESTORE_MULTI_TARGET = 5,

	DEFEND_SINGLE_TARGET = 6,
	DEFEND_MULTI_TARGET = 7,

	SUPPORT_SINGLE_TARGET = 8,
	SUPPORT_MULTI_TARGET = 9,

	IMPAIR_SINGLE_TARGET = 10,
	IMPAIR_MULTI_TARGET = 11
}

const ACT_TYPE_STRINGS = {
	0: "Single Target",
	1: "Multi-Target",
	2: "Blast",
	3: "Bounce",
	4: "Restore",
	5: "Restore",
	6: "Defend",
	7: "Defend",
	8: "Support",
	9: "Support",
	10: "Impair",
	11: "Impair"
}

var _stage: StageManager

@export var _name: String
@export var _type: Type
@export var _element: Element.Type
@export_multiline var _brief_description: String
@export_multiline var _long_description: String

@export var _friendly_fire: bool

@export var _recover_stamina: bool
@export var _stamina_modifier: int

@export var _locked: bool = false

var _act_components: Array[ActComponent]

func _ready():
	for child in get_children():
		if not child is ActComponent:
			continue
		_act_components.append(child as ActComponent)

func use(acting_actor: Actor, receiving_actors: Array):
	if _recover_stamina:
		acting_actor.modify({str(acting_actor.ActorModificationFunction.MODIFY_STATUS) + "_rest_" + str(Act.create_modification_id()): [_stamina_modifier]})
	else:
		acting_actor.modify({str(acting_actor.ActorModificationFunction.MODIFY_STATUS) + "_exhaust_" + str(Act.create_modification_id()): [_stamina_modifier]})

	var results = {}
	for comp in _act_components:
		var dict = comp.consume(self, acting_actor, receiving_actors)
		if dict == {}:
			continue
		results.merge(dict)

	# if any modifications are to affect the acting actor and !_friendly_fire, then apply them
	if not _friendly_fire:
		var self_modifications = {}
		for key in results.keys():
			var data = results[key]
			if data[0] != acting_actor:
				continue
			self_modifications[key] = data[1]
		acting_actor.modify(self_modifications)

	# if any modifications are to affect the stage (an item most likely),
	# apply them
	var stage_modifications = {}
	for key in results.keys():
		var data = results[key]
		if data[0] != _stage:
			continue
		stage_modifications[key] = data[1]
	_stage.modify(stage_modifications)
	
	# separate all modifications by receiving actor and combine them
	# so that the actor itself doesnt need to find the data that applies
	# to it
	for actor in receiving_actors:
		var modifications = {}
		for key in results.keys():
			var data = results[key]
			if data[0] != actor:
				continue
			modifications[key] = data[1]
		actor.modify(modifications)

func add_act_component(component):
	add_child(component)
	_act_components.append(component as ActComponent)

func remove_act_component(component: ActComponent):
	for i in range(_act_components.size() - 1, -1, -1):
		var comp = _act_components[i]
		if not comp.equals(component):
			continue
		remove_child(comp)
		_act_components.erase(comp)
		break

func set_locked(locked: bool):
	_locked = locked

func get_act_name() -> String:
	return _name
func get_act_type() -> int:
	return _type
func get_act_element() -> int:
	return _element
func does_recover_stamina() -> bool:
	return _recover_stamina
func get_stamina_modifier() -> int:
	return _stamina_modifier
func get_components() -> Array:
	return _act_components

func do_friendly_fire() -> bool:
	return _friendly_fire
func is_locked() -> bool:
	return _locked

# returns a random 6-digit long integer
static func create_modification_id() -> String:
	var s = ""
	for i in range(6):
		var num = randi_range(0, 9)
		s = s + str(num)
	return s

func get_stage() -> StageManager:
	return _stage