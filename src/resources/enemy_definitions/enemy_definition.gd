extends Resource
class_name EnemyDefinition

@export var enemy_name: String = "Slime"
@export var description: String = ""
@export var level: int = 1
@export var max_health: int = 30
@export var move_speed: float = 50.0
@export var chase_speed: float = 80.0
@export var attack_damage: int = 6
@export var attack_range: float = 25.0
@export var attack_startup: float = 0.2
@export var attack_active: float = 0.15
@export var attack_recovery: float = 0.35
@export var attack_cooldown: float = 1.5
@export var exp_value: int = 30
@export var gold_value: int = 5
@export var sprite_path: String = ""
@export var scene_path: String = ""

func apply_to(enemy) -> void:
	enemy.enemy_type = enemy_name
	enemy.level = level
	enemy.move_speed = move_speed
	enemy.chase_speed = chase_speed
	enemy.attack_damage = attack_damage
	enemy.attack_range = attack_range
	enemy.attack_startup = attack_startup
	enemy.attack_active = attack_active
	enemy.attack_recovery = attack_recovery
	enemy.attack_cooldown = attack_cooldown
	enemy.exp_value = exp_value
	if enemy.has_node("HealthComponent"):
		var h = enemy.get_node("HealthComponent")
		if h:
			h.max_health = max_health
			h.current_health = max_health
