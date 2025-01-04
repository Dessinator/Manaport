@tool
class_name CharacterCOMInputManager extends CharacterInputManager

func _get_configuration_warnings():
	if %NavigationAgent3D:
		return []
	return ["CharacterCOMInputManager requires a NavigationAgent3D child.
			Have you added the node as a child or instantiated a child scene?"]

@export var _recalcuation_delay_seconds: float = 1.0

@export_category("Nav Agent Settings")
@export_subgroup("Pathfinding")
@export var _path_desired_distance: float = 1.0
@export var _target_desired_distance: float = 1.0
@export var _path_height_offset: float = 0.0
@export var _path_max_distance: float = 5.0

@export_subgroup("Avoidance")
@export var _avoidance_enabled: bool = true
@export var _avoidance_height: float = 1.0
@export var _avoidance_radius: float = 0.5
@export var _neighbor_distance: float = 50.0
@export var _max_neighbors: int = 10
@export var _time_horizon_agents: float = 1.0
@export var _time_horizon_obstacles: float = 0.0
## in m/s
@export var _max_speed: float = 10.0
@export var _use_3D_avoidance: bool = false
@export var _keep_Y_velocity: bool = true
@export var _avoidance_priority: int = 1

@onready var _nav_agent: NavigationAgent3D = %NavigationAgent3D
@onready var _recalculate_path_timer: Timer = %RecalculatePathTimer

#@onready var area_3d = $Area3D

var _target_node: Node3D

func _ready():
	if Engine.is_editor_hint():
		return
	
	_setup_nav_agent()
	_setup_recalculation_delay()

func _setup_nav_agent():
	if Engine.is_editor_hint():
		return
	
	_nav_agent.path_desired_distance = _path_desired_distance
	_nav_agent.target_desired_distance = _target_desired_distance
	_nav_agent.path_height_offset = _path_height_offset
	_nav_agent.path_max_distance = _path_max_distance
	
	_nav_agent.avoidance_enabled = _avoidance_enabled
	_nav_agent.height = _avoidance_height
	_nav_agent.radius = _avoidance_radius
	_nav_agent.neighbor_distance = _neighbor_distance
	_nav_agent.max_neighbors = _max_neighbors
	_nav_agent.time_horizon_agents = _time_horizon_agents
	_nav_agent.max_speed = _max_speed
	_nav_agent.use_3d_avoidance = _use_3D_avoidance
	_nav_agent.keep_y_velocity = _keep_Y_velocity
	_nav_agent.avoidance_priority = _avoidance_priority
	
	_nav_agent.velocity_computed.connect(_on_avoidance_velocity_computed)

func _setup_recalculation_delay():
	if Engine.is_editor_hint():
		return
	
	_recalculate_path_timer.wait_time = _recalcuation_delay_seconds
	_recalculate_path_timer.start()
	_recalculate_path_timer.timeout.connect(_on_recalculate_path_timeout)

func _on_recalculate_path_timeout():
	if Engine.is_editor_hint():
		return
	
	if _target_node:
		_nav_agent.set_target_position(_target_node.global_position)

func _physics_process(delta):
	if Engine.is_editor_hint():
		return
	
	#var overlapping_bodies = area_3d.get_overlapping_bodies()
	
	_nav_agent.velocity = (_nav_agent.get_next_path_position() - global_position).normalized()
	_nav_agent.velocity.y = 0

func _on_avoidance_velocity_computed(safe_velocity):
	if Engine.is_editor_hint():
		return
	
	safe_velocity.y = 0
	on_move.emit(safe_velocity.normalized())

func set_target_node(node: Node3D):
	if Engine.is_editor_hint():
		return
	
	_target_node = node
