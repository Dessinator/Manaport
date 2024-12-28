class_name ModHealthBounce extends ActComponent

@export var _heal: bool
## Deals damage equivalent to this percent of _reference_stat
@export var _base_health_mod_percentage: float
@export_range(0, 1) var _falloff: float
@export var _bounce_count: int = 2

# "main actor" = actor @ i=0 in receiving_actors
func consume(act: Act, acting_actor: Actor, receiving_actors: Array) -> Dictionary:
	var dict = {}

	var base_health_mod
	if _reference_stat < 3:
		var stat = acting_actor.get_stats().call("get_" + REFERENCE_STAT_STRINGS[_reference_stat].to_lower(), false, false)
		base_health_mod = int((stat * _base_health_mod_percentage) + 0.5)
	else:
		var stat = acting_actor.get_stats().get_substat_curves().call("sample_" + REFERENCE_STAT_STRINGS[_reference_stat].to_lower() + "_curve",
				acting_actor.get_stats().call("get_" + REFERENCE_STAT_STRINGS[_substat_to_main_stat(_reference_stat)].to_lower(), false, true),
				false,
				false
				)
		base_health_mod = int((stat * _base_health_mod_percentage) + 0.5)
	var residual_damage = int((float(base_health_mod) * _falloff) + 0.5)

	var crit_chance = acting_actor.get_stats().get_substat_curves().sample_crch_curve(acting_actor.get_stats().get_attk(false, true), false, true)
	var crit_multiplier = acting_actor.get_stats().get_substat_curves().sample_crml_curve(acting_actor.get_stats().get_attk(false, true), false, true)

	if _heal:
		dict[str(acting_actor.ActorModificationFunction.MODIFY_STATUS) + "_heal_" + str(Act.create_modification_id())] = [receiving_actors[0], [base_health_mod]]
	else:
		var crit_roll = randf()
		var crit = crit_roll <= crit_chance

		if crit:
			dict[str(acting_actor.ActorModificationFunction.MODIFY_STATUS) + "_damage_" + str(Act.create_modification_id())] = [receiving_actors[0], [base_health_mod, crit, int((crit_multiplier * float(base_health_mod)) + 0.5)]]
		else:
			dict[str(acting_actor.ActorModificationFunction.MODIFY_STATUS) + "_damage_" + str(Act.create_modification_id())] = [receiving_actors[0], [base_health_mod, crit, 0]]
	
	for i in range(_bounce_count):
		var rand_actor_index = randi_range(1, receiving_actors.size() - 1)

		if _heal:
			dict[str(acting_actor.ActorModificationFunction.MODIFY_STATUS) + "_heal_" + str(Act.create_modification_id())] = [receiving_actors[rand_actor_index], [residual_damage]]
			continue
		
		var crit_roll = randf()
		var crit = crit_roll <= crit_chance

		if crit:
			dict[str(acting_actor.ActorModificationFunction.MODIFY_STATUS) + "_damage_" + str(Act.create_modification_id())] = [receiving_actors[rand_actor_index], [residual_damage, crit, int((crit_multiplier * float(residual_damage)) + 0.5)]]
			continue
		dict[str(acting_actor.ActorModificationFunction.MODIFY_STATUS) + "_damage_" + str(Act.create_modification_id())] = [receiving_actors[rand_actor_index], [residual_damage, crit, 0]]		
	return dict