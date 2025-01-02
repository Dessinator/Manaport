class_name CharacterPartyInterface extends Node

# responsible for any communication from a Character to a Party

@export var _character_party_reference: CharacterPartyReference
@export var _character_input_manager: CharacterInputManager

func _ready():
	# connect next and previous signals to change party member functions
	_character_input_manager.on_next.connect(_on_next)
	_character_input_manager.on_previous.connect(_on_previous)
	
func _on_next():
	# if the character is not in a party, do nothing
	if not _character_party_reference.is_in_party():
		return
	
	# get the current party and switch to the next member.
	var party = _character_party_reference.get_current_party()
	party.next_party_leader()

func _on_previous():
	# if the character is not in a party, do nothing
	if not _character_party_reference.is_in_party():
		return
	
	# get the current party and switch to the previous member.
	var party = _character_party_reference.get_current_party()
	party.previous_party_leader()
