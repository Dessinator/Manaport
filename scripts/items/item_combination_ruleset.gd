class_name ItemCombinationRuleset extends Resource

## Resulting item should be { "result" : VALUE }
@export var _rules: Array[Dictionary]

func get_rules() -> Array[Dictionary]:
    return _rules