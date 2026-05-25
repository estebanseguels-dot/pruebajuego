extends CharacterBody2D
## EnemyController - Controlador de enemigos en worldmap
## Maneja:
## - Patrulla/roaming
## - Detección del jugador
## - Disparo de encuentro
## - Animaciones

class_name EnemyController

# Propiedades
@export var enemy_type: String = "Slime"
@export var health: int = 20
@export var level: int = 1
@export var speed: float = 60.0
@export var patrol_range: float = 100.0
@export var alert_distance: float = 150.0

# Componentes
@onready var animated_sprite = $AnimatedSprite2D
@onready var detection_area = $DetectionArea

# Patrulla
var patrol_start: Vector2 = Vector2.ZERO
var patrol_end: Vector2 = Vector2.ZERO
var current_target: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO

# Estado
var is_alerted: bool = false
var player_detected: bool = false

func _ready() -> void:
	add_to_group("enemy")
	patrol_start = global_position
	patrol_end = patrol_start + Vector2(patrol_range, 0)
	current_target = patrol_end
	
	# Conexiones
	if detection_area.has_signal("area_entered"):
		detection_area.area_entered.connect(_on_detection_area_entered)
	if detection_area.has_signal("area_exited"):
		detection_area.area_exited.connect(_on_detection_area_exited)
	
	print("[Enemy] %s nivel %d creado" % [enemy_type, level])

func _process(delta: float) -> void:
	if GameManager.is_transitioning:
		velocity = Vector2.ZERO
		return
	
	if player_detected and not is_alerted:
		_alert()
	
	if is_alerted:
		_chase_player()
	else:
		_patrol(delta)

## Patrulla entre dos puntos
func _patrol(delta: float) -> void:
	var direction = (current_target - global_position).normalized()
	velocity = direction * speed
	
	# Cambiar dirección de patrulla
	if global_position.distance_to(current_target) < 10:
		current_target = patrol_end if current_target == patrol_start else patrol_start
	
	move_and_slide()
	_update_animation("walk")

## Persigue al jugador
func _chase_player() -> void:
	var player = GameManager.world_map.player
	if not player:
		is_alerted = false
		return
	
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed * 1.5  # Persecución es más rápida
	
	move_and_slide()
	_update_animation("alert")

## Se alerta al detectar al jugador
func _alert() -> void:
	is_alerted = true
	print("[Enemy] %s ¡Alerta! Persiguiendo..." % enemy_type)

## Detecta al jugador entrando al área
func _on_detection_area_entered(area: Area2D) -> void:
	if area.name == "Player" or area.get_parent().is_in_group("player"):
		player_detected = true

## El jugador sale del área de detección
func _on_detection_area_exited(area: Area2D) -> void:
	if area.name == "Player" or area.get_parent().is_in_group("player"):
		player_detected = false
		is_alerted = false
		print("[Enemy] %s Alerta cancelada" % enemy_type)

## Dispara el encuentro de batalla
func trigger_encounter() -> void:
	if GameManager.is_transitioning:
		return
	
	print("[Enemy] ¡Encuentro iniciado con %s!" % enemy_type)
	
	# Crear lista de enemigos para el encuentro
	var enemy_data = {
		"type": enemy_type,
		"level": level,
		"health": health,
		"max_health": health,
		"is_boss": false
	}
	
	GameManager.start_encounter([enemy_data], level)

## Actualiza la animación del enemigo
func _update_animation(state: String) -> void:
	if not animated_sprite:
		return
	
	match state:
		"walk":
			if animated_sprite.animation != "walk":
				animated_sprite.animation = "walk"
				animated_sprite.play()
		"alert":
			if animated_sprite.animation != "alert":
				animated_sprite.animation = "alert"
				animated_sprite.play()

## Obtiene los datos del enemigo para la batalla
func get_enemy_data() -> Dictionary:
	return {
		"type": enemy_type,
		"level": level,
		"health": health,
		"max_health": health,
		"attack": 5 + level * 2,
		"defense": 2 + level,
		"exp_reward": 50 * level,
		"gold_reward": 25 * level
	}
