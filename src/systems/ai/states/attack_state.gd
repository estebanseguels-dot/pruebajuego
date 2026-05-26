extends "res://src/systems/ai/enemy_state.gd"
class_name AttackState

enum AttackPhase { STARTUP, ACTIVE, RECOVERY }

var _phase: AttackPhase = AttackPhase.STARTUP
var _timer: float = 0.0
var _dir: Vector2 = Vector2.DOWN

func _init() -> void:
	state_type = StateType.ATTACK

func enter() -> void:
	super()
	_phase = AttackPhase.STARTUP
	_timer = enemy.attack_startup
	enemy.velocity = Vector2.ZERO
	_dir = enemy._facing_dir

	if enemy._player_ref and is_instance_valid(enemy._player_ref):
		_dir = (enemy._player_ref.global_position - enemy.global_position).normalized()
		enemy.update_facing(_dir)
		enemy.position_hitbox(_dir)

func update(delta: float) -> void:
	_timer -= delta
	if _timer > 0.0:
		return

	match _phase:
		AttackPhase.STARTUP:
			enemy.hitbox.active = true
			enemy.hitbox.damage = enemy.attack_damage
			_timer = enemy.attack_active
			_phase = AttackPhase.ACTIVE

		AttackPhase.ACTIVE:
			enemy.hitbox.active = false
			_timer = enemy.attack_recovery
			_phase = AttackPhase.RECOVERY

		AttackPhase.RECOVERY:
			enemy.hitbox.active = false
			var hp_pct = enemy.health.get_percentage() if enemy.health else 1.0
			if hp_pct < 0.3:
				fsm.queue_transition(EnemyState.StateType.RETREAT)
			else:
				enemy._attack_cooldown_timer = enemy.attack_cooldown
				fsm.queue_transition(EnemyState.StateType.CHASE)

func exit() -> void:
	super()
	enemy.hitbox.active = false
