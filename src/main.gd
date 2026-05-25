extends Node
## Main - Script de bootstrap del juego
## Punto de entrada principal
## Inicializa sistemas globales

class_name Main

func _ready() -> void:
	print("=== Retro RPG Adventure ===")
	print("[Main] Inicializando sistemas...")
	
	# Verificar que AutoLoads estén cargados
	if not is_node_in_group("autoload"):
		assert(GameManager != null, "GameManager no cargado")
		assert(SceneLoader != null, "SceneLoader no cargado")
	
	print("[Main] GameManager cargado:", GameManager != null)
	print("[Main] SceneLoader cargado:", SceneLoader != null)
	
	# Cargar primera escena
	await get_tree().process_frame
	await SceneLoader.load_scene(
		"res://src/scenes/world_map/world_map.tscn",
		SceneLoader.TransitionType.FADE
	)
	
	print("[Main] Juego listo")
