class_name CharacterMover extends Node

# handles simple movement in a 3D space

var _character: Character
var _character_skin: CharacterSkin

# Gamplay mechanics and Inspector tweakables
@export var _gravity = 9.8
@export var _walk_speed = 3.0
@export var _sprint_speed = 5.5

# Condition States
var _is_moving: bool
var _is_walking: bool
var _is_sprinting: bool

# Physics values
var _horizontal_velocity: Vector3
var _vertical_velocity: Vector3
var _movement_speed: float
var _angular_acceleration: int
var _acceleration: int

func initialize(character: Character):
	_character = character

# calculate velocity for movement all in one function
# does NOT normalize direction
# returns velocity as Vec3
func move(delta, direction, is_on_floor, is_sprinting) -> Vector3:
	var new_velocity: Vector3
	
	_movement_speed = 0
	_angular_acceleration = 10
	_acceleration = 15

	# Gravity mechanics and prevent slope-sliding
	if not is_on_floor: 
		_vertical_velocity += Vector3.DOWN * _gravity * 2 * delta
	else: 
		#vertical_velocity = -get_floor_normal() * gravity / 3
		_vertical_velocity = Vector3.DOWN * _gravity / 10
	
	# Movement input, state and mechanics. *Note: movement stops if attacking
	if not direction.is_zero_approx():
		_is_moving = true
		_is_walking = true
		
	# Sprint input and movement speed
		if (is_sprinting and _is_walking):
			_movement_speed = _sprint_speed
			
			_is_sprinting = true
		else: # Walk State and speed
			_movement_speed = _walk_speed
			
			_is_sprinting = false
	else: 
		if _is_walking:
			_is_walking = false
		if _is_sprinting:
			_is_sprinting = false
	
	
	if not direction.is_zero_approx():
		_character.rotation.y = lerp_angle(_character.rotation.y, atan2(direction.x, direction.z), delta * _angular_acceleration)
	
	_horizontal_velocity = _horizontal_velocity.lerp(direction * _movement_speed, _acceleration * delta)
	
	# The Physics Sauce. Movement, gravity and velocity in a perfect dance.
	new_velocity.z = _horizontal_velocity.z + _vertical_velocity.z
	new_velocity.x = _horizontal_velocity.x + _vertical_velocity.x
	new_velocity.y = _vertical_velocity.y
	
	return new_velocity
