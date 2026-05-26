extends "res://src/systems/ai/enemy_state.gd"
class_name ChaseState

var _player_ref: Node2D = null
var _attack_cooldown: float = 0.0

func _init() -> void:
	state_type = StateType.CHASE

func enter() -> void:
	super()
	_attack_cooldown = enemy._attack_cooldown_timer
	_player_ref = enemy._player_ref

func update(delta: float) -> void:
	_attack_cooldown -= delta
	if not _player_ref or not is_instance_valid(_player_ref):
		_player_ref = _find_player()
		if not _player_ref:
			fsm.queue_transition(EnemyState.StateType.PATROL)
			return

	var dir = (_player_ref.global_position - enemy.global_position).normalized()
	var dist = enemy.global_position.distance_to(_player_ref.global_position)

	if dist < enemy.attack_range and _attack_cooldown <= 0.0:
		fsm.queue_transition(EnemyState.StateType.ATTACK)
		return

	if dist > enemy.leash_range:
		_player_ref = null
		fsm.queue_transition(EnemyState.StateType.PATROL)
		return

	enemy.velocity = dir * enemy.chase_speed
	enemy.update_facing(dir)
	enemy.move_and_slide()

	if enemy.health and enemy.health.get_percentage() < 0.3:
		fsm.queue_transition(EnemyState.StateType.RETREAT)

func _find_player() -> Node2D:
	var wm = GameManager.world_map_scene
	if wm and is_instance_valid(wm):
		var p = wm.get_node("Player") if wm.has_node("Player") else null
		if p and is_instance_valid(p):
			return p
	return null
