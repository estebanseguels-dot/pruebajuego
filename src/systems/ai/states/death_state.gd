extends "res://src/systems/ai/enemy_state.gd"
class_name DeathState

var _elapsed: float = 0.0
var _duration: float = 0.4

func _init() -> void:
	state_type = StateType.DEATH

func enter() -> void:
	super()
	enemy.hitbox.active = false
	enemy.velocity = Vector2.ZERO
	enemy.set_physics_process(false)
	GameManager.add_exp(enemy.exp_value * enemy.level)
	GameManager.add_gold(enemy.level * 10)

func update(delta: float) -> void:
	_elapsed += delta
	var t = _elapsed / _duration
	enemy.modulate = Color(1, 1, 1, 1.0 - t)
	if t >= 1.0:
		enemy.queue_free()
