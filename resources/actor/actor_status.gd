class_name ActorStatus extends Resource

signal max_health_modified(old: int, new: int)
signal health_modified(old: int, new: int)
signal max_stamina_modified(old: int, new: int)
signal stamina_modified(old: int, new: int)

signal healed(amount: int)
signal damaged(amount: int, crit: bool)
signal died
signal revived

signal status_effect_applied(status_effect_instance: Dictionary)
signal status_effect_stack_applied(status_effect_instance: Dictionary)
signal status_effect_ticked(status_effect_instance: Dictionary)
signal status_effect_stack_removed(status_effect_instance: Dictionary)
signal status_effect_removed(status_effect_instance: Dictionary)
signal resisted_debuff
signal retained_buff

var _actor: Actor
var _stats: ActorStats

# health
var _max_health: int
var _health: int

var _is_dead: bool = false

# stamina
var _max_stamina: int
var _stamina: int

# status effects
var _status_effects: Dictionary = {}

func initialize(actor: Actor, stats: ActorStats):
	_actor = actor
	_stats = stats
	_set_max_health(_stats.get_substat_curves().sample_mxhl_curve(_stats.get_vtly(false, true), false, false))
	_set_health(get_max_health())
	
	_set_max_stamina(_stats.get_substat_curves().sample_mxst_curve(_stats.get_vtly(false, true), false, false))
	_set_stamina(get_max_stamina())

# damage
func damage(base_amount: int, crit: bool = false, addend: int = 0):
	var damage_mitigation = _stats.get_substat_curves().sample_dmmt_curve(_stats.get_dfns(false, true), false, true)
	var damage_negated = int((base_amount * damage_mitigation) + 0.5)
	var true_damage = base_amount - damage_negated + addend
	_set_health(_health - true_damage)
	damaged.emit(true_damage, crit)
func heal(amount: int):
	_set_health(_health + amount)
	healed.emit(amount)
func revive(recover_health: int, recover_stamina: int):
	_is_dead = false
	_set_health(recover_health)
	_set_stamina(recover_stamina)
	revived.emit()
func die():
	_is_dead = true
	died.emit()

# stamina
func exhaust(amount: int):
	_set_stamina(_stamina - amount)
func rest(amount: int):
	_set_stamina(_stamina + amount)

# status effects
func apply_status_effect(status_effect: StatusEffect, stacks: int = 1, ignore_dbrs: bool = false):
	if _is_dead:
		return

	var instance = status_effect.get_status_effect_instance()
	var status_effect_name = instance["metadata"]["name"]
	# var status_effect_name = status_effect.get_status_effect_name()

	if not ignore_dbrs:
		if instance["functional"]["type"] == StatusEffect.StatusEffectType.TYPE_DEBUFF:
			var resisted = _handle_debuff_resistance()
			if resisted:
				return

	for i in range(stacks):
		var combined = _handle_combination(instance)
		if combined:
			print("combined")
			instance = combined

		if _status_effects.has(status_effect_name):
			_add_stacks_to_status_effect(_status_effects[status_effect_name], 1)
			# _status_effects[status_effect_name].add_stack()
			continue

		# var instance = status_effect.duplicate(true)
		# var instance = status_effect.get_status_effect_instance()
			
		_status_effects[status_effect_name] = instance
		instance["affected_actor"] = _actor
		status_effect_applied.emit(instance)
		_add_stacks_to_status_effect(_status_effects[status_effect_name], 1)
		# instance.apply(_actor)
		# instance.ended.connect(remove_status_effect)

		for component in instance["functional"]["components"]:
			component.apply(instance, instance["affected_actor"])
		
func _add_stacks_to_status_effect(status_effect_instance: Dictionary, stacks: int):
	var stacks_array = status_effect_instance["stacks"]
	var duration_turns = status_effect_instance["functional"]["duration_turns"]
	for i in range(stacks):
		stacks_array.append(duration_turns)

		if status_effect_instance["functional"]["duration_mode"] == StatusEffect.StatusEffectDurationMode.MODE_RESET_ON_NEW_STACK:
			for j in range(stacks_array.size()):
				stacks_array[j] = duration_turns

		#status_effect_instance["on_stack_applied"].emit(status_effect_instance)
		status_effect_stack_applied.emit(status_effect_instance)
func _tick_status_effect(status_effect_instance: Dictionary):
	var stacks_array = status_effect_instance["stacks"]

	for component in status_effect_instance["functional"]["components"]:
		component.tick(status_effect_instance, status_effect_instance["affected_actor"])

	# tick status effect if it is meant to be infinite.
	if status_effect_instance["functional"]["duration_turns"] == 0:
		status_effect_ticked.emit(status_effect_instance)
		return
	
	# update individual stack counters UNLESS _duration_mode == MODE_QUEUE_STACK OR _duration_turns == 0
	if (status_effect_instance["functional"]["duration_mode"] == StatusEffect.StatusEffectDurationMode.MODE_QUEUE_STACK):
		stacks_array[0] -= 1
	else:
		for i in range(stacks_array.size()):
			stacks_array[i] -= 1
	
	#status_effect_instance["on_ticked"].emit(status_effect_instance)
	status_effect_ticked.emit(status_effect_instance)

	var stacks_to_end = []
	for i in range(stacks_array.size()):
		if stacks_array[i] == 0:
			stacks_to_end.append(i)
	for i in stacks_to_end:
		if stacks_array.is_empty():
			return
		_end_status_effect_stack(status_effect_instance, stacks_to_end[i])
func _end_status_effect_stack(status_effect_instance: Dictionary, stack_index: int):
	var affected_actor = status_effect_instance["affected_actor"]
	var stacks_array = status_effect_instance["stacks"]
	var components_array = status_effect_instance["functional"]["components"]

	match status_effect_instance["functional"]["duration_mode"]:
		StatusEffect.StatusEffectDurationMode.MODE_PER_STACK:
			_remove_stack_from_status_effect(status_effect_instance, stack_index)

			if not stacks_array.is_empty():
				return
			
			for component in components_array:
				component.end(status_effect_instance, affected_actor)
		StatusEffect.StatusEffectDurationMode.MODE_QUEUE_STACK:
			_remove_stack_from_status_effect(status_effect_instance, stack_index)

			if not stacks_array.is_empty():
				return
			
			for component in components_array:
				component.end(status_effect_instance, affected_actor)
		_:
			for i in range(stacks_array.size() - 1, -1, -1):
				_remove_stack_from_status_effect(status_effect_instance, i)
			
			for component in components_array:
				component.end(status_effect_instance, affected_actor)
func _remove_stack_from_status_effect(status_effect_instance: Dictionary, stack_index: int):
	var stacks_array = status_effect_instance["stacks"]
	stacks_array.remove_at(stack_index)
	status_effect_stack_removed.emit(status_effect_instance)
	
	if stacks_array.size() > 0:
		return
		
	_clear_status_effect(status_effect_instance)
	
func remove_status_effect(status_effect_instance: Dictionary, stacks: int = 1, ignore_bfrt: bool = false):
	var status_effect_name = status_effect_instance["metadata"]["name"]

	if not _status_effects.has(status_effect_name):
		return
	
	var status_effect = _status_effects[status_effect_name]
	var stacks_array = status_effect["stacks"]
	
	for i in range(stacks):
		if not ignore_bfrt:
			if status_effect["functional"]["type"] == StatusEffect.StatusEffectType.TYPE_BUFF:
				var retained = _handle_buff_retention()
				if retained:
					continue
		
		stacks_array.remove_at(stacks_array.size() - 1)
	
func _clear_status_effect(status_effect_instance: Dictionary):
	var status_effect_name = status_effect_instance["metadata"]["name"]
	if not _status_effects.has(status_effect_name):
		return
	
	for i in range(_status_effects[status_effect_name]["stacks"].size() - 1, -1, -1):
		_remove_stack_from_status_effect(_status_effects[status_effect_name], i)

	# _status_effects[status_effect_name].ended.disconnect(remove_status_effect)
	status_effect_removed.emit(_status_effects[status_effect_name])
	_status_effects.erase(status_effect_name)
func _clear_all_status_effects():
	for status_effect_name in _status_effects.keys():
		var status_effect = _status_effects[status_effect_name]

		_clear_status_effect(status_effect)

		# for i in range(effect.get_stacks(), -1, -1):
		# 	_status_effects[effect].remove_stack(i)

		# _status_effects[effect].ended.disconnect(remove_status_effect)
		status_effect_removed.emit(status_effect)
		
	_status_effects.clear()

func _handle_debuff_resistance() -> bool:
	var debuff_resistance = _stats.get_substat_curves().sample_dbrs_curve(_stats.get_dfns(false, true), false, true)
	var roll = randf()
	if roll < debuff_resistance:
		resisted_debuff.emit()
		return true
	return false

func _handle_buff_retention() -> bool:
	var buff_retention = _stats.get_substat_curves().sample_bfrt_curve(_stats.get_dfns(false, true), false, true)
	var roll = randf()
	if roll < buff_retention:
		retained_buff.emit()
		return true
	return false

func _handle_combination(status_effect_instance: Dictionary):
	# search for any CombineRules first
	# var combine_rules = status_effect.get_components().filter(func(comp): return comp is CombineRule)
	var combine_rules = status_effect_instance["functional"]["components"].filter(func(component): return component is CombineRule)
	if combine_rules.size() == 0:
		return null

	# if any CombineRule components found, see if any matching input status effect is active
	var matching_active_effects = []
	for rule in combine_rules:
		for rule_effect_name in rule.get_combination_rules().keys():
			if not _status_effects.has(rule_effect_name):
				continue
			
			matching_active_effects.append(_status_effects[rule_effect_name])
	if matching_active_effects.size() == 0:
		return null

	# combinations should happen with the last applied APPLICABLE status effect, usually the active status effect with
	# the greatest number of turns left.
	var last_applied_status_effect = matching_active_effects[0]

	for matching_active_effect in matching_active_effects:
		if StatusEffect.get_turns_left_for_status_effect_instance(matching_active_effect) > StatusEffect.get_turns_left_for_status_effect_instance(last_applied_status_effect):
			last_applied_status_effect = matching_active_effect

	# remove the other effect
	remove_status_effect(last_applied_status_effect, 1)

	var combination_result
	for rule in combine_rules:
		for rule_effect_name in rule.get_combination_rules().keys():
			if rule_effect_name == last_applied_status_effect["metadata"]["name"]:
				combination_result = rule.get_combination_rules()[last_applied_status_effect["metadata"]["name"]].get_status_effect_instance()
				break

	return combination_result

func tick_debuffs():
	for status_effect_name in _status_effects.keys():
		var status_effect_instance = _status_effects[status_effect_name]
		if status_effect_instance["functional"]["type"] != StatusEffect.StatusEffectType.TYPE_DEBUFF:
			continue
		_tick_status_effect(status_effect_instance)

# ...not sure if this will ever be useful, but hey, it's here. General status effects probably just need to be ticked
# before the actor takes their turn (for animations and stuff)
func tick_general():
	for status_effect_name in _status_effects.keys():
		var status_effect_instance = _status_effects[status_effect_name]
		if status_effect_instance["functional"]["type"] != StatusEffect.StatusEffectType.TYPE_GENERAL:
			continue
		_tick_status_effect(status_effect_instance)

func tick_buffs():
	for status_effect_name in _status_effects.keys():
		var status_effect_instance = _status_effects[status_effect_name]
		if status_effect_instance["functional"]["type"] != StatusEffect.StatusEffectType.TYPE_BUFF:
			continue
		_tick_status_effect(status_effect_instance)



# setters and getters
func _set_max_health(value: int):
	var old = _max_health
	_max_health = value
	max_health_modified.emit(old, _max_health)
func _set_health(value: int):
	if _is_dead:
		return

	var old = _health
	if old == value:
		return
	
	if value > _max_health:
		value = _max_health
	elif value <= 0:
		value = 0

		die()
	
	_health = value
	health_modified.emit(old, _health)
func get_max_health() -> int:
	return _max_health
func get_health() -> int:
	return _health
func is_dead() -> bool:
	return _is_dead

func _set_max_stamina(value: int):
	var old = _max_stamina
	_max_stamina = value
	max_stamina_modified.emit(old, _max_stamina)
func _set_stamina(value: int):
	if _is_dead:
		return
	
	var old = _stamina
	if old == value:
		return
	
	if value > _max_stamina:
		value = _max_stamina
	if value < 0:
		value = 0
	
	_stamina = value
	stamina_modified.emit(old, _stamina)
func get_max_stamina() -> int:
	return _max_stamina
func get_stamina() -> int:
	return _stamina

func get_status_effects() -> Dictionary:
	return _status_effects
