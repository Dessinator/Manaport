class_name RemoveStatusEffectSingleTarget extends ActComponent

@export var _status_effects: Array[StatusEffectSelection]

func consume(act: Act, acting_actor: Actor, receiving_actors: Array) -> Dictionary:
	var dict = {}
	for i in range(_status_effects.size()):
		if randf() > _status_effects[i].get_chance():
			continue

		dict[str(acting_actor.ActorModificationFunction.MODIFY_STATUS) + "_remove_status_effect_" + str(Act.create_modification_id())] = [receiving_actors[0], [_status_effects[i].get_status_effect(), _status_effects[i].does_ignore_bfrt_or_dbrs()]]
	return dict