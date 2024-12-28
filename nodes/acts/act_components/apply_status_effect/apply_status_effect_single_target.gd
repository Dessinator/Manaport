class_name ApplyStatusEffectSingleTarget extends ActComponent

@export var _status_effects: Array[StatusEffectSelection]

func consume(act: Act, acting_actor: Actor, receiving_actors: Array) -> Dictionary:
	var dict = {}
	for i in range(_status_effects.size()):
		var selection = _status_effects[i]

		if randf() > selection.get_chance():
			continue
		
		var duplicate = selection.get_status_effect().duplicate()
		duplicate.set_stats(acting_actor.get_stats())

		dict[str(acting_actor.ActorModificationFunction.MODIFY_STATUS) + "_apply_status_effect_" + str(Act.create_modification_id())] = [receiving_actors[0], [duplicate, selection.get_stacks(), selection.does_ignore_bfrt_or_dbrs()]]
	return dict
