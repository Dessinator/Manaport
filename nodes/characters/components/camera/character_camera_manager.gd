class_name CharacterCameraManager extends Node3D

@export_category("General")
@export var _camera_distance = 1
@export var _lerp_camera_position: bool = false

@export_category("Camera Look Settings")
@export var _camera_rotation_vertical_max = 75 # 75 recommended
@export var _camera_rotation_vertical_min = -55 # -55 recommended
@export var _joystick_sensitivity = 20
@export var _horizontal_sensitivity = .01
@export var _vertical_sensitivity = .01
@export var _horizontal_acceleration = 10
@export var _vertical_acceleration = 10

@export_category("Camera Lerp Settings")
@export var _lerp_acceleration = 10

var _current: bool:
	set(value):
		_current = value
		$horizontal/vertical/Camera3D.current = _current

var _camera_rotation_horizontal = 0
var _camera_rotation_vertical = 0
var _joyview = Vector2()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	$horizontal/vertical.position.z = -_camera_distance
	$horizontal/vertical.position.y = _camera_distance
	
	top_level = _lerp_camera_position

func look(view):
	_camera_rotation_horizontal += view.x * _horizontal_sensitivity
	_camera_rotation_vertical += view.y * _vertical_sensitivity

func look_at_target(target: Vector3) -> void:
	var direction = (target - global_position).normalized()
	var rotation_horizontal = atan2(direction.z, direction.x)
	_camera_rotation_horizontal = rotation_horizontal

func _physics_process(delta):
	_handle_position_lerp(_lerp_camera_position, delta)
	
	_camera_rotation_vertical = clamp(
		_camera_rotation_vertical,
		deg_to_rad(_camera_rotation_vertical_min),
		deg_to_rad(_camera_rotation_vertical_max))

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
	
	global_position = lerp(global_position, get_parent().global_position, delta * _lerp_acceleration)
