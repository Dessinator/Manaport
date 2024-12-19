class_name ActorStatusEffectManager extends Node

signal status_effect_applied(status_effect: StatusEffect)
signal status_effect_removed(status_effect: StatusEffect)

var _status_effects: Array = []

func apply_status_effect(status_effect: StatusEffect):
	if get_parent().get_status().is_dead():
		return

	var combined = _handle_combination(status_effect)
	if combined:
		print("combined")
		status_effect = combined

	# print(status_effect._duration_turns)
	var instance = status_effect.duplicate(true)
	# print(instance._duration_turns)

	for effect in _status_effects:
		if effect.get_status_effect_name() != instance.get_status_effect_name():
			continue
		
		effect.add_stack()
		return

	_status_effects.append(instance)
	instance.apply(get_parent())
	instance.ended.connect(remove_status_effect)
	status_effect_applied.emit(instance)

func _handle_combination(status_effect: StatusEffect) -> StatusEffect:
	# search for any CombineRules first
	var combine_rules = status_effect.get_components().filter(func(comp): return comp is CombineRule)
	if combine_rules.size() == 0:
		return null

	# if any CombineRule components found, see if any matching input status effect is active
	var matching_active_effects = []
	for rule in combine_rules:
		for rule_effect in rule.get_combination_rules().keys():
			for active_effect in _status_effects:
				if active_effect.get_status_effect_name() != rule_effect:
					continue
				
				matching_active_effects.append(active_effect)
	if matching_active_effects.size() == 0:
		return null

	# combinations should happen with the last applied APPLICABLE status effect, i.e., the active status effect with
	# the greatest number of turns left.
	var last_applied_status_effect = matching_active_effects[0]

	for effect in matching_active_effects:
		if effect.get_turns_left() > last_applied_status_effect.get_turns_left():
			last_applied_status_effect = effect

	# remove the other effect
	remove_status_effect(last_applied_status_effect)

	var combination_result
	for rule in combine_rules:
		for rule_effect in rule.get_combination_rules().keys():
			if rule_effect == last_applied_status_effect.get_status_effect_name():
				combination_result = rule.get_combination_rules()[last_applied_status_effect.get_status_effect_name()]
				break

	return combination_result

func tick_all():
	for effect in _status_effects:
		effect.tick()

func remove_status_effect(status_effect: StatusEffect):
	for effect in _status_effects:
		if effect.get_status_effect_name() != status_effect.get_status_effect_name():
			continue
		
		if effect.get_stacks() <= 1:
			_status_effects.erase(status_effect)
			status_effect.ended.disconnect(remove_status_effect)
			status_effect_removed.emit(status_effect)
			return
		
		effect.remove_stack(0)

func clear_status_effect(status_effect: StatusEffect):
	for effect in _status_effects:
		if effect.get_status_effect_name() != status_effect.get_status_effect_name():
			continue
		
		for i in range(effect.get_stacks(), -1, -1):
			effect.remove_stack(i)
		
		_status_effects.erase(status_effect)
		status_effect.ended.disconnect(remove_status_effect)
		status_effect_removed.emit(status_effect)

func clear_all_status_effects():
	for effect in _status_effects:
		for i in range(effect.get_stacks(), -1, -1):
			effect.remove_stack(i)
		effect.ended.disconnect(remove_status_effect)
		status_effect_removed.emit(effect)
		
	_status_effects.clear()