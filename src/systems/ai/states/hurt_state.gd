extends "res://src/systems/ai/enemy_state.gd"
class_name HurtState

var _timer: float = 0.3

func _init() -> void:
	state_type = StateType.HURT

func enter() -> void:
	super()
	_timer = enemy.hurt_stun_time
	enemy.hitbox.active = false

func update(delta: float) -> void:
	_timer -= delta
	enemy.velocity = enemy.velocity.move_toward(Vector2.ZERO, enemy.friction * 5.0 * delta)
	enemy.move_and_slide()
	if _timer <= 0.0:
		if enemy._player_ref and is_instance_valid(enemy._player_ref):
			fsm.queue_transition(EnemyState.StateType.CHASE)
		else:
			fsm.queue_transition(EnemyState.StateType.PATROL)

func exit() -> void:
	super()
	enemy.hitbox.active = false
