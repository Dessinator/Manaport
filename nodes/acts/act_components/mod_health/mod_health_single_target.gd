class_name ModHealthSingleTarget extends ActComponent

@export var _heal: bool
## Deals damage equivalent to this percent of _reference_stat
@export var _health_mod_percentage: float

func consume(act: Act, acting_actor: Actor, receiving_actors: Array) -> Dictionary:
	var health_mod: int
	if _reference_stat < 3:
		var stat = acting_actor.get_stats().call("get_" + REFERENCE_STAT_STRINGS[_reference_stat].to_lower(), false, false)
		health_mod = int((stat * _health_mod_percentage) + 0.5)
	else:
		var stat = acting_actor.get_stats().get_substat_curves().call("sample_" + REFERENCE_STAT_STRINGS[_reference_stat].to_lower() + "_curve",
				acting_actor.get_stats().call("get_" + REFERENCE_STAT_STRINGS[_substat_to_main_stat(_reference_stat)].to_lower(), false, true),
				false,
				false
				)
		health_mod = int((stat * _health_mod_percentage) + 0.5)

	if _heal:
		return {str(acting_actor.ActorModificationFunction.MODIFY_STATUS) + "_heal_" + str(Act.create_modification_id()): [receiving_actors[0], [health_mod]]}
	
	var crit_chance = acting_actor.get_stats().get_substat_curves().sample_crch_curve(acting_actor.get_stats().get_attk(false, true), false, true)
	var crit_multiplier = acting_actor.get_stats().get_substat_curves().sample_crml_curve(acting_actor.get_stats().get_attk(false, true), false, true)
	var crit_roll = randf()
	var crit = crit_roll <= crit_chance

	if crit:
		return {str(acting_actor.ActorModificationFunction.MODIFY_STATUS) + "_damage_" + str(Act.create_modification_id()): [receiving_actors[0], [health_mod, crit, int((crit_multiplier * float(health_mod)) + 0.5)]]}
	return {str(acting_actor.ActorModificationFunction.MODIFY_STATUS) + "_damage_" + str(Act.create_modification_id()): [receiving_actors[0], [health_mod, crit, 0]]}
	
