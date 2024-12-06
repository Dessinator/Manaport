class_name RemoveStatusEffectMultiTarget extends ActComponent

@export var _status_effects: Array[StatusEffectSelection]

func consume(act: Act, acting_actor: Actor, receiving_actors: Array) -> Dictionary:
	var dict = {}
	for i in range(_status_effects.size()):
		if randf() > _status_effects[i].get_chance():
			continue
		
		for j in range(receiving_actors.size()):
			dict[str(acting_actor.ActorModificationFunction.MODIFY_STATUS) + "_remove_status_effect_" + str(Act.create_modification_id())] = [receiving_actors[j], [_status_effects[i].get_status_effect(), _status_effects[i].does_ignore_bfrt_or_dbrs()]]
	return dict