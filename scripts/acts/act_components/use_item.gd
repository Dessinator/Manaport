class_name UseItem extends ActComponent

# mainly created and used internally
@export var _stage_inventory: StageInventory
@export var _item: Item

func consume(act: Act, acting_actor: Actor, receiving_actors: Array) -> Dictionary:
    var modifications = {}
    print("use item: " + _item.get_item_name())

    modifications.merge(_item.consume(receiving_actors[0]))
    var key = str(StageManager.StageModificationFunction.MODIFY_INVENTORY) + "_remove_item_" + Act.create_modification_id()
    modifications[key] = [act.get_stage(), [_item.get_item_name()]]

    if _item.get_quantity() - 1 <= 0:
        act.set_locked(true)

    return modifications

func get_item() -> Item:
    return _item
func set_item(item: Item):
    _item = item
