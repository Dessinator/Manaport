class_name OverworldManager extends Node3D

static var _instance: OverworldManager

@onready var _overworld_environment: Node3D = %OverworldEnvironment
@onready var _environment_parent: Node3D = %OverworldEnvironment/%Environment

static var _global_enemies: Array = []
static var _parties: Array = []

func _enter_tree():
	if _instance:
		return
	_instance = self

## finds an existing party or creates a new party, adding the provided party_reference
## to the party.
static func request_and_join_party(party_reference: CharacterPartyReference) -> Party:
	return null

static func find_party_with_member(member: CharacterPartyReference) -> Party:
	return null
	#for party in _parties:
		#if party.get_members().has(member):

static func create_party() -> Party:
	var party = Party.new()
	_parties.append(party)
	return party

static func remove_party(party: Party):
	if _parties.has(party):
		_parties.erase(party)
	party.queue_free()

static func add_enemy_to_global_enemy_array(enemy_reference: CharacterEnemyReference) -> int:
	_global_enemies.append(enemy_reference)
	return _global_enemies.size() - 1
