extends "res://src/systems/ai/enemy_state.gd"
class_name RetreatState

@export var retreat_distance: float = 120.0
@export var retreat_speed_multiplier: float = 1.2

var _retreat_target: Vector2 = Vector2.ZERO

func _init() -> void:
	state_type = StateType.RETREAT

func enter() -> void:
	super()
	var away = Vector2.ZERO
	if enemy._player_ref and is_instance_valid(enemy._player_ref):
		away = (enemy.global_position - enemy._player_ref.global_position).normalized()
	else:
		away = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	_retreat_target = enemy.global_position + away * retreat_distance

func update(_delta: float) -> void:
	var dir = (_retreat_target - enemy.global_position).normalized()
	enemy.velocity = dir * enemy.chase_speed * retreat_speed_multiplier
	enemy.update_facing(-dir)
	enemy.move_and_slide()

	if enemy.global_position.distance_to(_retreat_target) < 16.0:
		fsm.queue_transition(EnemyState.StateType.CHASE)

	if enemy.health and enemy.health.get_percentage() > 0.6:
		fsm.queue_transition(EnemyState.StateType.CHASE)
