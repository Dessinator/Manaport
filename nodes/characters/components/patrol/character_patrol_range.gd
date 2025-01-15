@tool
class_name CharacterPatrolRange extends Area3D

@export var _radius: float = 0.5

@onready var _collision_shape_3d: CollisionShape3D = %CollisionShape3D
@onready var _shape: SphereShape3D = _collision_shape_3d.shape

func _ready():
	if Engine.is_editor_hint():
		return
	
	_shape.radius = _radius
	top_level = true

func _process(delta):
	if Engine.is_editor_hint():
		%CollisionShape3D.shape.radius = _radius
		return

func generate_random_target() -> Node3D:
	for child in get_children():
		remove_child(child)
	
	var random_pos = get_random_pos_in_sphere()
	var node = Node3D.new()
	add_child(node)
	node.position = random_pos
	return node

func get_random_pos_in_sphere() -> Vector3:
	var x1 = randf_range(-1, 1)
	var x2 = randf_range(-1, 1)

	while x1 * x1 + x2 * x2 >= 1:
		x1 = randf_range(-1, 1)
		x2 = randf_range(-1, 1)

	var random_pos_on_unit_sphere = Vector3 (
		2 * x1 * sqrt (1 - x1*x1 - x2*x2),
		2 * x2 * sqrt (1 - x1*x1 - x2*x2),
		1 - 2 * (x1*x1 + x2*x2))

	return random_pos_on_unit_sphere * randf_range(0, _radius)

func set_radius(radius: float):
	_radius = radius
	%CollisionShape3D.shape.radius = _radius
