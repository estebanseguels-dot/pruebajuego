extends Node

signal player_entered_battle
signal battle_finished(victory: bool, exp: int, loot: Dictionary)
signal scene_transition_started
signal scene_transition_finished
signal player_stats_changed
signal inventory_changed
signal gold_changed

var player_data: Dictionary = {
	"hp": 100,
	"max_hp": 100,
	"mp": 50,
	"max_mp": 50,
	"exp": 0,
	"level": 1,
	"gold": 0,
	"attack": 15,
	"defense": 10,
	"position": Vector2(100, 100)
}

var current_encounter: Dictionary = {
	"enemies": [],
	"difficulty": 1,
	"rewards_exp": 0,
	"rewards_gold": 0
}

var world_map_scene: Node = null
var battle_scene: Node = null

var is_in_battle: bool = false
var is_transitioning: bool = false

var inventory: Dictionary = {}
var equipment: Dictionary = {
	"weapon": null,
	"armor": null,
	"accessory": null
}

func _ready() -> void:
	name = "GameManager"

func start_encounter(enemy_list: Array, difficulty: int = 1) -> void:
	if is_transitioning:
		return

	is_transitioning = true
	is_in_battle = true
	scene_transition_started.emit()

	current_encounter = {
		"enemies": enemy_list,
		"difficulty": difficulty,
		"rewards_exp": 50 * difficulty,
		"rewards_gold": 25 * difficulty
	}

	if world_map_scene:
		world_map_scene.process_mode = PROCESS_MODE_DISABLED
		player_data["position"] = world_map_scene.player.global_position

	var battle = await SceneLoader.load_scene(
		"res://src/scenes/battle/battle_scene.tscn",
		SceneLoader.TransitionType.FADE
	)
	battle_scene = battle

	scene_transition_finished.emit()
	is_transitioning = false
	player_entered_battle.emit()

func end_encounter(victory: bool, exp_gained: int, loot: Dictionary) -> void:
	if is_transitioning:
		return

	is_transitioning = true
	scene_transition_started.emit()

	if victory:
		add_exp(exp_gained)
		player_data["gold"] += loot.get("gold", 0)
		for item in loot.get("items", []):
			add_item(item)

	if battle_scene:
		battle_scene.queue_free()
		battle_scene = null

	var world = await SceneLoader.load_scene(
		"res://src/scenes/world_map/world_map.tscn",
		SceneLoader.TransitionType.FADE
	)
	world_map_scene = world

	if world_map_scene and world_map_scene.has_node("Player"):
		world_map_scene.player.global_position = player_data["position"]

	scene_transition_finished.emit()
	is_transitioning = false
	is_in_battle = false
	battle_finished.emit(victory, exp_gained, loot)

func _on_scene_loaded(scene: Node, path: String) -> void:
	if "world_map" in path:
		world_map_scene = scene
	elif "battle" in path:
		battle_scene = scene

func add_exp(amount: int) -> void:
	player_data["exp"] += amount
	var needed = player_data["level"] * 100
	while player_data["exp"] >= needed:
		player_data["exp"] -= needed
		level_up()
		needed = player_data["level"] * 100

func level_up() -> void:
	player_data["level"] += 1
	player_data["max_hp"] += 10
	player_data["max_mp"] += 5
	player_data["hp"] = player_data["max_hp"]
	player_data["mp"] = player_data["max_mp"]
	player_data["attack"] += 3
	player_data["defense"] += 2
	player_stats_changed.emit()

func heal_player() -> void:
	player_data["hp"] = player_data["max_hp"]
	player_data["mp"] = player_data["max_mp"]
	player_stats_changed.emit()

func damage_player(amount: int) -> bool:
	var actual = max(1, amount - player_data["defense"])
	player_data["hp"] = max(0, player_data["hp"] - actual)
	player_stats_changed.emit()
	return player_data["hp"] <= 0

func add_gold(amount: int) -> void:
	player_data["gold"] += amount
	gold_changed.emit()

func remove_gold(amount: int) -> bool:
	if player_data["gold"] >= amount:
		player_data["gold"] -= amount
		gold_changed.emit()
		return true
	return false

func add_item(item_name: String, amount: int = 1) -> void:
	if inventory.has(item_name):
		inventory[item_name] += amount
	else:
		inventory[item_name] = amount
	inventory_changed.emit()

func remove_item(item_name: String, amount: int = 1) -> bool:
	if inventory.has(item_name) and inventory[item_name] >= amount:
		inventory[item_name] -= amount
		if inventory[item_name] <= 0:
			inventory.erase(item_name)
		inventory_changed.emit()
		return true
	return false

func has_item(item_name: String) -> bool:
	return inventory.has(item_name) and inventory[item_name] > 0

func get_player_data() -> Dictionary:
	return player_data.duplicate()

func restore_player_hp() -> void:
	player_data["hp"] = player_data["max_hp"]

func reset_game() -> void:
	player_data = {
		"hp": 100,
		"max_hp": 100,
		"mp": 50,
		"max_mp": 50,
		"exp": 0,
		"level": 1,
		"gold": 0,
		"attack": 15,
		"defense": 10,
		"position": Vector2(100, 100),
		"gender": "male",
		"pet": "dog",
		"hair_style": "Despeinado",
		"hair_color": [0.95, 0.85, 0.4],
		"skin_color": [0.95, 0.8, 0.65]
	}
	inventory.clear()
	equipment = {"weapon": null, "armor": null, "accessory": null}
	is_in_battle = false
	is_transitioning = false
