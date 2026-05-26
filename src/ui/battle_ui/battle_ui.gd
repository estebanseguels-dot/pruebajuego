extends Control
class_name BattleUI

@onready var player_name_label = $PlayerHUD/PlayerNameLabel
@onready var player_hp_bar = $PlayerHUD/PlayerHPBar
@onready var action_menu = $ActionMenu
@onready var enemy_info_container = $EnemyInfoContainer

var player_character = null
var enemy_characters = []
var battle_controller = null

func _ready() -> void:
	battle_controller = get_parent()

	for button in action_menu.get_children():
		button.pressed.connect(_on_action.bind(button.text.to_lower()))

func initialize(player, enemies) -> void:
	player_character = player
	enemy_characters = enemies
	_update_player_display()
	_build_enemy_list()
	enable_player_actions()

func _update_player_display() -> void:
	if not player_character:
		return
	player_name_label.text = "%s Lvl %d" % [player_character.character_type, player_character.level]
	player_hp_bar.max_value = player_character.max_health
	player_hp_bar.value = player_character.health

func _build_enemy_list() -> void:
	for c in enemy_info_container.get_children():
		c.queue_free()

	for i in enemy_characters.size():
		var e = enemy_characters[i]
		var vbox = VBoxContainer.new()
		vbox.name = "Enemy_%d" % i

		var label = Label.new()
		label.text = "%s Lvl %d" % [e.character_type, e.level]
		vbox.add_child(label)

		var bar = ProgressBar.new()
		bar.max_value = e.max_health
		bar.value = e.health
		bar.custom_minimum_size = Vector2(200, 16)
		bar.add_theme_color_override("font_color", Color.RED)
		vbox.add_child(bar)

		vbox.set_meta("hp_bar", bar)
		enemy_info_container.add_child(vbox)

func _on_action(action: String) -> void:
	match action:
		"attack":
			disable_player_actions()
			battle_controller.execute_player_action("attack", 0)
		"defend":
			disable_player_actions()
			battle_controller.execute_player_action("defend")
		"item":
			disable_player_actions()
			battle_controller.execute_player_action("item")
		"escape":
			disable_player_actions()
			battle_controller.execute_player_action("escape")

func show_damage(damage: int, enemy_index: int) -> void:
	if enemy_index >= enemy_info_container.get_child_count():
		return
	var hud = enemy_info_container.get_child(enemy_index)
	var bar = hud.get_meta("hp_bar") as ProgressBar
	if not bar:
		return
	if enemy_index < enemy_characters.size():
		bar.value = enemy_characters[enemy_index].health
	var tween = create_tween()
	tween.tween_property(bar, "scale", Vector2(1.15, 1.15), 0.08)
	tween.tween_property(bar, "scale", Vector2(1.0, 1.0), 0.12)

func show_player_damage(damage: int) -> void:
	player_hp_bar.value = player_character.health
	var tween = create_tween()
	tween.tween_property(player_hp_bar, "scale", Vector2(1.15, 1.15), 0.08)
	tween.tween_property(player_hp_bar, "scale", Vector2(1.0, 1.0), 0.12)

func enable_player_actions() -> void:
	action_menu.visible = true
	for b in action_menu.get_children():
		b.disabled = false

func disable_player_actions() -> void:
	for b in action_menu.get_children():
		b.disabled = true
