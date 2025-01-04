@tool
class_name CharacterPartyFormation extends Node3D

# responsible for defining a "Formation" or >= 1 positions for other party members
# to fall into when the parent Character is the party leader.
func _get_configuration_warnings():
	var children = get_children()
	if children.is_empty():
		return ["A CharacterPartyFormation requires 1 or more Node3D children."]
	if not children.all(func(child): return child is Node3D):
		return ["1 or more children are not of Type Node3D."]
