extends "res://src/systems/ai/enemy_state.gd"
class_name PatrolState

var _target: Vector2 = Vector2.ZERO
var _spawn: Vector2 = Vector2.ZERO

func _init() -> void:
	state_type = StateType.PATROL

func enter() -> void:
	super()
	_spawn = enemy.global_position
	_pick_new_target()

func update(_delta: float) -> void:
	var dir = (_target - enemy.global_position).normalized()
	enemy.velocity = dir * enemy.move_speed
	enemy.update_facing(dir)
	enemy.move_and_slide()
	if enemy.global_position.distance_to(_target) < 8.0:
		_pick_new_target()

func can_transition_to(target) -> bool:
	return target != EnemyState.StateType.PATROL

func _pick_new_target() -> void:
	var range_x = randf_range(-enemy.patrol_range, enemy.patrol_range)
	var range_y = randf_range(-enemy.patrol_range, enemy.patrol_range)
	_target = _spawn + Vector2(range_x, range_y)
