class_name ModifyGlobalActComponents extends ActComponent

@export var _include_this_act: bool
@export var _remove_instead_of_add: bool
@export var _exclude_list: Array[String]

var _act_components: Array[ActComponent]

func _ready():
	for child in get_children():
		if not child is ActComponent:
			continue
		_act_components.append(child as ActComponent)

func consume(act: Act, acting_actor: Actor, receiving_actors: Array) -> Dictionary:
	var acts = ActsPool.get_instance().get_pool()

	for a in acts.keys():
		if (not _include_this_act and a == act.name):
			continue
		
		var excluded = false
		for exclusion in _exclude_list:
			if a == exclusion:
				excluded = true
				break
		if excluded:
			continue
		
		for comp in _act_components:
			if _remove_instead_of_add:
				acts[a].remove_act_component(comp)
				continue
			var dupe = comp.duplicate() as ActComponent
			acts[a].add_act_component(dupe)

	return {}
