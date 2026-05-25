extends Node
## SceneLoader - Gestor de carga y transición de escenas
## Maneja:
## - Transiciones suaves (fade, slide, etc.)
## - Carga asincrónica de escenas
## - Prevención de duplicados
## - Comunicación entre escenas

class_name SceneLoader

enum TransitionType {
	FADE,
	SLIDE_LEFT,
	SLIDE_RIGHT,
	SLIDE_DOWN,
	SLIDE_UP,
	NONE
}

# Transición actual en progreso
var _is_transitioning: bool = false
var _current_transition_type: TransitionType = TransitionType.NONE

# Canvas layer para las transiciones visuales
var _transition_canvas: CanvasLayer = null
var _transition_rect: ColorRect = null

# Referencias a escenas
var _current_scene: Node = null
var _loading_screen: Node = null

func _ready() -> void:
	name = "SceneLoader"
	_setup_transition_canvas()
	print("[SceneLoader] Inicializado")

## Configura el canvas para transiciones
func _setup_transition_canvas() -> void:
	_transition_canvas = CanvasLayer.new()
	_transition_canvas.layer = 100  # Encima de todo
	add_child(_transition_canvas)
	
	_transition_rect = ColorRect.new()
	_transition_rect.color = Color.BLACK
	_transition_rect.anchor_right = 1.0
	_transition_rect.anchor_bottom = 1.0
	_transition_rect.color.a = 0.0  # Transparente inicialmente
	_transition_canvas.add_child(_transition_rect)

## Carga una escena con transición
func load_scene(path: String, transition: TransitionType = TransitionType.FADE) -> void:
	if _is_transitioning:
		print("[SceneLoader] Ya hay una transición en progreso")
		return
	
	_is_transitioning = true
	_current_transition_type = transition
	
	# Fade out
	await _execute_transition_in(transition)
	
	# Limpiar escena anterior
	if _current_scene:
		_current_scene.queue_free()
	
	# Cargar nueva escena
	var new_scene = load(path).instantiate()
	get_tree().root.add_child(new_scene)
	_current_scene = new_scene
	
	# Actualizar referencias en GameManager
	if "world_map" in path:
		GameManager.world_map = new_scene
	elif "battle" in path:
		GameManager.battle_scene = new_scene
	
	GameManager.current_scene = new_scene
	
	# Fade in
	await _execute_transition_out(transition)
	
	_is_transitioning = false
	print("[SceneLoader] Escena cargada: %s" % path)

## Transición de entrada (fade out/ocultación)
func _execute_transition_in(transition: TransitionType) -> void:
	match transition:
		TransitionType.FADE:
			await _fade_in()
		TransitionType.SLIDE_LEFT:
			await _slide_left_in()
		TransitionType.SLIDE_RIGHT:
			await _slide_right_in()
		TransitionType.NONE:
			await get_tree().create_timer(0.1).timeout

## Transición de salida (fade in/reaparición)
func _execute_transition_out(transition: TransitionType) -> void:
	match transition:
		TransitionType.FADE:
			await _fade_out()
		TransitionType.SLIDE_LEFT:
			await _slide_left_out()
		TransitionType.SLIDE_RIGHT:
			await _slide_right_out()
		TransitionType.NONE:
			await get_tree().create_timer(0.1).timeout

## Fade to black (entrada)
func _fade_in() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(_transition_rect, "color:a", 1.0, 0.5)
	await tween.finished

## Fade from black (salida)
func _fade_out() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(_transition_rect, "color:a", 0.0, 0.5)
	await tween.finished

## Slide left (entrada)
func _slide_left_in() -> void:
	_transition_rect.color.a = 1.0
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(_transition_rect, "position:x", 0, 0.4)
	await tween.finished

## Slide left (salida)
func _slide_left_out() -> void:
	var screen_size = get_viewport().get_visible_rect().size
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(_transition_rect, "position:x", -screen_size.x, 0.4)
	await tween.finished

## Slide right (entrada)
func _slide_right_in() -> void:
	_transition_rect.color.a = 1.0
	_transition_rect.position.x = get_viewport().get_visible_rect().size.x
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(_transition_rect, "position:x", 0, 0.4)
	await tween.finished

## Slide right (salida)
func _slide_right_out() -> void:
	var screen_size = get_viewport().get_visible_rect().size
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(_transition_rect, "position:x", screen_size.x, 0.4)
	await tween.finished

## Verifica si está en transición
func is_transitioning() -> bool:
	return _is_transitioning
