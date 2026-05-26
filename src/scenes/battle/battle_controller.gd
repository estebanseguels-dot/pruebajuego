extends Node2D
class_name BattleController

@onready var camera_2d = $Camera2D
@onready var battle_ui = $BattleUI

var player_character = null
var enemy_characters = []
var battle_active: bool = true
var _total_exp: int = 0
var _total_gold: int = 0

func _ready() -> void:
	name = "Battle"
	camera_2d.enabled = true
	camera_2d.global_position = Vector2(160, 90)

	var pd = GameManager.player_data
	var pdata = {
		"type": "Player",
		"level": pd["level"],
		"health": pd["hp"],
		"max_health": pd["max_hp"],
		"attack": pd["attack"],
		"defense": pd["defense"],
		"speed": 15,
		"exp_value": 0
	}
	player_character = BattleCharacter.new()
	player_character.initialize(pdata, true)

	for ei in GameManager.current_encounter["enemies"]:
		var ec = BattleCharacter.new()
		ec.initialize(ei, false)
		_total_exp += ec.exp_value
		_total_gold += ec.level * 10
		enemy_characters.append(ec)

	if battle_ui:
		battle_ui.initialize(player_character, enemy_characters)

func execute_player_action(action: String, target_index: int = 0) -> void:
	if not battle_active:
		return
	match action:
		"attack":
			_attack(target_index)
		"defend":
			player_character.defense_multiplier = 1.5
			await get_tree().create_timer(1.0).timeout
			player_character.defense_multiplier = 1.0
			_enemy_turns()
		"escape":
			if randf() < 0.5:
				_end_battle(false)
			elif battle_ui:
				battle_ui.enable_player_actions()

func _attack(index: int) -> void:
	if index >= enemy_characters.size():
		return
	var dmg = player_character.calculate_damage(enemy_characters[index])
	enemy_characters[index].take_damage(dmg)
	if battle_ui:
		battle_ui.show_damage(dmg, index)
	enemy_characters = enemy_characters.filter(func(e): return e.is_alive())
	if not _check_end():
		await get_tree().create_timer(0.5).timeout
		_enemy_turns()

func _enemy_turns() -> void:
	for e in enemy_characters:
		if not e.is_alive():
			continue
		var dmg = e.calculate_damage(player_character)
		player_character.take_damage(dmg)
		if battle_ui:
			battle_ui.show_player_damage(dmg)
		await get_tree().create_timer(0.3).timeout
	if not _check_end() and battle_ui:
		battle_ui.enable_player_actions()

func _check_end() -> bool:
	if enemy_characters.is_empty():
		_end_battle(true)
		return true
	if player_character.is_defeated():
		_end_battle(false)
		return true
	return false

func _end_battle(victory: bool) -> void:
	battle_active = false
	GameManager.end_encounter(victory, _total_exp if victory else 0, {"gold": _total_gold if victory else 0, "items": []})
