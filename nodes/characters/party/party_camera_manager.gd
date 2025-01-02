@tool
class_name PartyCameraManager extends CharacterCameraManager

# should override the CharacterCameraManager on the party members.
@onready var _party: Party = get_node("..")
func _get_configuration_warnings():
	if get_node("..") is Party:
		return []
	return ["PartyCameraComponent only works when it is the child of a Party node.
			Please add this node as a child of a Party node."]

#@export_category("General Settings")
#@export var _camera_distance = 1
#@export var _lerp_camera_position: bool = false
#
#@export_category("Camera Look Settings")
#@export var _camera_rotation_vertical_max = 75 # 75 recommended
#@export var _camera_rotation_vertical_min = -55 # -55 recommended
#@export var _joystick_sensitivity = 20
#@export var _horizontal_sensitivity = .01
#@export var _vertical_sensitivity = .01
#@export var _horizontal_acceleration = 10
#@export var _vertical_acceleration = 10
#
#@export_category("Camera Lerp Settings")
#@export var _lerp_acceleration = 10
#
#var _current: bool:
	#set(value):
		#_current = value
		#$horizontal/vertical/Camera3D.current = _current
#
#var _camera_rotation_horizontal = 0
#var _camera_rotation_vertical = 0
#var _joyview = Vector2()

var _target: Node3D

func _ready():
	if Engine.is_editor_hint():
		return
	super()

	$horizontal/vertical/Camera3D.current = true
	_party.on_party_leader_set.connect(_on_party_leader_set)

func _input(event):
	if Engine.is_editor_hint():
		return
	
	if event is InputEventMouseMotion:
		var horizontal = -event.relative.x
		var vertical = event.relative.y
		look(Vector2(horizontal, vertical))

func look(view):
	if Engine.is_editor_hint():
		return
	super(view)

func _physics_process(delta):
	if Engine.is_editor_hint():
		return
	
	_handle_position_lerp(_lerp_camera_position, delta)
	
	#var target_character = party.current_party_leader.get_parent()
	#var target_character_velocity = target_character.velocity
	#if target_character_velocity.y < 0.2:
		#target_character_velocity.y = 0.2
	#global_position = global_position.slerp(target_character.global_position + (target_character_velocity * 0.5), 0.05)
	
	$horizontal.rotation.y = lerpf(
		$horizontal.rotation.y,
		_camera_rotation_horizontal,
		delta * _horizontal_acceleration)
	$horizontal.rotation.x = lerpf(
		$horizontal.rotation.x,
		_camera_rotation_vertical,
		delta * _vertical_acceleration)

func _handle_position_lerp(do_lerp: bool, delta):
	if not do_lerp:
		return
	if not _target:
		return
	
	global_position = lerp(global_position, _target.global_position, delta * _lerp_acceleration)

func _on_party_leader_set(new_leader: CharacterPartyReference):
	_target = new_leader.get_parent()
	
