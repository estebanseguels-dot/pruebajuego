extends "res://src/systems/ai/enemy_state.gd"
class_name IdleState

@export var min_idle_time: float = 1.0
@export var max_idle_time: float = 3.0

var _timer: float = 0.0

func _init() -> void:
	state_type = StateType.IDLE

func enter() -> void:
	super()
	enemy.velocity = Vector2.ZERO
	_timer = randf_range(min_idle_time, max_idle_time)

func update(delta: float) -> void:
	_timer -= delta
	if _timer <= 0.0:
		fsm.queue_transition(StateType.PATROL)
