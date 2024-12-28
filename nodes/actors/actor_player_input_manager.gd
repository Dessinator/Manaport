class_name ActorPlayerInputManager extends ActorInputManager

var _attached_stage_interface: StageInterface

func attach_stage_interface(stage_interface: StageInterface):
	_attached_stage_interface = stage_interface

func choose_act(acting_actor: Actor):
	"""
	Select an action to perform in combat
	Can be based on state of the actor
	"""
	return await _attached_stage_interface.choose_act(acting_actor)
	
func choose_targets(acting_actor: Actor, act: Act, target_actors: Array[Actor]):
	"""
	Chooses a target to perform an action on
	"""
	var real_target_actors = []
	for actor in target_actors:
		# if act.do_friendly_fire(), use this act on the same team. else, use this act on the opposite team.
		if act.do_friendly_fire():
			if acting_actor.is_party_member() != actor.is_party_member():
				continue
			if actor.get_status().is_dead():
				continue
			real_target_actors.append(actor)
		else:
			if acting_actor.is_party_member() == actor.is_party_member():
				continue
			if actor.get_status().is_dead():
				continue
			real_target_actors.append(actor)

	return await _attached_stage_interface.select_targets(act, real_target_actors)

