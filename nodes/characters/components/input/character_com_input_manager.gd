class_name AIInputComponent extends NavigationAgent3D

@export var use_avoidance: bool = true
@export var avoidance_activiation_radius: float = 2.0

@onready var area_3d = $Area3D

var target_node: Node3D

signal jump
signal move(velocity)
signal sprint(is_sprinting)
signal look(view)
signal primary_attack
signal secondary_attack
signal target	
signal next
signal previous

func _physics_process(delta):
	if target_node != null:
		set_target_position(target_node.global_position)
	
	var overlapping_bodies = area_3d.get_overlapping_bodies()
	
	velocity = (get_next_path_position() - get_node("..").global_position).normalized()
	velocity.y = 0

func _on_avoidance_velocity_computed(safe_velocity):
	safe_velocity.y = 0
	move.emit(safe_velocity)
