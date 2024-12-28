class_name FoodPreparer extends ItemComponent

const GLOBAL_FOOD_COMBINATION_RULESET: ItemCombinationRuleset = preload("res://resources/items/GLOBAL_FOOD_COMBINATION_RULESET.tres")

@export var _dish: WorldItem
@export var _ingredients: Array[WorldItem]

func initialize(item: Item):
	var dish_ingredient_definitions = _dish.get_item_components().filter(func(comp): return comp is IngredientDefinition)
	assert(dish_ingredient_definitions.size() > 0,
			"Item '{dish_name}' on {item_name} needs an IngredientDefinition!".format({"dish_name" : _dish.get_item_name(), "item_name" : item.get_item_name()}))
	assert(dish_ingredient_definitions[0].is_dish() or dish_ingredient_definitions[0].is_flask(),
			"Item '{dish_name}' on {item_name} must be a Dish!".format({"dish_name" : _dish.get_item_name(), "item_name" : item.get_item_name()}))

	assert(_ingredients.size() > 0,
			"Item '{item_name}' needs ingredients!".format({"item_name" : item.get_item_name()}))
	
	for ingredient in _ingredients:
		assert(ingredient != null,
				"Item '{item_name}' contains a null ingredient!".format({"item_name" : item.get_item_name()}))

		var ingredient_definitions = ingredient.get_item_components().filter(func(comp): return comp is IngredientDefinition)
		assert(ingredient_definitions.size() > 0,
				"Item '{ingredient_name}' on {item_name} needs an IngredientDefinition!".format({"ingredient_name" : ingredient.get_item_name(), "item_name" : item.get_item_name()}))
		
		if dish_ingredient_definitions[0].is_dish():
			assert(ingredient_definitions[0].is_food_ingredient(),
					"Item '{dish_name}' on {item_name} can only support Food Ingredients. Ingredient {ingredient_name} is a(n) {ingredient_type}.".format(
							{
							"dish_name" : _dish.get_item_name(),
							"item_name" : item.get_item_name(),
							"ingredient_name" : ingredient.get_item_name(),
							"ingredient_type" : str(IngredientDefinition.IngredientType.keys()[ingredient_definitions[0].get_ingredient_type()])
							}))
		elif dish_ingredient_definitions[0].is_flask():
			assert(ingredient_definitions[0].is_potion_ingredient(),
					"Item '{dish_name}' on {item_name} can only support Potion Ingredients. Ingredient {ingredient_name} is a(n) {ingredient_type}.".format(
							{
							"dish_name" : _dish.get_item_name(),
							"item_name" : item.get_item_name(),
							"ingredient_name" : ingredient.get_item_name(),
							"ingredient_type" : str(IngredientDefinition.IngredientType.keys()[ingredient_definitions[0].get_ingredient_type()])
							}))

		assert(not ingredient_definitions[0].is_dish(),
				"Item '{dish_name}' on {item_name} cannot be a Dish!".format({"dish_name" : _dish.get_item_name(), "item_name" : item.get_item_name()}))

	var combination_rules = GLOBAL_FOOD_COMBINATION_RULESET.get_rules()
	var possible_matching_rules = []
	for rule in combination_rules:
		assert(rule.has("dish"), "A rule on the Global Food Combination Ruleset does not contain a 'dish' requirement.")
		var dish = rule["dish"]
		if dish.get_item_name() != _dish.get_item_name():
			continue
		possible_matching_rules.append(rule)
		
	# find the first matching rule in possible_matching rules
	for i in range(possible_matching_rules.size()):
		var rule = possible_matching_rules[i]

		assert(rule.has("ingredients"), "A rule on the Global Food Combination Ruleset does not contain an 'ingredients' requirement.")
		var ingredients = rule["ingredients"]

		var matches = 0
		for required_ingredient in ingredients:
			for input_ingredient in _ingredients:
				# print("Testing Rule {rule_index}: \nRequired Ingredient: {req_ing} \nInput Ingredient: {in_ing}".format({
				# 		"rule_index": i,
				# 		"req_ing": required_ingredient.get_item_name(),
				# 		"in_ing": input_ingredient.get_item_name()
				# 	}))
				if required_ingredient.get_item_name() == input_ingredient.get_item_name():
					matches += 1
					break
		
		if matches < ingredients.size():
			continue
		
		assert(rule.has("result"), "A rule on the Global Food Combination Ruleset does not contain a 'result' definition.")
		var result = rule["result"]
		var resulting_food = result.duplicate()
		print(resulting_food.get_item_name())
		return {
			"add_item_" + Item.create_modification_id(): [resulting_food],
			"remove_item_" + Item.create_modification_id(): [item.get_item_name()]
		}

	return {}
