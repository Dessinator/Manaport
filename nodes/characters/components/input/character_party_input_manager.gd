class_name PartyInputComponent extends Node3D

# responsible for switching a character's input mode
# between player and AI.
#
# AI Input is to be used when the party reference component
# emits the "was_set_as_party_member" signal
#
# Player Input is to be used when the party reference component
# emits the "was_set_as_party_leader" signal 

signal jump
signal move(velocity)
signal sprint(is_sprinting)
signal look(view)
signal primary_attack
signal secondary_attack
signal target
signal next
signal previous

@onready var player_input_component = $PlayerInputComponent
@onready var ai_input_component = $AIInputComponent

#@export_category("Node")
#@export var party_reference_component: PartyReferenceComponent:
	#set(value):
		#party_reference_component = value
		#connect_party_reference_component_signals()
## will only be used in Player Input mode
#var party_camera_component: PartyCameraComponent:
	#set(value):
		#party_camera_component = value
		#player_input_component.camera_component = party_camera_component
#
#func connect_party_reference_component_signals():
	#party_reference_component.was_set_as_party_leader.connect(on_was_set_as_party_leader)
	#party_reference_component.was_set_as_party_member.connect(on_was_set_as_party_member)
#
#func on_was_set_as_party_leader():
	#connect_player_input_signals()
#func on_was_set_as_party_member():
	#connect_ai_input_signals()
	#ai_input_component.target_node = party_reference_component.current_party.current_party_leader

func connect_player_input_signals():
		player_input_component.jump.connect(_on_jump)
		player_input_component.move.connect(_on_move)
		player_input_component.sprint.connect(_on_sprint)
		player_input_component.look.connect(_on_look)
		player_input_component.primary_attack.connect(_on_primary_attack)
		player_input_component.secondary_attack.connect(_on_secondary_attack)
		player_input_component.target.connect(_on_target)
		player_input_component.next.connect(_on_next)
		player_input_component.previous.connect(_on_previous)
	
		ai_input_component.jump.disconnect(_on_jump)
		ai_input_component.move.disconnect(_on_move)
		ai_input_component.sprint.disconnect(_on_sprint)
		ai_input_component.look.disconnect(_on_look)
		ai_input_component.primary_attack.disconnect(_on_primary_attack)
		ai_input_component.secondary_attack.disconnect(_on_secondary_attack)
		ai_input_component.target.disconnect(_on_target)
		ai_input_component.next.disconnect(_on_next)
		ai_input_component.previous.disconnect(_on_previous)
func connect_ai_input_signals():
		ai_input_component.jump.connect(_on_jump)
		ai_input_component.move.connect(_on_move)
		ai_input_component.sprint.connect(_on_sprint)
		ai_input_component.look.connect(_on_look)
		ai_input_component.primary_attack.connect(_on_primary_attack)
		ai_input_component.secondary_attack.connect(_on_secondary_attack)
		ai_input_component.target.connect(_on_target)
		ai_input_component.next.connect(_on_next)
		ai_input_component.previous.connect(_on_previous)
	
		player_input_component.jump.disconnect(_on_jump)
		player_input_component.move.disconnect(_on_move)
		player_input_component.sprint.disconnect(_on_sprint)
		player_input_component.look.disconnect(_on_look)
		player_input_component.primary_attack.disconnect(_on_primary_attack)
		player_input_component.secondary_attack.disconnect(_on_secondary_attack)
		player_input_component.target.disconnect(_on_target)
		player_input_component.next.disconnect(_on_next)
		player_input_component.previous.disconnect(_on_previous)

func _on_jump():
	jump.emit()
func _on_move(velocity):
	move.emit(velocity)
func _on_sprint(is_sprinting):
	sprint.emit(is_sprinting)
func _on_look(view):
	look.emit(view)
func _on_primary_attack():
	primary_attack.emit()
func _on_secondary_attack():
	secondary_attack.emit()
func _on_target():
	target.emit()
func _on_next():
	next.emit()
func _on_previous():
	previous.emit()
