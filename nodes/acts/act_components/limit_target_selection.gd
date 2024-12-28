class_name LimitTargetSelection extends ActComponent

# status effects that an actor must (or must not) have to be selectable

@export var _exclude: bool = false
@export var _status_effect_requirements: Array[StatusEffect]
@export var _must_have_met_all_requirements: bool = false

# returns true if actor meets the status effect requirements
func status_effect_match(actor: Actor) -> bool:
	if _must_have_met_all_requirements:
		for requirement in _status_effect_requirements:
			if _exclude:
				if actor.get_status().get_status_effects().has(requirement.get_status_effect_name()):
					return false
				continue

			if not actor.get_status().get_status_effects().has(requirement.get_status_effect_name()):
				return false
		return true
	
	for requirement in _status_effect_requirements:
		if _exclude:
			if not actor.get_status().get_status_effects().has(requirement.get_status_effect_name()):
				return true
			return false
		if actor.get_status().get_status_effects().has(requirement.get_status_effect_name()):
			return true
	return false
