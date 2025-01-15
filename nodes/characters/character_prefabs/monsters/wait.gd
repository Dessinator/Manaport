extends ActionLeaf

@export var _time_seconds = 1.0

var _internal_timer: Timer

func before_run(actor: Node, blackboard: Blackboard):
	if _internal_timer == null:
		_internal_timer = Timer.new()
		add_child(_internal_timer)
		_internal_timer.one_shot = true
	
	if _internal_timer.is_stopped():
		_internal_timer.wait_time = _time_seconds
		_internal_timer.start()

func tick(actor: Node, blackboard: Blackboard) -> int:
	if _internal_timer.time_left > 0.0:
		return RUNNING
	
	return SUCCESS
