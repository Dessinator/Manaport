class_name ActorStatus extends Resource

signal max_health_modified(old: int, new: int)
signal health_modified(old: int, new: int)
signal max_stamina_modified(old: int, new: int)
signal stamina_modified(old: int, new: int)

signal healed(amount: int)
signal damaged(amount: int, crit: bool)
signal died
signal revived

signal status_effect_applied(status_effect: StatusEffect)
signal status_effect_removed(status_effect: StatusEffect)
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

	if not ignore_dbrs:
		if status_effect.get_status_effect_type() == status_effect.StatusEffectType.TYPE_DEBUFF:
			var resisted = _handle_debuff_resistance()
			if resisted:
				return

	var status_effect_name = status_effect.get_status_effect_name()

	for i in range(stacks):
		var combined = _handle_combination(status_effect)
		if combined:
			print("combined")
			status_effect = combined

		if _status_effects.has(status_effect_name):
			_status_effects[status_effect_name].add_stack()
			continue

		var instance = status_effect.duplicate(true)
			
		_status_effects[status_effect_name] = instance
		instance.apply(_actor)
		instance.ended.connect(remove_status_effect)
		status_effect_applied.emit(instance)

func remove_status_effect(status_effect: StatusEffect, stacks: int = 1, ignore_bfrt: bool = false):
	var status_effect_name = status_effect.get_status_effect_name()
	if not _status_effects.has(status_effect_name):
		return
	
	if not ignore_bfrt:
		if status_effect.get_status_effect_type() == status_effect.StatusEffectType.TYPE_BUFF:
			var retained = _handle_buff_retention()
			if retained:
				return
	
	for i in range(stacks):
		if _status_effects[status_effect_name].get_stacks() - 1 == 0:
			_status_effects[status_effect_name].ended.disconnect(remove_status_effect)
			status_effect_removed.emit(_status_effects[status_effect_name])
			_status_effects.erase(status_effect_name)
			return
	
		_status_effects[status_effect_name].remove_stack(0)

func _clear_status_effect(status_effect: StatusEffect):
	var status_effect_name = status_effect.get_status_effect_name()
	if not _status_effects.has(status_effect_name):
		return
	
	for i in range(_status_effects[status_effect_name].get_stacks(), -1, -1):
		_status_effects[status_effect_name].remove_stacks(i)

	_status_effects[status_effect_name].ended.disconnect(remove_status_effect)
	status_effect_removed.emit(_status_effects[status_effect_name])
	_status_effects.erase(status_effect_name)

func _clear_all_status_effects():
	for effect in _status_effects.keys():
		for i in range(effect.get_stacks(), -1, -1):
			_status_effects[effect].remove_stack(i)
		_status_effects[effect].ended.disconnect(remove_status_effect)
		status_effect_removed.emit(_status_effects[effect])
		
	_status_effects.clear()

func _handle_debuff_resistance() -> bool:
	var debuff_resistance = _stats.get_substat_curves().sample_dbrs_curve(_stats.get_dfns(false, true), false, true)
	var roll = randf()
	if roll < debuff_resistance:
		resisted_debuff.emit()
		return true
	return false

func _handle_buff_retention() -> bool:
	var buff_retention = _stats.get_substat_curves().samble_bfrt_curve(_stats.get_dfns(false, true), false, true)
	var roll = randf()
	if roll < buff_retention:
		retained_buff.emit()
		return true
	return false

func _handle_combination(status_effect: StatusEffect) -> StatusEffect:
	# search for any CombineRules first
	var combine_rules = status_effect.get_components().filter(func(comp): return comp is CombineRule)
	if combine_rules.size() == 0:
		return null

	# if any CombineRule components found, see if any matching input status effect is active
	var matching_active_effects = []
	for rule in combine_rules:
		for rule_effect in rule.get_combination_rules().keys():
			if not _status_effects.has(rule_effect):
				continue
			
			matching_active_effects.append(_status_effects[rule_effect])
	if matching_active_effects.size() == 0:
		return null

	# combinations should happen with the last applied APPLICABLE status effect, i.e., the active status effect with
	# the greatest number of turns left.
	var last_applied_status_effect = matching_active_effects[0]

	for effect in matching_active_effects:
		if effect.get_turns_left() > last_applied_status_effect.get_turns_left():
			last_applied_status_effect = effect

	# remove the other effect
	remove_status_effect(last_applied_status_effect, 1)

	var combination_result
	for rule in combine_rules:
		for rule_effect in rule.get_combination_rules().keys():
			if rule_effect == last_applied_status_effect.get_status_effect_name():
				combination_result = rule.get_combination_rules()[last_applied_status_effect.get_status_effect_name()]
				break

	return combination_result

func tick_all():
	for effect in _status_effects.keys():
		_status_effects[effect].tick()

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
