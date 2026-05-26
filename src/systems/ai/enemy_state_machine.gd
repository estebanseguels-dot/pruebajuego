extends Node
class_name EnemyStateMachine

signal state_changed(old_state, new_state)

var states: Dictionary = {}
var current_state
var enemy
var _pending_transition = -1

func _ready() -> void:
	name = "EnemyStateMachine"

func setup(controller) -> void:
	enemy = controller
	for child in get_children():
		var s = child
		if s:
			s.setup(self, controller)
			states[s.state_type] = s

func start(initial) -> void:
	var s = states.get(initial)
	if s:
		current_state = s
		current_state.enter()

func transition_to(target) -> void:
	if _pending_transition >= 0:
		return
	var next = states.get(target)
	var prev = current_state
	if not next or next == prev:
		return
	if prev and not prev.can_transition_to(target):
		return
	_pending_transition = -1
	if prev:
		prev.exit()
	current_state = next
	current_state.enter()
	state_changed.emit(prev.state_type if prev else -1, target)

func force_transition(target) -> void:
	_pending_transition = -1
	var next = states.get(target)
	var prev = current_state
	if not next or next == prev:
		return
	if prev:
		prev.exit()
	current_state = next
	current_state.enter()
	state_changed.emit(prev.state_type if prev else -1, target)

func queue_transition(target) -> void:
	_pending_transition = target

func _process(delta: float) -> void:
	if _pending_transition >= 0:
		transition_to(_pending_transition)
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func get_state(type):
	return states.get(type)
