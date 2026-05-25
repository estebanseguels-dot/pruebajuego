extends CharacterBody2D
## PlayerController - Controlador del jugador
## Maneja:
## - Movimiento en 8 direcciones
## - Animaciones
## - Colisiones
## - Interacción con enemigos

class_name PlayerController

# Propiedades de movimiento
@export var speed: float = 100.0
@export var acceleration: float = 500.0
@export var friction: float = 300.0

# Componentes
@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D
@onready var interaction_area = $InteractionArea

# Estado
var is_moving: bool = false
var current_direction: Vector2 = Vector2.ZERO
var facing_direction: Vector2 = Vector2.DOWN

# Referencia a datos del jugador
var player_data: Dictionary = {}

func _ready() -> void:
	name = "Player"
	player_data = GameManager.get_player_data()
	
	# Conexión de señales
	if interaction_area.has_signal("area_entered"):
		interaction_area.area_entered.connect(_on_interaction_area_entered)

## Procesa input del jugador
func _process(delta: float) -> void:
	if GameManager.is_transitioning:
		velocity = Vector2.ZERO
		return
	
	# Obtener input en 8 direcciones
	var input_direction = Vector2.ZERO
	input_direction.x = Input.get_axis("ui_left", "ui_right")
	input_direction.y = Input.get_axis("ui_up", "ui_down")
	
	# Normalizar para evitar movimiento diagonal más rápido
	if input_direction != Vector2.ZERO:
		input_direction = input_direction.normalized()
		current_direction = input_direction
		facing_direction = input_direction
		is_moving = true
	else:
		is_moving = false
	
	# Aplicar movimiento
	_apply_movement(input_direction, delta)
	
	# Actualizar animaciones
	_update_animations()

## Aplica la física del movimiento
func _apply_movement(input_direction: Vector2, delta: float) -> void:
	if input_direction != Vector2.ZERO:
		velocity = velocity.move_toward(input_direction * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	move_and_slide()

## Actualiza las animaciones según dirección y estado
func _update_animations() -> void:
	if not animated_sprite:
		return
	
	# Obtener ángulo de dirección
	var angle = facing_direction.angle()
	var animation_name = "idle_down"
	
	if is_moving:
		# Determinar animación según dirección
		if abs(facing_direction.x) > abs(facing_direction.y):
			# Movimiento horizontal
			animation_name = "walk_right" if facing_direction.x > 0 else "walk_left"
		else:
			# Movimiento vertical
			animation_name = "walk_down" if facing_direction.y > 0 else "walk_up"
	else:
		# Animaciones idle según dirección
		if abs(facing_direction.x) > abs(facing_direction.y):
			animation_name = "idle_right" if facing_direction.x > 0 else "idle_left"
		else:
			animation_name = "idle_down" if facing_direction.y > 0 else "idle_up"
	
	if animated_sprite.animation != animation_name:
		animated_sprite.animation = animation_name
		animated_sprite.play()

## Detecta colisión con enemigos
func _on_interaction_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		print("[Player] ¡Colisión con enemigo!")
		area.trigger_encounter()

## Restaura HP después de batalla
func restore_hp() -> void:
	player_data["hp"] = player_data["max_hp"]

## Obtiene datos actuales del jugador
func get_player_data() -> Dictionary:
	return player_data.duplicate()
