class_name IngredientDefinition extends ItemComponent

enum IngredientType
{
    # dishes
    DISH_CRUDE_PLATE,
    DISH_WOODEN_PLATE,
    DISH_CERAMIC_PLATE,
    DISH_GLASS_PLATE,

    DISH_CRUDE_BOWL,
    DISH_WOODEN_BOWL,
    DISH_CERAMIC_BOWL,
    DISH_GLASS_BOWL,

    DISH_CRUDE_TEACUP,
    DISH_WOODEN_TEACUP,
    DISH_CERAMIC_TEACUP,
    DISH_GLASS_TEACUP,


    # flasks
    FLASK_TEST_TUBE,
    FLASK_CONICAL,
    FLASK_FLORENCE,


    # food ingredients
    FING_PROTEIN,
    FING_NOODLES,
    FING_SPICES,
    FING_LIQUID,
    FING_VEGETABLE,
    FING_LEAF,
    FING_SUGAR,


    # potion ingredients
    PING_RESTORATION,
    PING_RESISTANCE
}
@export var _ingredient_type: IngredientType = IngredientType.DISH_CRUDE_PLATE

func get_ingredient_type() -> IngredientType:
    return _ingredient_type

func is_dish():
    return _ingredient_type >= 0 and _ingredient_type <= 11

func is_flask():
    return _ingredient_type >= 12 and _ingredient_type <= 14
func is_food_ingredient():
    return _ingredient_type >= 15 and _ingredient_type <= 21
func is_potion_ingredient():
    return _ingredient_type >= 22 and _ingredient_type <= 23
