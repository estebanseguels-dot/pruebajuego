extends CanvasLayer
class_name MainMenu

@onready var new_game_btn = $VBox/NewGameBtn
@onready var load_game_btn = $VBox/LoadGameBtn
@onready var options_btn = $VBox/OptionsBtn
@onready var options_menu = $OptionsMenu

func _ready() -> void:
	name = "MainMenu"
	options_menu.hide()
	load_game_btn.disabled = not DataManager.has_save()

func _on_new_game_pressed() -> void:
	GameManager.reset_game()
	SceneLoader.load_scene("res://src/scenes/character_creator/character_creator.tscn", SceneLoader.TransitionType.FADE)

func _on_load_game_pressed() -> void:
	if DataManager.load_game():
		SceneLoader.load_scene("res://src/scenes/world_map/world_map.tscn", SceneLoader.TransitionType.FADE)

func _on_options_pressed() -> void:
	options_menu.populate()
	options_menu.show()

func _on_options_back() -> void:
	options_menu.hide()
