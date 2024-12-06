class_name ModHealthMultiTarget extends ActComponent

@export var _heal: bool
## Deals damage equivalent to this percent of _reference_stat
@export var _health_mod_percentage: float

func consume(act: Act, acting_actor: Actor, receiving_actors: Array):
	var dict = {}

	var health_mod
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

	var crit_chance = acting_actor.get_stats().get_substat_curves().sample_crch_curve(acting_actor.get_stats().get_attk(false, true), false, true)
	var crit_multiplier = acting_actor.get_stats().get_substat_curves().sample_crml_curve(acting_actor.get_stats().get_attk(false, true), false, true)
	
	for i in range(receiving_actors.size()):
		if _heal:
			dict[str(acting_actor.ActorModificationFunction.MODIFY_STATUS) + "_heal_" + str(Act.create_modification_id())] = [receiving_actors[i], [health_mod]]
			continue
		
		var crit_roll = randf()
		var crit = crit_roll <= crit_chance

		if crit:
			dict[str(acting_actor.ActorModificationFunction.MODIFY_STATUS) + "_damage_" + str(Act.create_modification_id())] = [receiving_actors[i], [health_mod, crit, int((crit_multiplier * float(health_mod)) + 0.5)]]
			continue
		dict[str(acting_actor.ActorModificationFunction.MODIFY_STATUS) + "_damage_" + str(Act.create_modification_id())] = [receiving_actors[i], [health_mod, crit, 0]]		
	return dict
