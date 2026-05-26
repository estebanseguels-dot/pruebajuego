extends Node

enum TransitionType {
	FADE,
	SLIDE_LEFT,
	SLIDE_RIGHT,
	SLIDE_DOWN,
	SLIDE_UP,
	NONE
}

var _is_transitioning: bool = false
var _current_transition_type: TransitionType = TransitionType.NONE
var _transition_canvas: CanvasLayer = null
var _transition_rect: ColorRect = null
var _current_scene: Node = null

func _ready() -> void:
	name = "SceneLoader"
	_setup_transition_canvas()

func _setup_transition_canvas() -> void:
	_transition_canvas = CanvasLayer.new()
	_transition_canvas.layer = 100
	add_child(_transition_canvas)

	_transition_rect = ColorRect.new()
	_transition_rect.color = Color.BLACK
	_transition_rect.anchor_right = 1.0
	_transition_rect.anchor_bottom = 1.0
	_transition_rect.color.a = 0.0
	_transition_canvas.add_child(_transition_rect)

func load_scene(path: String, transition: TransitionType = TransitionType.FADE) -> Node:
	if _is_transitioning:
		return null

	_is_transitioning = true
	_current_transition_type = transition

	await _execute_transition_in(transition)

	if _current_scene:
		_current_scene.queue_free()
		_current_scene = null

	var new_scene = load(path).instantiate()
	get_tree().root.add_child(new_scene)
	_current_scene = new_scene

	await _execute_transition_out(transition)

	_is_transitioning = false
	return new_scene

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

func _fade_in() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(_transition_rect, "color:a", 1.0, 0.5)
	await tween.finished

func _fade_out() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(_transition_rect, "color:a", 0.0, 0.5)
	await tween.finished

func _slide_left_in() -> void:
	_transition_rect.color.a = 1.0
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(_transition_rect, "position:x", 0, 0.4)
	await tween.finished

func _slide_left_out() -> void:
	var screen_size = get_viewport().get_visible_rect().size
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(_transition_rect, "position:x", -screen_size.x, 0.4)
	await tween.finished

func _slide_right_in() -> void:
	_transition_rect.color.a = 1.0
	_transition_rect.position.x = get_viewport().get_visible_rect().size.x
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(_transition_rect, "position:x", 0, 0.4)
	await tween.finished

func _slide_right_out() -> void:
	var screen_size = get_viewport().get_visible_rect().size
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(_transition_rect, "position:x", screen_size.x, 0.4)
	await tween.finished

func is_transitioning() -> bool:
	return _is_transitioning
