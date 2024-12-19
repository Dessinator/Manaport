class_name Actor extends Node3D

signal actor_ready(actor: Actor)
signal actor_selected(actor: Actor)
signal actor_deselected(actor: Actor)

signal act_chosen(act: Act)

const MAX_READINESS: float = 10.0

@export var _is_party_member: bool

@export var _stats: ActorStats
@export var _visual_manager: ActorVisualManager
@export var _costume: ActorCostume
@export var _input_manager: ActorInputManager
@export var _acts_manager: ActsManager
@export var _status_effect_manager: ActorStatusEffectManager

@export var _status: ActorStatus

# time to wait in secs before getting ready
var _ready_delay: float = 0
# 0 to 10, once 10 is reached, this actor is "ready" to act.
var _readiness: float = 0
var _is_risen: bool
# used to prevent double turns if aglt is high enough
var _has_risen: bool
var _has_acted: bool

var _is_selected: bool

enum ActorModificationFunction
{
	MODIFY_STATUS,
	MODIFY_ACTS,
}

func _ready():
	if _is_party_member:
		add_to_group("party_member")
	else:
		add_to_group("enemy")
	
	initialize()

func initialize():
	_stats.initialize()
	_reset_status()
	_readiness = 0

func _reset_status():
	_status = ActorStatus.new()

	_status.died.connect(_on_died)

	_status.status_effect_applied.connect(_visual_manager._on_status_effect_applied)
	_status.status_effect_stack_applied.connect(_visual_manager._status_effect_stack_applied)
	_status.status_effect_ticked.connect(_visual_manager._status_effect_ticked)
	_status.status_effect_stack_removed.connect(_visual_manager._status_effect_stack_removed)
	_status.status_effect_removed.connect(_visual_manager._on_status_effect_removed)

	_status.damaged.connect(_visual_manager._on_damaged)
	_status.healed.connect(_visual_manager._on_healed)

	_visual_manager._actor_status = _status

	_status.initialize(self, _stats)

func update(delta):
	if _status.is_dead():
		# print(name + " is dead")
		return
	# print(name + " ready delay: " + str(_ready_delay))
	if _ready_delay > 0:
		_ready_delay -= delta
		return
	_ready_delay = 0

	_get_ready(delta)

func _get_ready(delta):
	if _is_risen:
		return

	_readiness += delta * (_stats.get_substat_curves().sample_aglt_curve(_stats.get_vtly(false, true), false, true) * 10)
	# print(name + ": readiness: " + str(_readiness))
	if _readiness >= MAX_READINESS:
		actor_ready.emit(self)

func rise():
	_is_risen = true
	_has_risen = true

	_status.tick_debuffs()
	_status.tick_general()

	_visual_manager.rise()

func choose_act():
	return await _input_manager.choose_act(self)
func choose_targets(target_actors: Array[Actor], act: Act) -> Array:
	return await _input_manager.choose_targets(self, act, target_actors)

func modify(modifications: Dictionary):
	# print(name + "'s modifications: \n" + str(modifications))
	for key in modifications.keys():
		var function = int(key[0])

		match function:
			ActorModificationFunction.MODIFY_STATUS:
				var method = key.substr(2, key.length() - 9)
				_status.callv(method, modifications[key])
			ActorModificationFunction.MODIFY_ACTS:
				var method = key.substr(2, key.length() - 9)
				_acts_manager.callv(method, modifications[key])
			

func _on_died():
	_status_effect_manager.clear_all_status_effects()

func fall():
	_status.tick_buffs()
	
	_has_acted = true
	_is_risen = false
	_readiness = 0

	_visual_manager.fall()

func reset():
	_has_risen = false
	_has_acted = false

func select():
	_is_selected = true
	actor_selected.emit()
	_visual_manager.show_select_actor_arrow()

func deselect():
	_is_selected = false
	actor_deselected.emit()
	_visual_manager.hide_select_actor_arrow()

func set_ready_delay(delay_seconds: float):
	_ready_delay = delay_seconds

func get_stats() -> ActorStats:
	return _stats
func get_status() -> ActorStatus:
	return _status
func get_costume() -> ActorCostume:
	return _costume
func get_visual_manager() -> ActorVisualManager:
	return _visual_manager
func get_input_manager() -> ActorInputManager:
	return _input_manager
func get_acts_manager() -> ActsManager:
	return _acts_manager
func get_status_effect_manager() -> ActorStatusEffectManager:
	return _status_effect_manager

func get_readiness() -> float:
	return _readiness
func has_risen() -> bool:
	return _has_risen
func has_acted() -> bool:
	return _has_acted

func is_party_member() -> bool:
	return _is_party_member

func print_stats():
	print(name + "'s stats:")
	print("ATTK (Attack): {value}".format({"value": _stats.get_attk(false, false)}))
	print("ATTK (Attack)/ATDM (Attack Damage): {value}".format({"value": _stats.get_substat_curves().sample_atdm_curve(_stats.get_attk(false, true), false, false)}))
	print("ATTK (Attack)/CRCH (Critical Chance): {value}".format({"value": _stats.get_substat_curves().sample_crch_curve(_stats.get_attk(false, true), false, false)}))
	print("ATTK (Attack)/CRML (Critical Multiplier): {value}".format({"value": _stats.get_substat_curves().sample_crml_curve(_stats.get_attk(false, true), false, false)}))
	print("--------------------")
	
	print("DFNS (Defense): {value}".format({"value": _stats.get_dfns(false, false)}))
	print("DFNS (Defense)/DMMT (Damage Mitigation): {value}".format({"value": _stats.get_substat_curves().sample_dmmt_curve(_stats.get_dfns(false, true), false, false)}))
	print("DFNS (Defense)/DBRS (Debuff Resistance): {value}".format({"value": _stats.get_substat_curves().sample_dbrs_curve(_stats.get_dfns(false, true), false, false)}))
	print("DFNS (Defense)/BFRT (Buff Retention): {value}".format({"value": _stats.get_substat_curves().sample_bfrt_curve(_stats.get_dfns(false, true), false, false)}))
	print("--------------------")
	
	print("VTLY (Vitality): {value}".format({"value": _stats.get_vtly(false, false)}))
	print("VTLY (Vitality)/MXHL (Max Health): {value}".format({"value": _stats.get_substat_curves().sample_mxhl_curve(_stats.get_vtly(false, true), false, false)}))
	print("VTLY (Vitality)/MXST (Max Stamina): {value}".format({"value": _stats.get_substat_curves().sample_mxst_curve(_stats.get_vtly(false, true), false, false)}))
	print("VTLY (Vitality)/AGLT (Agility): {value}".format({"value": _stats.get_substat_curves().sample_aglt_curve(_stats.get_vtly(false, true), false, false)}))
