@tool
class_name CharacterDetectionRange extends Area3D

@export var _radius: float = 0.5

@onready var _collision_shape_3d: CollisionShape3D = %CollisionShape3D
@onready var _shape: SphereShape3D = _collision_shape_3d.shape

func _ready():
	_shape.radius = _radius

func _process(delta):
	if Engine.is_editor_hint():
		%CollisionShape3D.shape.radius = _radius
		return
