class_name UseItem extends ActComponent

# mainly created and used internally
@export var _stage_inventory: StageInventory
@export var _item: Item

func consume(act: Act, acting_actor: Actor, receiving_actors: Array) -> Dictionary:
    print("use item: " + _item.get_item_name())
    return { str(StageManager.StageModificationFunction.MODIFY_INVENTORY) + "_remove_item_" + Act.create_modification_id(): [act.get_stage(), [_item.get_item_name()]]}

func get_item() -> Item:
    return _item
func set_item(item: Item):
    _item = item
