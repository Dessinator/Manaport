class_name ActorWeakness extends Resource

@export var _debuff: StatusEffect

@export var _damage_boost_percentage: float

func calc_total_damage(damage: int):
    return int(damage + (damage * _damage_boost_percentage))
