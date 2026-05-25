extends Node2D
## BattleController - Controlador principal de la escena de batalla
## Maneja:
## - Inicialización de encuentro
## - Turnos de combate
## - Cámara de batalla
## - Música de batalla
## - UI de batalla

class_name BattleController

# Componentes
@onready var camera_2d = $Camera2D
@onready var background = $BattleBackground
@onready var music_player = $AudioStreamPlayer
@onready var battle_ui = $BattleUI

# Estado de batalla
var player_character: BattleCharacter = null
var enemy_characters: Array[BattleCharacter] = []
var current_turn: int = 0
var battle_active: bool = true
var turn_order: Array = []  # Orden de turnos según velocidad

# Referencias
var player_data: Dictionary = {}
var enemy_data: Array = []

func _ready() -> void:
	name = "Battle"
	player_data = GameManager.get_player_data()
	enemy_data = GameManager.current_encounter["enemies"]
	
	_setup_background()
	_setup_camera()
	_setup_music()
	_initialize_encounter()
	_setup_ui()
	
	print("[Battle] Sistema de combate inicializado")

## Configura el fondo de batalla
func _setup_background() -> void:
	if not background:
		background = ColorRect.new()
		add_child(background)
	
	# Color de fondo de prueba (reemplazar con sprite)
	background.color = Color.DARK_SLATE_GRAY
	background.anchor_right = 1.0
	background.anchor_bottom = 1.0

## Configura la cámara de batalla
func _setup_camera() -> void:
	if not camera_2d:
		camera_2d = Camera2D.new()
		add_child(camera_2d)
	
	camera_2d.enabled = true
	camera_2d.zoom = Vector2(1.5, 1.5)
	camera_2d.global_position = Vector2(160, 90)  # Centro de pantalla

## Configura la música de batalla
func _setup_music() -> void:
	if not music_player:
		music_player = AudioStreamPlayer.new()
		add_child(music_player)
	
	# Usar música de batalla predeterminada (reemplazar con ruta real)
	var music_path = "res://assets/music/battle_theme.ogg"
	if ResourceLoader.exists(music_path):
		music_player.stream = load(music_path)
		music_player.bus = "Music"
		music_player.play()

## Inicializa el encuentro con jugador y enemigos
func _initialize_encounter() -> void:
	# Crear jugador de batalla
	var player_battle_data = {
		"type": "Player",
		"level": player_data["level"],
		"health": player_data["hp"],
		"max_health": player_data["max_hp"],
		"attack": 10 + player_data["level"] * 2,
		"defense": 5 + player_data["level"],
		"speed": 15,
		"exp_value": 0
	}
	
	player_character = BattleCharacter.new()
	player_character.initialize(player_battle_data, true)  # true = es el jugador
	
	# Crear enemigos de batalla
	for enemy_info in enemy_data:
		var enemy_character = BattleCharacter.new()
		enemy_character.initialize(enemy_info, false)
		enemy_characters.append(enemy_character)
	
	# Calcular orden de turnos (basado en velocidad)
	_calculate_turn_order()
	
	# Notificar a UI
	if battle_ui:
		battle_ui.initialize(player_character, enemy_characters)
	
	print("[Battle] Encuentro inicializado: %s vs %d enemigos" % [
		player_character.character_type,
		enemy_characters.size()
	])

## Calcula el orden de turnos basado en velocidad
func _calculate_turn_order() -> void:
	turn_order.clear()
	
	# Añadir jugador
	turn_order.append({
		"character": player_character,
		"is_player": true,
		"speed": player_character.speed
	})
	
	# Añadir enemigos
	for enemy in enemy_characters:
		turn_order.append({
			"character": enemy,
			"is_player": false,
			"speed": enemy.speed
		})
	
	# Ordenar por velocidad (mayor primero)
	turn_order.sort_custom(func(a, b): return a["speed"] > b["speed"])

## Configura la UI de batalla
func _setup_ui() -> void:
	if not battle_ui:
		# Crear UI si no existe
		battle_ui = Control.new()
		add_child(battle_ui)

## Inicia el turno
func _process(delta: float) -> void:
	if not battle_active:
		return
	
	# TODO: Implementar sistema de turnos
	# Esto será llamado desde la UI cuando el jugador selecciona acción

## Ejecuta el turno del jugador
func execute_player_action(action: String, target_index: int = 0) -> void:
	if not battle_active:
		return
	
	print("[Battle] Acción: %s en enemigo %d" % [action, target_index])
	
	match action:
		"attack":
			_execute_player_attack(target_index)
		"defend":
			_execute_player_defend()
		"item":
			_execute_player_item()
		"escape":
			_attempt_escape()

## Ejecuta ataque del jugador
func _execute_player_attack(target_index: int) -> void:
	var target = enemy_characters[target_index]
	var damage = player_character.calculate_damage(target)
	
	target.take_damage(damage)
	
	print("[Battle] ¡Golpe! Daño: %d" % damage)
	
	# Animar daño en UI
	if battle_ui:
		battle_ui.show_damage(damage, target_index)
	
	# Verificar si enemigo fue derrotado
	if target.is_defeated():
		enemy_characters.remove_at(target_index)
		print("[Battle] ¡Enemigo derrotado!")
	
	# Verificar si batalla terminó
	if _check_battle_end():
		return
	
	# Turno de enemigos
	await get_tree().create_timer(0.5).timeout
	_execute_enemy_turns()

## Enemigos atacan
func _execute_enemy_turns() -> void:
	for enemy in enemy_characters:
		if enemy.is_defeated():
			continue
		
		var damage = enemy.calculate_damage(player_character)
		player_character.take_damage(damage)
		
		print("[Battle] Enemigo ataca: %d daño" % damage)
		
		if battle_ui:
			battle_ui.show_player_damage(damage)
		
		await get_tree().create_timer(0.3).timeout
	
	if _check_battle_end():
		return
	
	# Siguiente turno del jugador
	if battle_ui:
		battle_ui.enable_player_actions()

## Ejecuta defensa del jugador
func _execute_player_defend() -> void:
	player_character.defense_multiplier = 1.5
	print("[Battle] ¡Defensa activada!")
	await get_tree().create_timer(1.0).timeout
	player_character.defense_multiplier = 1.0

## Ejecuta uso de objeto
func _execute_player_item() -> void:
	# TODO: Implementar sistema de objetos
	print("[Battle] Usar objeto")

## Intenta escapar de batalla
func _attempt_escape() -> void:
	if randf() < 0.5:  # 50% de probabilidad
		print("[Battle] ¡Escapar exitoso!")
		_end_battle(false)
	else:
		print("[Battle] ¡No se pudo escapar!")

## Verifica si la batalla ha terminado
func _check_battle_end() -> bool:
	# Victoria
	if enemy_characters.is_empty():
		_end_battle(true)
		return true
	
	# Derrota
	if player_character.is_defeated():
		_end_battle(false)
		return true
	
	return false

## Finaliza la batalla
func _end_battle(victory: bool) -> void:
	battle_active = false
	
	var exp_gained = 0
	var loot = {"gold": 0}
	
	if victory:
		# Calcular recompensas
		for enemy in enemy_characters:
			exp_gained += enemy.exp_value
			loot["gold"] += enemy.level * 10
		
		print("[Battle] ¡VICTORIA! +%d EXP, +%d Gold" % [exp_gained, loot["gold"]])
	else:
		print("[Battle] ¡DERROTA!")
	
	# Transferir recompensas a GameManager
	GameManager.end_encounter(victory, exp_gained, loot)
