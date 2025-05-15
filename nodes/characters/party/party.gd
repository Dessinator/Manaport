class_name Party extends Node

var _members: Array

func _ready():
	_add_children_to_party()

func _add_children_to_party():
	# get all children with a CharacterPartyReference node and add them to the members dictionary
	var children = get_children()
	var children_with_party_references = children.filter(func(child): return child.has_node("CharacterPartyReference"))
	if children_with_party_references.size() == 0:
		return
	
	for child in children_with_party_references:
		_members.append(child.get_node("CharacterPartyReference"))
	
	for member in _members:
		member.join_party(self)

## will add the party_reference's parent as a child.
func add_to_party(member: CharacterPartyReference):
	var parent = member.get_parent()
	parent.call_deferred("reparent", self)
	
	_members.append(member)
	member.join_party(self)

func kick_from_party(member: CharacterPartyReference):
	assert(_members.has(member), "Attempt to kick member '{member_name}' from party of which it is not a member of."
			.format({"member_name": member.get_parent().name}))
	
	var parent = member.get_parent()
	parent.call_deferred("reparent", get_parent())
	
	_members.erase(member)
	member.leave_party(self)
	
	if _members.is_empty():
		OverworldManager.remove_party(self)

func get_members() -> Array:
	return _members
