class_name ChangeActs extends ActComponent

# will set the acts in the acting actor's ActsManager as
# the following act when this act is consumed.

@export var _basic_move_path: String

@export var _skill_1_path: String
@export var _skill_2_path: String

func consume(act: Act, acting_actor: Actor, receiving_actors: Array) -> Dictionary:

    if _basic_move_path != "": acting_actor.get_acts_manager().set_basic_move(load(_basic_move_path))
    if _skill_1_path != "": acting_actor.get_acts_manager().set_skill_1(load(_skill_1_path))
    if _skill_2_path != "": acting_actor.get_acts_manager().set_skill_2(load(_skill_2_path))

    return {}