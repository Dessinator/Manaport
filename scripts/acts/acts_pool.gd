class_name ActsPool extends Node

static var _instance: ActsPool

var _stage: StageManager

var _pool: Dictionary

func _enter_tree():
    if _instance:
        return
    _instance = self

func add_to_pool(act_scene: PackedScene) -> Act:
    var instance: Act = act_scene.instantiate() as Act
    # print(instance)
    if _pool.has(instance.name):
        return _pool[instance.name]
    _pool[instance.name] = instance
    add_child(instance)
    instance._stage = _stage
    # _print_pool()

    return instance

func take_from_pool(act_name: String) -> Act:
    if not _pool[act_name]:
        return null

    remove_child(_pool[act_name])
    return _pool[act_name]

func return_to_pool(act: Act):
    if not _pool[str(act.name)]:
        return
    
    add_child(_pool[str(act.name)])

func _print_pool():
    print("------START PRINTED CONTENTS OF ACTS POOL------")
    for key in _pool.keys():
        print("Act Name: {name} :: Act Node: {node}".format({"name": key, "node": _pool[key]}))
    print("------END PRINTED CONTENTS OF ACTS POOL------")

static func get_instance() -> ActsPool:
    return _instance
func get_pool() -> Dictionary:
    return _pool