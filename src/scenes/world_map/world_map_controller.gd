extends Node2D
class_name WorldMapController

@onready var camera_2d = $Camera2D
@onready var music_player = $AudioStreamPlayer

var player = null
var combat_hud = null

@export var player_spawn: Vector2 = Vector2(100, 100)

var enemy_definitions: Dictionary = {
	"slime": {
		"max_health": 30,
		"move_speed": 50,
		"chase_speed": 70,
		"attack_damage": 6,
		"attack_range": 25,
		"attack_startup": 0.25,
		"attack_active": 0.12,
		"attack_recovery": 0.3,
		"attack_cooldown": 1.8,
		"exp_value": 25,
		"gold_value": 3
	},
	"wolf": {
		"max_health": 50,
		"move_speed": 70,
		"chase_speed": 120,
		"attack_damage": 10,
		"attack_range": 28,
		"attack_startup": 0.15,
		"attack_active": 0.1,
		"attack_recovery": 0.25,
		"attack_cooldown": 1.2,
		"exp_value": 45,
		"gold_value": 8
	},
	"goblin": {
		"max_health": 40,
		"move_speed": 60,
		"chase_speed": 90,
		"attack_damage": 8,
		"attack_range": 30,
		"attack_startup": 0.2,
		"attack_active": 0.12,
		"attack_recovery": 0.35,
		"attack_cooldown": 1.5,
		"exp_value": 35,
		"gold_value": 6
	}
}

func _ready() -> void:
	name = "WorldMap"
	_spawn_player()
	_setup_camera()
	_spawn_enemies()
	_setup_combat_hud()

	if music_player and music_player.stream:
		music_player.play()

	GameManager._on_scene_loaded(self, "world_map")

func _spawn_player() -> void:
	var scene = load("res://src/scenes/world_map/player.tscn")
	player = scene.instantiate()
	player.global_position = player_spawn
	add_child(player)
	player.add_to_group("player")

func _setup_camera() -> void:
	camera_2d.enabled = true
	camera_2d.position_smoothing_enabled = true

func _process(_delta: float) -> void:
	if player and camera_2d:
		camera_2d.global_position = player.global_position
		_update_target_reticle()

func _update_target_reticle() -> void:
	if not combat_hud:
		return
	var nearest = _find_nearest_enemy()
	combat_hud.set_target(nearest)

func _find_nearest_enemy() -> Node2D:
	var best: Node2D = null
	var best_dist: float = INF
	var max_range = 120.0

	for e in get_tree().get_nodes_in_group("enemy"):
		if not is_instance_valid(e):
			continue
		var h = e.get_node("HealthComponent")
		if h and h.is_dead:
			continue
		var dist = player.global_position.distance_to(e.global_position)
		if dist < best_dist and dist < max_range:
			if player:
				var dir_to = (e.global_position - player.global_position).normalized()
				if dir_to.dot(player.facing_direction) > 0.3:
					best = e
					best_dist = dist
	return best

func _setup_combat_hud() -> void:
	var scene = load("res://src/ui/combat/combat_hud.tscn")
	if not scene:
		return
	combat_hud = scene.instantiate()
	add_child(combat_hud)

	var health = player.get_node("HealthComponent")
	var stamina = player.get_node("StaminaComponent")
	if health and stamina:
		combat_hud.setup(health, stamina)

func _spawn_enemies() -> void:
	var scene = load("res://src/scenes/world_map/enemy.tscn")
	if not scene:
		return

	var spawn_configs = [
		{"pos": Vector2(300, 150), "type": "slime", "level": 1},
		{"pos": Vector2(500, 250), "type": "wolf", "level": 2},
		{"pos": Vector2(200, 400), "type": "goblin", "level": 1},
		{"pos": Vector2(600, 100), "type": "slime", "level": 2},
	]
	for cfg in spawn_configs:
		var e = scene.instantiate()
		e.global_position = cfg["pos"]
		_apply_definition(e, cfg["type"], cfg["level"])
		add_child(e)

func _apply_definition(enemy, type: String, level: int) -> void:
	var def = enemy_definitions.get(type, enemy_definitions["slime"])
	enemy.enemy_type = type.capitalize()
	enemy.level = level
	enemy.move_speed = def["move_speed"]
	enemy.chase_speed = def["chase_speed"]
	enemy.attack_damage = def["attack_damage"] + level * 2
	enemy.attack_range = def["attack_range"]
	enemy.attack_startup = def["attack_startup"]
	enemy.attack_active = def["attack_active"]
	enemy.attack_recovery = def["attack_recovery"]
	enemy.attack_cooldown = def["attack_cooldown"]
	enemy.exp_value = def["exp_value"] * level
	var health = enemy.get_node("HealthComponent")
	if health:
		health.max_health = def["max_health"] + level * 10
		health.current_health = health.max_health
