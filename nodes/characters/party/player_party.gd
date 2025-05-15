class_name PlayerParty extends Party

signal on_party_leader_set(new_leader: CharacterPartyReference)

@export var _party_camera_manager: PartyCameraManager

var _current_party_leader: CharacterPartyReference
var _last_party_leader: CharacterPartyReference
var _oldest_party_leader: CharacterPartyReference

var _changed_party_leader_this_frame: bool = false

func _ready():
	super()
	
	_setup_party_input_components()
	
	_oldest_party_leader = _members[-1]
	_last_party_leader = _members[1]
	set_party_leader(_members[0])

func _setup_party_input_components():
	for member in _members:
		# get the parent node
		var parent = member.get_parent()
		
		# check if parent node has a CharacterPartyInputManager node child
		if not parent.has_node("CharacterPartyInputManager"):
			continue
		
		var character_party_input_manager: CharacterPartyInputManager = parent.get_node("CharacterPartyInputManager")
		character_party_input_manager.set_party_camera_manager(_party_camera_manager)

func _process(delta):
	_changed_party_leader_this_frame = false

func is_party_leader(member: CharacterPartyReference) -> bool:
	return member == _current_party_leader

func set_party_leader(member: CharacterPartyReference) -> void:
	if _changed_party_leader_this_frame:
		return
	if not _members.has(member):
		return
	
	if _oldest_party_leader == member:
		_oldest_party_leader = _last_party_leader
	if _current_party_leader:
		_last_party_leader = _current_party_leader
	_current_party_leader = member
	_changed_party_leader_this_frame = true
	on_party_leader_set.emit(_current_party_leader)
	
	print("---------------------")
	print("Oldest Party Member: " + _oldest_party_leader.get_parent().name)
	print("Last Party Member: " + _last_party_leader.get_parent().name)
	print("Current Party Member: " + _current_party_leader.get_parent().name)
func next_party_leader() -> void:
	if _members.find(_current_party_leader) + 1 >= _members.size():
		set_party_leader(_members[0])
	else:
		set_party_leader(_members[_members.find(_current_party_leader) + 1])
func previous_party_leader() -> void:
	if _members.find(_current_party_leader) - 1 <= -1:
		set_party_leader(_members[-1])
	else:
		set_party_leader(_members[_members.find(_current_party_leader) - 1])

func get_current_party_leader() -> CharacterPartyReference:
	return _current_party_leader
func get_last_party_leader() -> CharacterPartyReference:
	return _last_party_leader
func get_oldest_party_leader() -> CharacterPartyReference:
	return _oldest_party_leader
