extends Node

# autoload for managing the transition between the overworld to the stage and back.

const STAGE_SCENE_PATH = "res://nodes/stage/stage.tscn"

var _current_stage_instance: StageManager

func start_battle(aggressor: CharacterBattleHandler, victim: CharacterBattleHandler):
	print("Starting battle...")
	
	var aggressor_character = aggressor.get_parent()
	var victim_character = victim.get_parent()
	
	print("Aggressor: {aggressor_name} vs. Victim: {victim_name}".format({
		"aggressor_name": aggressor_character.name,
		"victim_name": victim_character.name
	}))
	
	# if the two Characters are in parties, make sure they are sent into battle too.
	
	print("Gathering Party info...")
	var aggressor_party_reference = aggressor_character.get_node("CharacterPartyReference")
	var victim_party_reference = victim_character.get_node("CharacterPartyReference")
	var aggressor_party
	var victim_party
	
	var aggressor_battle_handlers = []
	var victim_battle_handlers = []
	
	if aggressor_party_reference:
		if aggressor_party_reference.is_in_party():
			aggressor_party = aggressor_party_reference.get_current_party()
	if victim_party_reference:
		if victim_party_reference.is_in_party():
			victim_party = victim_party_reference.get_current_party()
	
	if aggressor_party == null:
		print("Aggressor is not in a party.")
		aggressor_battle_handlers.append(aggressor)
	else:
		if aggressor_party.is_player_party():
			print("Player party is aggressor party.")
		
		var party_members = aggressor_party.get_members()
		
		print("Aggressor party members:")
		for member in party_members:
			print(member.get_parent().name)
			
			var battle_handler = member.get_node("../CharacterBattleHandler")
			if battle_handler == null:
				print("(no CharacterBattleHandler found...)")
				continue
			
			aggressor_battle_handlers.append(battle_handler)
		
	if victim_party == null:
		print("Victim is not in a party.")
		victim_battle_handlers.append(victim)
	else:
		if victim_party.is_player_party():
			print("Player party is victim party.")
		
		var party_members = victim_party.get_members()
		
		print("Victim party members:")
		for member in party_members:
			print(member.get_parent().name)
			
			var battle_handler = member.get_node("../CharacterBattleHandler")
			if battle_handler == null:
				print("(no CharacterBattleHandler found...)")
				continue
			
			victim_battle_handlers.append(battle_handler)
	
	var aggressor_actor_scenes = aggressor_battle_handlers.map(func(battle_handler): return battle_handler.get_actor_scene())
	var victim_actor_scenes = victim_battle_handlers.map(func(battle_handler): return battle_handler.get_actor_scene())
	print("Setting the stage...")
	
	SceneLoader.load_scene(STAGE_SCENE_PATH)
	await SceneLoader.scene_changed
	
	_current_stage_instance = get_node("../Stage")
	_current_stage_instance.add_actors(aggressor_actor_scenes)
	_current_stage_instance.add_actors(victim_actor_scenes)
	
	await _current_stage_instance.ready
	print("Action!")
	_current_stage_instance.action()
