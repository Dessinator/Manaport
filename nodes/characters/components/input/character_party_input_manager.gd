@tool
class_name CharacterPartyInputManager extends CharacterInputManager

# responsible for switching a character's input mode
# between player and COM.
#
# COM Input is to be used when the CharacterPartyReference
# emits the "was_set_as_party_member" signal
#
# Player Input is to be used when the CharacterPartyReference
# emits the "was_set_as_party_leader" signal

func _get_configuration_warnings():
	if %CharacterCOMInputManager and %CharacterPlayerInput:
		return []
	return ["CharacterPartyInputManager requires a CharacterCOMInputManager child AND
			A CharacterPlayerInput child. Have you added the node as a child or instantiated a child scene?"] 

@onready var _player_input_manager: CharacterPlayerInputManager = %CharacterPlayerInput
@onready var _com_input_manager: CharacterCOMInputManager = %CharacterCOMInputManager

@export var _party_reference: CharacterPartyReference:
	set(value):
		_party_reference = value
		_connect_party_reference_component_signals()
## will only be used in Player Input mode
var _party_camera_manager: PartyCameraManager:
	set(value):
		_party_camera_manager = value
		_player_input_manager.set_camera_manager(_party_camera_manager)

func _connect_party_reference_component_signals():
	_party_reference.was_set_as_party_leader.connect(_on_was_set_as_party_leader)
	_party_reference.was_set_as_party_member.connect(_on_was_set_as_party_member)

func _on_was_set_as_party_leader():
	_reset_input()
	_connect_player_input_signals()
func _on_was_set_as_party_member():
	_reset_input()
	_connect_com_input_signals()
	
	# get the party leader's formation
	var current_party = _party_reference.get_current_party()
	var leader = current_party.get_current_party_leader()
	var formation = leader.get_formation()
	
	# make the CharacterCOMInputManager follow the matching Marker3D on the formation
	var target
	if _party_reference == current_party.get_last_party_leader():
		target = formation.get_child(0)
	else:
		target = formation.get_child(1)
	
	# set the target node of the CharacterCOMInputManager
	_com_input_manager.set_target_node(target)

func _connect_player_input_signals():
		_player_input_manager.on_move.connect(_on_move)
		_player_input_manager.on_sprint.connect(_on_sprint)
		_player_input_manager.on_look.connect(_on_look)
		_player_input_manager.on_next.connect(_on_next)
		_player_input_manager.on_previous.connect(_on_previous)
	
		_com_input_manager.on_move.disconnect(_on_move)
		_com_input_manager.on_sprint.disconnect(_on_sprint)
		_com_input_manager.on_look.disconnect(_on_look)
		_com_input_manager.on_next.disconnect(_on_next)
		_com_input_manager.on_previous.disconnect(_on_previous)
func _connect_com_input_signals():
		_com_input_manager.on_move.connect(_on_move)
		_com_input_manager.on_sprint.connect(_on_sprint)
		_com_input_manager.on_look.connect(_on_look)
		_com_input_manager.on_next.connect(_on_next)
		_com_input_manager.on_previous.connect(_on_previous)
	
		_player_input_manager.on_move.disconnect(_on_move)
		_player_input_manager.on_sprint.disconnect(_on_sprint)
		_player_input_manager.on_look.disconnect(_on_look)
		_player_input_manager.on_next.disconnect(_on_next)
		_player_input_manager.on_previous.disconnect(_on_previous)

# emit all signals at their default values
func _reset_input():
	on_move.emit(Vector3.ZERO)
	on_sprint.emit(false)
	on_look.emit(Vector2.ZERO)
	
func _on_move(velocity):
	on_move.emit(velocity)
func _on_sprint(is_sprinting):
	on_sprint.emit(is_sprinting)
func _on_look(view):
	on_look.emit(view)
func _on_next():
	on_next.emit()
func _on_previous():
	on_previous.emit()

func set_party_camera_manager(party_camera_manager: PartyCameraManager):
	_party_camera_manager = party_camera_manager
