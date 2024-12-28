class_name ApplyStatusEffects extends ItemComponent

@export var _status_effects: Array[StatusEffect]

func consume(item: Item, receiving_actor: Actor) -> Dictionary:
    var modifications = {}
    for status_effect in _status_effects:
        var duplicate = status_effect.duplicate()
        var key = str(Actor.ActorModificationFunction.MODIFY_STATUS) + "_apply_status_effect_" + str(Act.create_modification_id())
        modifications[key] = [receiving_actor, [duplicate, 1, true]]

    return modifications
