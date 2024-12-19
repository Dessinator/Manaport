class_name StageInventory extends Resource

@export var _starting_items: Array
var _items: Dictionary

func initialize():
    if _starting_items.size() != 0:
        for item in _starting_items:
            item.handle_item_name_fallback()
            _items[item.get_item_name()] = item.duplicate()
    
    var modifications = {}
    for item in _items.values():
        modifications.merge(item.initialize())
    
    modify(modifications)

func modify(modifications: Dictionary):
    for key in modifications.keys():
        var method = key.substr(0, key.length() - 7)
        callv(method, modifications[key])

func add_item(item: Item):
    if _items.has(item.get_item_name()):
        var existing_item = _items[item.get_item_name()]
        existing_item.add(1)
        return
    
    var dupe = item.duplicate()
    _items[dupe.get_item_name()] = dupe.duplicate()
    # print_items()
    
    modify(dupe.initialize())

# func remove_exact_item(item: Item):
#     if not _items.values().has(item):
#         print("Attempted to remove exact item '{item_to_remove}' from inventory when such an item is not in the inventory.".format({"item_to_remove": item.get_item_name}))
#         return
    
#     var item_to_remove
#     for i in _items.values():
#         if i != item_to_remove:
#             continue
#         item_to_remove = i
#     _items.erase(item_to_remove)

func remove_item(item_name: String):
    if not _items.has(item_name):
        print("Attempted to remove item '{item_to_remove}' from inventory when such an item is not in the inventory.".format({"item_to_remove": item_name}))
        return
    
    var item = _items[item_name]
    item.remove(1)
    if item.get_quantity() <= 0:
        _items.erase(item_name)
    # print_items()

func get_items() -> Dictionary:
    return _items

func get_consumable_items_as_acts() -> Array:
    var acts = []

    for item_name in _items.keys():
        var item = _items[item_name]

        if not item.is_consumable():
            continue
        
        var act = Act.new()

        act.name = "ACT_INT_" + item_name.to_snake_case().to_upper()

        act._name = item_name
        act._friendly_fire = item.is_friendly_fire()
        act._type = item.get_use_type()

        var use_item_component = UseItem.new()

        act.add_child(use_item_component)
        use_item_component.owner = act

        use_item_component._stage_inventory = self
        use_item_component._item = item

        # act._act_components.append(use_item_component)

        acts.append(act)
    
    return acts

func print_items():
    print("------START PRINTED CONTENTS OF STAGE INVENTORY------")
    for item_name in _items.keys():
        print("Item Name: {name} :: Item: {quantity}x {resource}".format({
            "name"    : item_name,
            "quantity": _items[item_name].get_quantity(),
            "resource": _items[item_name]
            }))
    print("------END PRINTED CONTENTS OF STAGE INVENTORY------")
