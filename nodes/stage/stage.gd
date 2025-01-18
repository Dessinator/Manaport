class_name StageManager extends Node3D

signal cut(condition: StageCutCondition)
enum StageCutCondition { CONDITION_WIN, CONDITION_LOSS }

const TOUGHNESS_STATUS_EFFECT = preload("res://resources/status_effects/buffs/STEFF_B_TOUGHNESS.tres")

const CRYO_WARD_STATUS_EFFECT = preload("res://resources/status_effects/buffs/elemental_wards/STEFF_B_CRYO_WARD.tres")
const PYRO_WARD_STATUS_EFFECT = preload("res://resources/status_effects/buffs/elemental_wards/STEFF_B_PYRO_WARD.tres")
const TOXI_WARD_STATUS_EFFECT = preload("res://resources/status_effects/buffs/elemental_wards/STEFF_B_TOXI_WARD.tres")
const VOLT_WARD_STATUS_EFFECT = preload("res://resources/status_effects/buffs/elemental_wards/STEFF_B_VOLT_WARD.tres")

const READY_DELAY_FACTOR = 0.1

@onready var _stage_interface: StageInterface = %StageInterface
@onready var _stage_acts_manager: ArrayActsManager = %ArrayActsManager
@onready var _actors_container = %Actors

@onready var _ready_actor_position = %ReadyActorPosition
@onready var _next_ready_actor_position = %NextReadyActorPosition
@onready var _last_ready_actor_position = %LastReadyActorPosition

var _cycle: int = 0

var _ready_actor: Actor
var _actors: Array[Actor]

@export var _starting_stage_inventory: StageInventory
var _stage_inventory: StageInventory

var _acts_pool: ActsPool

enum StageModificationFunction
{
	MODIFY_INVENTORY,
}

func _enter_tree():
	if _starting_stage_inventory:
		_stage_inventory = _starting_stage_inventory.duplicate()
	else:
		_stage_inventory = StageInventory.new()
	_stage_inventory.initialize()
	
	_acts_pool = ActsPool.new()
	_acts_pool._stage = self
	add_child(_acts_pool)

func _ready():
	var consumable_item_acts = _stage_inventory.get_consumable_items_as_acts()

	for act in consumable_item_acts:
		var scene = PackedScene.new()
		scene.pack(act)
		_stage_acts_manager.add_act(scene)

func add_actors(actors: Array):
	for actor in actors:
		var actor_instance = actor.instantiate()
		%Actors.add_child(actor_instance)
	
	var party_member_counter = 0
	var enemy_counter = 0
	for actor in %Actors.get_children():
		if actor.is_party_member():
			actor.reparent($POIs/PartyMember.get_child(party_member_counter), false)
			actor.reparent(%Actors)
			party_member_counter += 1
			continue
		
		actor.reparent($POIs/Enemy.get_child(enemy_counter), false)
		actor.reparent(%Actors)
		enemy_counter += 1

func action():
	for i in range(_actors_container.get_children().size()):
		var actor = _actors_container.get_child(i)
		_actors.append(actor as Actor)

		var actor_input_manager = actor.get_input_manager()
		if actor_input_manager is ActorPlayerInputManager:
			actor_input_manager.attach_stage_interface(_stage_interface)

		actor.actor_ready.connect(_on_actor_ready)

		_stage_interface.instantiate_action_order_visual_scene(actor)
		if actor.get_visual_manager().get_mini_actor_info_container():
			_stage_interface.instantiate_mini_actor_info_scene(actor)
		
		actor.set_ready_delay(READY_DELAY_FACTOR * i)

		# actor.initialize()

		if not actor.is_in_group("party_member"):
			# apply the required wards
			var modifications = {}
			for j in range(actor.get_stats().get_wards().size()):
				modifications[str(actor.ActorModificationFunction.MODIFY_STATUS) + "_apply_status_effect_" + str(Act.create_modification_id())] = [actor.get_stats().get_wards()[j], 3]
			actor.modify(modifications)
			continue
		
		_stage_interface.instantiate_actor_info_scene(actor)
	
	_cycle = 1

func _process(delta):
	if not _ready_actor:
		update_actors(delta)

func modify(modifications: Dictionary):
	# print(name + "'s modifications: \n" + str(modifications))
	for key in modifications.keys():
		var function = int(key[0])

		match function:
			StageModificationFunction.MODIFY_INVENTORY:
				var method = key.substr(2, key.length() - 9)
				_stage_inventory.callv(method, modifications[key])

func update_actors(delta):
	for actor in _actors:
		if not actor.has_risen():
			actor.update(delta)

func _on_actor_ready(actor: Actor):
	_play_turn(actor)

	if _actors.all(func(a): return a.has_risen() or a.get_status().is_dead()):	
		_new_cycle()

func _play_turn(actor: Actor):
	_ready_actor = actor
	_ready_actor.rise()

	var chosen_act: Act
	var chosen_targets: Array = []
	while (chosen_act == null or chosen_targets.size() == 0):
		chosen_act = await _ready_actor.choose_act()
		# cancelled act selection
		if chosen_act == null:
			continue

		chosen_targets = await _ready_actor.choose_targets(get_eligible_actors(chosen_act), chosen_act)

	await chosen_act.use(actor, chosen_targets)
	await get_tree().create_timer(1.0).timeout
	actor.get_acts_manager().remove_child(chosen_act)
	ActsPool.get_instance().return_to_pool(chosen_act)
	_ready_actor.fall()
	_ready_actor = null
	
	#var alive_actors_string = "Alive actors\n"
	#for i in range(get_alive_actors().size()):
		#var a = get_alive_actors()[i]
		#alive_actors_string += a.name + " "
		##actor.set_ready_delay(READY_DELAY_FACTOR * i)
		##actor.reset()
	#print(alive_actors_string)
	
	_handle_cut()

func _new_cycle():
	_cycle += 1
	var alive_actors_string = "Alive actors for cycle " + str(_cycle) + "\n"
	for i in range(get_alive_actors().size()):
		var actor = get_alive_actors()[i]
		alive_actors_string += actor.name + " "
		actor.set_ready_delay(READY_DELAY_FACTOR * i)
		actor.reset()
	print(alive_actors_string)

func _handle_cut():
	var alive_actors = get_alive_actors()
	
	if alive_actors.all(func(actor): return actor.is_party_member() == true):
		print("yuo won!!!!")
		cut.emit(StageCutCondition.CONDITION_WIN)
		get_tree().quit()
	elif alive_actors.all(func(actor): return actor.is_party_member() == false):
		print("you loss,,,,")
		cut.emit(StageCutCondition.CONDITION_LOSS)
		get_tree().quit()
	

func get_alive_actors() -> Array:
	return _actors.filter(func(actor): return not actor.get_status().is_dead())
func get_eligible_actors(act: Act) -> Array:
	var eligible_actors = get_alive_actors()

	# search for any LimitTargetSelection components first
	var target_selection_limiters = act.get_components().filter(func(comp): return comp is LimitTargetSelection)
	if target_selection_limiters.size() == 0:
		return eligible_actors
	
	var indexes_to_remove = []
	for limiter in target_selection_limiters:
		for i in range(eligible_actors.size()):
			if not limiter.status_effect_match(eligible_actors[i]):
				indexes_to_remove.append(i)
	
	indexes_to_remove.reverse()
	for index in indexes_to_remove:
		eligible_actors.remove_at(index)
	
	return eligible_actors
	
func get_stage_inventory() -> StageInventory:
	return _stage_inventory

func get_stage_acts_manager() -> ArrayActsManager:
	return _stage_acts_manager
