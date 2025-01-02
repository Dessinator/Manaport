class_name Character extends CharacterBody3D

@export var _fsm: FiniteStateMachine
@export var _actor_scene: PackedScene

@export_category("Components")
@export var _character_visual_manager: CharacterVisualManager
@export var _character_skin: CharacterSkin
@export var _character_mover: CharacterMover
@export var _character_input_manager: CharacterInputManager
@export var _character_camera_manager: CharacterCameraManager

# gameplay variables
var _input_movement_velocity: Vector3
var _input_is_sprinting: bool
var _input_is_crawling: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	initialize()

func initialize():
	_character_mover.initialize(self)
	
	connect_input_component_signals()

func connect_input_component_signals():
	_character_input_manager.on_move.connect(_on_move)
	_character_input_manager.on_sprint.connect(_on_sprint)
	_character_input_manager.on_look.connect(_on_look)
	_character_input_manager.on_crawl.connect(_on_crawl)

func _on_move(movement_velocity):
	_input_movement_velocity = movement_velocity
func _on_sprint(is_sprinting):
	_input_is_sprinting = is_sprinting
func _on_look(view):
	_character_camera_manager.look(view)
func _on_crawl(is_crawling):
	_input_is_crawling = is_crawling

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	velocity = velocity.move_toward(
		_character_mover.move(
			delta,
			_input_movement_velocity,
			is_on_floor(),
			_input_is_sprinting),
		.80)
	
	move_and_slide()

func get_fsm() -> FiniteStateMachine:
	return _fsm
