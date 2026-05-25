extends Control
## BattleUI - UI del sistema de combate
## Maneja:
## - Visualización de HP
## - Selección de acciones
## - Animación de daño
## - Estado de batalla

class_name BattleUI

# Componentes
@onready var player_hp_bar = $PlayerHPBar
@onready var player_name_label = $PlayerNameLabel
@onready var action_menu = $ActionMenu
@onready var enemy_info_container = $EnemyInfoContainer

# Referencias
var player_character: BattleCharacter = null
var enemy_characters: Array[BattleCharacter] = []
var battle_controller: BattleController = null

func _ready() -> void:
	name = "BattleUI"
	battle_controller = get_parent()
	
	# Crear elementos si no existen
	if not player_hp_bar:
		_create_player_hud()
	if not action_menu:
		_create_action_menu()
	if not enemy_info_container:
		_create_enemy_display()

## Inicializa la UI con personajes
func initialize(player: BattleCharacter, enemies: Array[BattleCharacter]) -> void:
	player_character = player
	enemy_characters = enemies
	
	_update_player_display()
	_update_enemy_display()
	enable_player_actions()

## Crea el HUD del jugador
func _create_player_hud() -> void:
	# Crear contenedor
	var player_hud = VBoxContainer.new()
	player_hud.name = "PlayerHUD"
	player_hud.position = Vector2(10, 10)
	add_child(player_hud)
	
	# Nombre
	player_name_label = Label.new()
	player_name_label.text = "[Player]"
	player_name_label.add_theme_font_size_override("font_size", 14)
	player_hud.add_child(player_name_label)
	
	# Barra de HP
	player_hp_bar = ProgressBar.new()
	player_hp_bar.size.x = 200
	player_hp_bar.custom_minimum_size = Vector2(200, 20)
	player_hud.add_child(player_hp_bar)

## Crea el menú de acciones
func _create_action_menu() -> void:
	action_menu = VBoxContainer.new()
	action_menu.name = "ActionMenu"
	action_menu.position = Vector2(10, 100)
	add_child(action_menu)
	
	var actions = ["Attack", "Defend", "Item", "Escape"]
	for action in actions:
		var button = Button.new()
		button.text = action
		button.pressed.connect(_on_action_button_pressed.bindv([action]))
		action_menu.add_child(button)

## Crea la visualización de enemigos
func _create_enemy_display() -> void:
	enemy_info_container = VBoxContainer.new()
	enemy_info_container.name = "EnemyInfoContainer"
	enemy_info_container.position = Vector2(320, 10)
	add_child(enemy_info_container)

## Actualiza la visualización del jugador
func _update_player_display() -> void:
	if not player_character:
		return
	
	if player_name_label:
		player_name_label.text = "%s - Lvl %d" % [
			player_character.character_type,
			player_character.level
		]
	
	if player_hp_bar:
		player_hp_bar.max_value = player_character.max_health
		player_hp_bar.value = player_character.health
		player_hp_bar.tooltip_text = "%d/%d" % [
			player_character.health,
			player_character.max_health
		]

## Actualiza la visualización de enemigos
func _update_enemy_display() -> void:
	# Limpiar display anterior
	for child in enemy_info_container.get_children():
		child.queue_free()
	
	for i in range(enemy_characters.size()):
		var enemy = enemy_characters[i]
		var enemy_hud = _create_enemy_hud(enemy, i)
		enemy_info_container.add_child(enemy_hud)

## Crea un HUD para un enemigo específico
func _create_enemy_hud(enemy: BattleCharacter, index: int) -> VBoxContainer:
	var hud = VBoxContainer.new()
	hud.name = "Enemy_%d" % index
	
	# Nombre
	var name_label = Label.new()
	name_label.text = "%s Lvl %d" % [enemy.character_type, enemy.level]
	name_label.add_theme_font_size_override("font_size", 12)
	hud.add_child(name_label)
	
	# Barra de HP
	var hp_bar = ProgressBar.new()
	hp_bar.max_value = enemy.max_health
	hp_bar.value = enemy.health
	hp_bar.custom_minimum_size = Vector2(200, 16)
	hud.add_child(hp_bar)
	
	# Guardar referencia para actualización
	hud.set_meta("hp_bar", hp_bar)
	hud.set_meta("name_label", name_label)
	
	return hud

## Manejo de botones de acción
func _on_action_button_pressed(action: String) -> void:
	match action:
		"Attack":
			_show_target_selection("attack")
		"Defend":
			disable_player_actions()
			battle_controller.execute_player_action("defend")
		"Item":
			disable_player_actions()
			battle_controller.execute_player_action("item")
		"Escape":
			disable_player_actions()
			battle_controller.execute_player_action("escape")

## Muestra selección de objetivo
func _show_target_selection(action: String) -> void:
	print("[UI] Seleccionar objetivo para: ", action)
	# TODO: Implementar selección visual de objetivos
	disable_player_actions()
	battle_controller.execute_player_action(action, 0)

## Muestra daño en enemigo
func show_damage(damage: int, enemy_index: int) -> void:
	if enemy_index >= enemy_info_container.get_child_count():
		return
	
	var enemy_hud = enemy_info_container.get_child(enemy_index)
	var hp_bar = enemy_hud.get_meta("hp_bar")
	
	if hp_bar:
		hp_bar.value = enemy_characters[enemy_index].health
		
		# Animar daño
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_BOUNCE)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(hp_bar, "scale", Vector2(1.1, 1.1), 0.1)
		tween.tween_property(hp_bar, "scale", Vector2(1.0, 1.0), 0.1)

## Muestra daño del jugador
func show_player_damage(damage: int) -> void:
	if player_hp_bar:
		player_hp_bar.value = player_character.health
		
		# Animar daño
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_BOUNCE)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(player_hp_bar, "scale", Vector2(1.1, 1.1), 0.1)
		tween.tween_property(player_hp_bar, "scale", Vector2(1.0, 1.0), 0.1)

## Habilita acciones del jugador
func enable_player_actions() -> void:
	if action_menu:
		action_menu.visible = true
		for button in action_menu.get_children():
			button.disabled = false

## Desactiva acciones del jugador
func disable_player_actions() -> void:
	if action_menu:
		for button in action_menu.get_children():
			button.disabled = true
