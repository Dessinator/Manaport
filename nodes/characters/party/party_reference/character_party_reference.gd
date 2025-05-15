class_name CharacterPartyReference extends Node

signal was_set_as_party_leader
signal was_set_as_party_member

@export var _formation: CharacterPartyFormation

var _current_party: Party

func join_party(party: Party):
	_current_party = party
	print(get_parent().name + " joined a party.")
	if not party is PlayerParty:
		return
	_current_party.on_party_leader_set.connect(_on_party_leader_set)
func leave_party(party: Party):
	_current_party = null
	print(get_parent().name + " left a party.")
	if not party is PlayerParty:
		return
	_current_party.on_party_leader_set.disconnect(_on_party_leader_set)

func is_in_party() -> bool:
	return _current_party != null
func is_party_leader() -> bool:
	return (is_in_party() and _current_party.is_party_leader(self))

func _on_party_leader_set(new_leader):
	if new_leader != self:
		was_set_as_party_member.emit()
		return
	
	was_set_as_party_leader.emit()

func get_formation() -> CharacterPartyFormation:
	return _formation
func get_current_party() -> Party:
	return _current_party
