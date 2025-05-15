class_name CharacterDynamicPartyHandler extends Node3D

@export var _party_reference: CharacterPartyReference

func _on_join_party_area_3d_body_entered(body: Node3D) -> void:
	pass # Replace with function body.

func _on_join_party_area_3d_body_exited(body: Node3D) -> void:
	pass # Replace with function body.


func _on_party_max_distance_area_3d_body_entered(body: Node3D) -> void:
	if not body is Character:
		return
	body = body as Character
	if not body.has_node("CharacterPartyReference"):
		return
	#var body_party_reference = body.get_node("CharacterPartyReference")
	
	if _party_reference.is_in_party():
		return
	
	var party = OverworldManager.create_party()
	_party_reference.join_party(party)

func _on_party_max_distance_area_3d_body_exited(body: Node3D) -> void:
	if not body is Character:
		return
	body = body as Character
	if not body.has_node("CharacterPartyReference"):
		return
	#var body_party_reference = body.get_node("CharacterPartyReference")
	
	# get all characters within the max distance
	
	if not _party_reference.is_in_party():
		return
	
	var party = _party_reference.get_current_party()
	_party_reference.leave_party(party)
	OverworldManager.remove_party(party)
