extends Node2D
## WorldMapController - Controlador de la escena de exploración
## Maneja:
## - Instanciación del jugador
## - Cámara de seguimiento
## - Música ambiental
## - Gestión de enemigos

class_name WorldMapController

# Componentes
@onready var camera_2d = $Camera2D
@onready var tilemap = $TileMap
@onready var music_player = $AudioStreamPlayer

# Referencias
var player: PlayerController = null

# Configuración
@export var music_path: String = ""
@export var player_start_position: Vector2 = Vector2(100, 100)
@export var camera_zoom: float = 2.0

func _ready() -> void:
	name = "WorldMap"
	_setup_player()
	_setup_camera()
	_setup_music()
	_spawn_enemies()
	
	# Restaurar datos del jugador si vuelve de una batalla
	if GameManager.world_map == self:
		_restore_player_state()
	
	GameManager.world_map = self
	print("[WorldMap] Escena lista para exploración")

## Crea e instancia al jugador
func _setup_player() -> void:
	var player_scene = load("res://src/scenes/world_map/player.tscn")
	if not player_scene:
		push_error("[WorldMap] No se encontró player.tscn")
		return
	
	player = player_scene.instantiate()
	player.global_position = player_start_position
	add_child(player)
	player.add_to_group("player")
	print("[WorldMap] Jugador instanciado en ", player.global_position)

## Configura la cámara para seguir al jugador
func _setup_camera() -> void:
	if not camera_2d:
		camera_2d = Camera2D.new()
		add_child(camera_2d)
	
	camera_2d.enabled = true
	camera_2d.zoom = Vector2(camera_zoom, camera_zoom)
	camera_2d.follow_smoothing_enabled = true
	camera_2d.set_physics_process(true)

func _process(delta: float) -> void:
	# Seguir al jugador
	if player and camera_2d:
		camera_2d.global_position = player.global_position

## Configura la música ambiental
func _setup_music() -> void:
	if not music_player:
		music_player = AudioStreamPlayer.new()
		add_child(music_player)
	
	if music_path and ResourceLoader.exists(music_path):
		music_player.stream = load(music_path)
		music_player.bus = "Music"
		music_player.play()
	else:
		print("[WorldMap] Música no encontrada: ", music_path)

## Spawnea enemigos en la escena
func _spawn_enemies() -> void:
	# Crear algunos enemigos de prueba
	var enemy_scene = load("res://src/scenes/world_map/enemy.tscn")
	if not enemy_scene:
		print("[WorldMap] No se encontró enemy.tscn")
		return
	
	# Posiciones de spawn
	var spawn_positions = [
		Vector2(300, 150),
		Vector2(500, 250),
		Vector2(200, 400),
		Vector2(600, 100)
	]
	
	for spawn_pos in spawn_positions:
		var enemy = enemy_scene.instantiate()
		enemy.global_position = spawn_pos
		enemy.level = randi() % 3 + 1  # Niveles del 1 al 3
		add_child(enemy)

## Restaura el estado del jugador al volver de batalla
func _restore_player_state() -> void:
	if not player:
		return
	
	var player_data = GameManager.get_player_data()
	player.player_data = player_data
	player.global_position = player_data["position"]
	player.restore_hp()
	print("[WorldMap] Estado del jugador restaurado")

## Pausa/despausa el mundo (usado en transiciones)
func pause() -> void:
	get_tree().paused = true

func resume() -> void:
	get_tree().paused = false
