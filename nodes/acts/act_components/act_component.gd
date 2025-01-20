class_name ActComponent extends Node

enum ReferenceStatType
{
	ATTK = 0, # Attack
	DFNS = 1, # Defense
	VTLY = 2, # Soundness
	ATDM = 3, # Attack Damage
	CRCH = 4, # Crit. Chance
	CRML = 5, # Crit. Mult.
	DMMT = 6, # Damage Mitigation
	DBRS = 7, # Debuff Resistance
	BFRT = 8, # Buff Retention
	MXHL = 9, # Max Health
	MXST = 10, # Max Stamina
	AGLT = 11  # Agility
}

const REFERENCE_STAT_STRINGS = {
	0: "ATTK",
	1: "DFNS",
	2: "VTLY",
	3: "ATDM",
	4: "CRCH",
	5: "CRML",
	6: "DMMT",
	7: "DBRS",
	8: "BFRT",
	9: "MXHL",
	10: "MXST",
	11: "AGLT"
}

@export var _reference_receiving_actor: bool
@export var _reference_stat: ReferenceStatType

func consume(act: Act, acting_actor: Actor, receiving_actors: Array) -> Dictionary:
	return {}

func equals(other: ActComponent):
	return (self.name == other.name) and \
		   (self._reference_stat == other._reference_stat)

func _substat_to_main_stat(substat: ReferenceStatType) -> ReferenceStatType:
	if substat > 2 and substat < 6:
		return ReferenceStatType.ATTK
	elif substat > 5 and substat < 9:
		return ReferenceStatType.DFNS
	elif substat > 8 and substat < 12:
		return ReferenceStatType.VTLY
	else:
		return substat
