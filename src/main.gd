extends Node

func _ready() -> void:
	_load_all_scripts()
	
func _load_all_scripts() -> void:
	load("res://src/systems/combat/health_component.gd")
	load("res://src/systems/combat/stamina_component.gd")
	load("res://src/systems/combat/camera_shake.gd")
	load("res://src/systems/combat/hit_pause.gd")
	load("res://src/systems/combat/damage_popup.gd")
	load("res://src/systems/combat/hurtbox_component.gd")
	load("res://src/systems/combat/hitbox_component.gd")
	load("res://src/systems/ai/enemy_state.gd")
	load("res://src/systems/ai/enemy_state_machine.gd")
	load("res://src/characters/player/player_combat_controller.gd")
	load("res://src/characters/player/player_controller.gd")
	load("res://src/characters/enemy/enemy_controller.gd")
	load("res://src/ui/combat/combat_hud.gd")
	load("res://src/scenes/world_map/world_map_controller.gd")
	load("res://src/scenes/main_menu/main_menu.gd")
	load("res://src/scenes/main_menu/options_menu.gd")
	load("res://src/scenes/character_creator/character_creator.gd")
	load("res://src/scenes/cutscene/intro_cutscene.gd")
	_setup_input_actions()
	print("=== Retro RPG Adventure ===")
	print("[Main] GameManager cargado: %s" % str(GameManager != null))
	print("[Main] SceneLoader cargado: %s" % str(SceneLoader != null))

	await get_tree().process_frame
	await SceneLoader.load_scene(
		"res://src/scenes/main_menu/main_menu.tscn",
		SceneLoader.TransitionType.FADE
	)
	print("[Main] Menu listo")

func _setup_input_actions() -> void:
	var actions = {
		"attack": [KEY_Z, KEY_SPACE],
		"run": [KEY_X, KEY_SHIFT],
	}
	for action_name in actions:
		if InputMap.has_action(action_name):
			continue
		InputMap.add_action(action_name)
		for key in actions[action_name]:
			var event = InputEventKey.new()
			event.keycode = key
			InputMap.action_add_event(action_name, event)
