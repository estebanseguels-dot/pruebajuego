extends Node
class_name HealthComponent

signal hp_changed(current: int, max_hp: int)
signal damaged(amount: int, knockback_dir: Vector2)
signal healed(amount: int)
signal died

@export var max_health: int = 100
@export var invulnerability_time: float = 0.5

var current_health: int : set = _set_health
var is_invulnerable: bool = false
var is_dead: bool = false

func _ready() -> void:
	current_health = max_health

func _set_health(value: int) -> void:
	current_health = clampi(value, 0, max_health)
	hp_changed.emit(current_health, max_health)

func take_damage(amount: int, knockback_dir: Vector2 = Vector2.ZERO) -> bool:
	if is_dead or is_invulnerable:
		return false

	current_health -= amount
	damaged.emit(amount, knockback_dir)

	if current_health <= 0:
		is_dead = true
		died.emit()
		return true

	_start_invulnerability()
	return false

func _start_invulnerability() -> void:
	is_invulnerable = true
	await get_tree().create_timer(invulnerability_time).timeout
	is_invulnerable = false

func heal(amount: int) -> void:
	if is_dead:
		return
	var before = current_health
	current_health = min(max_health, current_health + amount)
	var actual = current_health - before
	if actual > 0:
		healed.emit(actual)

func reset() -> void:
	is_dead = false
	is_invulnerable = false
	current_health = max_health

func get_percentage() -> float:
	return float(current_health) / float(max_health)
