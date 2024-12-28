class_name CharacterMover extends Node

# handles simple movement in a 3D space

var _character: Character

var _fsm: FiniteStateMachine
var _blackboard: Blackboard

# Gamplay mechanics and Inspector tweakables
@export var gravity = 9.8
@export var jump_force = 9
@export var walk_speed = 1.3
@export var run_speed = 5.5
@export var dash_power = 12

# Condition States
#var is_attacking: bool
#var is_rolling: bool
#var is_walking: bool
#var is_running: bool

# Physics values
var direction: Vector3
var horizontal_velocity: Vector3
var vertical_velocity: Vector3
var movement: Vector3
var aim_turn: float
var movement_speed: int
var angular_acceleration: int
var acceleration: int

func initialize(character: Character):
	_character = character
	
	_fsm = _character.get_fsm()
	_blackboard = _fsm.blackboard

# calculate velocity for movement all in one function
# does NOT normalize direction
# returns velocity as Vec3
func move(delta, direction, is_on_floor, is_sprinting) -> Vector3:
	print("move " + str(direction))
	var new_velocity: Vector3
	
	movement_speed = 0
	angular_acceleration = 10
	acceleration = 15

	# Gravity mechanics and prevent slope-sliding
	if not is_on_floor: 
		vertical_velocity += Vector3.DOWN * gravity * 2 * delta
	else: 
		#vertical_velocity = -get_floor_normal() * gravity / 3
		vertical_velocity = Vector3.DOWN * gravity / 10
	
	# Movement input, state and mechanics. *Note: movement stops if attacking
	if not direction.is_zero_approx():
		_blackboard.set_value("is_moving", true)
		_blackboard.set_value("is_walking", true)
		_fsm.fire_event("start_walking")
		
	# Sprint input and movement speed
		if is_sprinting and (_blackboard.get_value("is_walking")):
			movement_speed = run_speed
			
			_blackboard.set_value("is_sprinting", true)
			_fsm.fire_event("start_sprinting")
		else: # Walk State and speed
			movement_speed = walk_speed
			
			_blackboard.set_value("is_sprinting", false)
			_fsm.fire_event("stop_sprinting")
	else: 
		if _blackboard.get_value("is_walking"):
			_blackboard.set_value("is_walking", false)
			_fsm.fire_event("stop_walking")
		if _blackboard.get_value("is_sprinting"):
			_blackboard.set_value("is_sprinting", false)
			_fsm.fire_event("stop_sprinting")
	
	## Movment mechanics with limitations during rolls/attacks
	#if ((is_attacking == true) or (is_rolling == true)): 
		#horizontal_velocity = horizontal_velocity.lerp(direction * .01 , acceleration * delta)
	#else: # Movement mechanics without limitations 
	horizontal_velocity = horizontal_velocity.lerp(direction * movement_speed, acceleration * delta)
	
	# The Physics Sauce. Movement, gravity and velocity in a perfect dance.
	new_velocity.z = horizontal_velocity.z + vertical_velocity.z
	new_velocity.x = horizontal_velocity.x + vertical_velocity.x
	new_velocity.y = vertical_velocity.y
	
	return new_velocity

# calculate velocity for jump
# returns velocity as Vec3
func jump(is_on_floor) -> Vector3:
	if is_on_floor:
		return Vector3.UP * jump_force
	else:
		return Vector3.ZERO
