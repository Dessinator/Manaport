class_name StatusEffect extends Resource

# a Status Effect is a buff or debuff which makes temporary changes to an Actors stats.

signal applied(status_effect: StatusEffect)
signal stack_applied(status_effect: StatusEffect)
signal ticked(status_effect: StatusEffect)
signal stack_removed(status_effect: StatusEffect)
signal ended(status_effect: StatusEffect)

@export_category("Metadata")
@export var _name: String
@export var _icon: Texture2D
@export_multiline var _brief_description: String
@export_multiline var _long_description: String

enum StatusEffectType { TYPE_GENERAL, TYPE_BUFF, TYPE_DEBUFF }
enum StatusEffectDurationMode { MODE_IGNORE_NEW_STACK, MODE_PER_STACK, MODE_QUEUE_STACK, MODE_RESET_ON_NEW_STACK }
@export_category("Functional")
@export var _status_effect_type: StatusEffectType = StatusEffectType.TYPE_GENERAL
# how long the modifier will be in effect for
# 0 will be treated as infinite
@export var _duration_turns: int
# MODE_IGNORE_NEW_STACK: Status effect duration will not be modified when this status effect is stacked.
# MODE_PER_STACK: Status effect duration is per-stack.
# MODE_QUEUE_STACK: Status effect duration is determined by the number of stacks.
#					(e.x., if there are 6 stacks and this status effect lasts 2 turns, it will take 12 turns
#					for the status effect to end.)
# MODE_RESET_ON_NEW_STACK: Status effect duration is reset upon stacking.
@export var _duration_mode: StatusEffectDurationMode
@export var _status_effect_components: Array[StatusEffectComponent]

# the actor that this modifier is attached to
var _affected_actor: Actor
# the stats resource from the original actor
var _stats: ActorStats
# number of this same modifier affecting _affected_actor
var _stacks: Array = []

# ideally should be called before apply()
func set_stats(stats: ActorStats):
	_stats = stats

func apply(affected_actor: Actor):
	_affected_actor = affected_actor
	_stacks.append(_duration_turns)

	for comp in _status_effect_components:
		comp.apply(self, _affected_actor)
	
	applied.emit(self)

# should be called every turn, should increase the _internal_turn_count by 1
# unless _internal_turn_count == _duration_turns. 
func tick():
	for comp in _status_effect_components:
		comp.tick(self, _affected_actor)
	
	# update individual stack counters UNLESS _duration_mode == MODE_QUEUE_STACK OR _duration_turns == 0
	if _duration_turns == 0:
		ticked.emit(self)
		return
	
	if (_duration_mode == StatusEffectDurationMode.MODE_QUEUE_STACK):
		_stacks[0] -= 1
	else:
		for i in range(_stacks.size()):
			_stacks[i] -= 1
	ticked.emit(self)

	var stacks_to_end = []
	for i in range(_stacks.size()):
		if _stacks[i] == 0:
			stacks_to_end.append(i)
	for i in stacks_to_end:
		if _stacks.is_empty():
			return
		_end_stack(_stacks[i])

func _end_stack(stack_index: int):
	match _duration_mode:
		StatusEffectDurationMode.MODE_PER_STACK:
			remove_stack(stack_index)

			if not _stacks.is_empty():
				return
			
			for comp in _status_effect_components:
				comp.end(self, _affected_actor)
			
			ended.emit(self)
		StatusEffectDurationMode.MODE_QUEUE_STACK:
			remove_stack(stack_index)

			if not _stacks.is_empty():
				return
			
			for comp in _status_effect_components:
				comp.end(self, _affected_actor)
			
			ended.emit(self)
		_:
			for comp in _status_effect_components:
				comp.end(self, _affected_actor)
			for i in range(_stacks.size(), -1, -1):
				remove_stack(i)

			ended.emit(self)

func get_status_effect_name() -> String:
	return _name
func get_icon() -> Texture2D:
	return _icon
func get_brief_desc() -> String:
	return _brief_description
func get_long_desc() -> String:
	return _long_description

func get_status_effect_type() -> StatusEffectType:
	return _status_effect_type
func get_duration_mode() -> StatusEffectDurationMode:
	return _duration_mode

func get_affected_actor() -> Actor:
	return _affected_actor

func get_duration_turns() -> int:
	return _duration_turns
func get_turns_left() -> int:
	# if infinite, just return zero
	if _duration_turns == 0:
		return 0
	
	match _duration_mode:
		StatusEffectDurationMode.MODE_PER_STACK:
			var max = -1
			for stack in _stacks:
				max = max(stack, max)
			return max
		StatusEffectDurationMode.MODE_QUEUE_STACK:
			var sum = 0
			for stack in _stacks:
				sum += stack
			return sum
		_:
			# return the stack closest to 0
			var min = 999999
			for stack in _stacks:
				min = min(stack, min)
			return min

func add_stack():
	_stacks.append(_duration_turns)

	if _duration_mode == StatusEffectDurationMode.MODE_RESET_ON_NEW_STACK:
		for i in range(_stacks.size()):
			_stacks[i] = _duration_turns

	stack_applied.emit(self)
func remove_stack(stack_index: int):
	_stacks.remove_at(stack_index)
	stack_removed.emit(self)

func get_stacks() -> int:
	return _stacks.size()
func get_components() -> Array:
	return _status_effect_components
