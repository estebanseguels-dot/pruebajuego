extends RefCounted
## BattleCharacter - Representa un personaje en combate
## Maneja:
## - Stats de combate
## - Cálculo de daño
## - Estado de salud
## - Acciones de batalla

class_name BattleCharacter

# Stats básicos
var character_type: String = ""
var level: int = 1
var health: int = 100
var max_health: int = 100
var attack: int = 10
var defense: int = 5
var speed: int = 15
var exp_value: int = 0

# Estado
var is_player: bool = false
var defense_multiplier: float = 1.0
var current_status: String = "normal"  # normal, poisoned, confused, etc.

func _init() -> void:
	pass

## Inicializa un personaje de batalla
func initialize(data: Dictionary, is_player_char: bool = false) -> void:
	character_type = data.get("type", "Unknown")
	level = data.get("level", 1)
	health = data.get("health", 100)
	max_health = data.get("max_health", 100)
	attack = data.get("attack", 10)
	defense = data.get("defense", 5)
	speed = data.get("speed", 15)
	exp_value = data.get("exp_value", 0)
	is_player = is_player_char

## Calcula el daño infligido a otro personaje
func calculate_damage(target: BattleCharacter) -> int:
	# Fórmula básica de daño: (Ataque - Defensa del objetivo) + variación
	var base_damage = attack - (target.defense * target.defense_multiplier)
	var variation = randi() % (base_damage / 4) - (base_damage / 8)  # Variación ±12.5%
	var total_damage = max(1, base_damage + variation)  # Mínimo 1 de daño
	
	return total_damage

## Recibe daño
func take_damage(damage: int) -> void:
	health = max(0, health - damage)
	print("[BattleChar] %s recibe %d daño. HP: %d/%d" % [
		character_type,
		damage,
		health,
		max_health
	])

## Restaura salud
func restore_health(amount: int) -> void:
	health = min(max_health, health + amount)

## Verifica si está derrotado
func is_defeated() -> bool:
	return health <= 0

## Verifica si está vivo
func is_alive() -> bool:
	return health > 0

## Obtiene el porcentaje de salud
func get_health_percentage() -> float:
	return float(health) / float(max_health)

## Obtiene los datos del personaje
func get_data() -> Dictionary:
	return {
		"type": character_type,
		"level": level,
		"health": health,
		"max_health": max_health,
		"attack": attack,
		"defense": defense,
		"speed": speed,
		"status": current_status
	}

## Aplica un estado
func apply_status(status: String) -> void:
	current_status = status
	print("[BattleChar] %s ahora tiene estado: %s" % [character_type, status])

## Limpia estados
func clear_status() -> void:
	current_status = "normal"
