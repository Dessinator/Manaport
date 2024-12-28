class_name ActorCOMInputManager extends ActorInputManager

# const DEFAULT_CHANCE: float = 0.75

func choose_act(acting_actor: Actor) -> Act:
	# For now, we just choose the first action on a battler
	
	# we await even though determining an action is instantaneous
	# because the combat arena expects this to be an async function
	await get_tree().process_frame
	return acting_actor.get_acts_manager().get_basic_move_instance()
	
func choose_targets(acting_actor: Actor, act: Act, target_actors: Array[Actor]):
	# Chooses a target to perform an action on

	var target_min_health = target_actors[0]
	
	var min_health = target_min_health.get_status().get_health() 
	for target in target_actors:
		# don't attack battlers on your team
		if acting_actor.is_party_member() == target.is_party_member():
			continue

		if target.get_status().get_health() < min_health:
			target_min_health = target
	
	# we await even though determining an action is instantaneous
	# because the combat arena expects this to be an async function
	await get_tree().process_frame

	return [target_min_health]
