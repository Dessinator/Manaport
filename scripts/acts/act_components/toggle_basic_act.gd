class_name ToggleBasicAct extends ActComponent

@export var _enhance_basic_attack: bool

func consume(act: Act, acting_actor: Actor, receiving_actors: Array) -> Dictionary:
    var key = str(acting_actor.ActorModificationFunction.MODIFY_ACTS)
    if _enhance_basic_attack:
        return {key + "_enhance_basic_attack_" + str(Act.create_modification_id()): [acting_actor, []]}
    return {key + "_revert_basic_attack_" + str(Act.create_modification_id()): [acting_actor, []]}