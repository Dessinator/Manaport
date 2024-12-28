class_name RemoveStatusEffectBlast extends ActComponent

@export var _status_effects: Array[StatusEffectSelection]

# "main actor" = actor @ i=0 in receiving_actors
func consume(act: Act, acting_actor: Actor, receiving_actors: Array) -> Dictionary:
	var dict = {}
	for i in range(_status_effects.size()):
		if randf() <= _status_effects[i].get_chance():
			dict[str(acting_actor.ActorModificationFunction.MODIFY_STATUS) + "_remove_status_effect_" + str(Act.create_modification_id())] = [receiving_actors[0], [_status_effects[i].get_status_effect(), _status_effects[i].does_ignore_bfrt_or_dbrs()]]
		
		for j in range(1, receiving_actors.size()):
			if randf() > _status_effects[i].get_chance():
				continue

			dict[str(acting_actor.ActorModificationFunction.MODIFY_STATUS) + "_remove_status_effect_" + str(Act.create_modification_id())] = [receiving_actors[j], [_status_effects[i].get_status_effect(), _status_effects[i].does_ignore_bfrt_or_dbrs()]]
	return dict