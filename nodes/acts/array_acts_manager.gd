class_name ArrayActsManager extends Node

@export var _acts: Array[PackedScene]

var _cached_act_names: Array[String]

func _ready():
    var pool = ActsPool.get_instance()
    for i in range(_acts.size()):
        var act = _acts[i]
        _cached_act_names.append(pool.add_to_pool(act).name)

func get_all_act_instances() -> Array[Act]:
    var acts: Array[Act] = []
    for i in range(_acts.size()):
        acts.append(get_act_instance(i))
    return acts
    
func get_act_instance(index: int) -> Act:
    var instance = ActsPool.get_instance().take_from_pool(_cached_act_names[index])
    add_child(instance)
    return instance as Act

func add_act(act: PackedScene):
    _acts.append(act)
    _cached_act_names.append(ActsPool.get_instance().add_to_pool(act).name)

