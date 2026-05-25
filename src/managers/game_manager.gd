extends Node
## GameManager - Singleton principal del juego
## Gestiona:
## - Estado global del jugador
## - Transiciones entre escenas
## - Persistencia de datos
## - Comunicación entre sistemas

class_name GameManager

# Señales para eventos globales
signal player_entered_battle
signal battle_finished(victory: bool, exp: int, loot: Dictionary)
signal scene_transition_started
signal scene_transition_finished

# Estado del jugador (persistente)
var player_data: Dictionary = {
	"hp": 100,
	"max_hp": 100,
	"exp": 0,
	"level": 1,
	"gold": 0,
	"position": Vector2(100, 100),
	"scene": "res://src/scenes/world_map/world_map.tscn"
}

# Estado de la batalla actual
var current_encounter: Dictionary = {
	"enemies": [],
	"difficulty": 1,
	"rewards_exp": 0,
	"rewards_gold": 0
}

# Referencias a escenas activas
var current_scene: Node = null
var world_map: Node = null
var battle_scene: Node = null

# Control de transición
var is_transitioning: bool = false

func _ready() -> void:
	# AutoLoad - singleton que persiste entre escenas
	name = "GameManager"
	print("[GameManager] Inicializado correctamente")

## Inicia un encuentro de batalla
func start_encounter(enemy_list: Array, difficulty: int = 1) -> void:
	if is_transitioning:
		return
	
	is_transitioning = true
	scene_transition_started.emit()
	
	current_encounter = {
		"enemies": enemy_list,
		"difficulty": difficulty,
		"rewards_exp": 50 * difficulty,
		"rewards_gold": 25 * difficulty
	}
	
	# Guardar estado del mundo
	if world_map:
		player_data["position"] = world_map.player.global_position
	
	# Transición SNES-style (fade out)
	await _fade_out()
	
	# Cargar escena de batalla
	await SceneLoader.load_scene(
		"res://src/scenes/battle/battle_scene.tscn",
		SceneLoader.TransitionType.FADE
	)
	
	scene_transition_finished.emit()
	is_transitioning = false
	player_entered_battle.emit()

## Finaliza la batalla
func end_encounter(victory: bool, exp_gained: int, loot: Dictionary) -> void:
	if is_transitioning:
		return
	
	is_transitioning = true
	scene_transition_started.emit()
	
	# Actualizar datos del jugador
	if victory:
		player_data["exp"] += exp_gained
		player_data["gold"] += loot.get("gold", 0)
		
		# Verificar subida de nivel
		_check_level_up()
		
		print("[GameManager] Victoria! +%d EXP, +%d Gold" % [exp_gained, loot.get("gold", 0)])
	
	# Fade out de batalla
	await _fade_out()
	
	# Volver a WorldMap
	await SceneLoader.load_scene(
		"res://src/scenes/world_map/world_map.tscn",
		SceneLoader.TransitionType.FADE
	)
	
	# Restaurar posición del jugador
	if world_map and world_map.has_node("Player"):
		world_map.player.global_position = player_data["position"]
	
	scene_transition_finished.emit()
	is_transitioning = false
	battle_finished.emit(victory, exp_gained, loot)

## Transición con fade out estilo SNES
func _fade_out() -> void:
	# Esta función se extenderá con un CanvasLayer y AnimationPlayer
	# Por ahora es un placeholder
	await get_tree().create_timer(0.5).timeout

## Transición con fade in estilo SNES
func _fade_in() -> void:
	# Placeholder
	await get_tree().create_timer(0.5).timeout

## Verifica si el jugador sube de nivel
func _check_level_up() -> void:
	var exp_for_level = player_data["level"] * 100
	if player_data["exp"] >= exp_for_level:
		player_data["level"] += 1
		player_data["max_hp"] += 10
		player_data["hp"] = player_data["max_hp"]
		print("[GameManager] ¡LEVEL UP! Nivel %d" % player_data["level"])

## Guarda los datos del jugador a archivo (para persistencia)
func save_game() -> void:
	var save_data = {
		"player": player_data,
		"timestamp": Time.get_ticks_msec()
	}
	# TODO: Implementar guardado a archivo
	print("[GameManager] Juego guardado: ", save_data)

## Carga los datos del jugador desde archivo
func load_game() -> bool:
	# TODO: Implementar carga desde archivo
	print("[GameManager] Cargando datos del jugador...")
	return true

## Obtiene los datos actuales del jugador
func get_player_data() -> Dictionary:
	return player_data.duplicate()

## Restaura HP del jugador después de batalla
func restore_player_hp() -> void:
	player_data["hp"] = player_data["max_hp"]
