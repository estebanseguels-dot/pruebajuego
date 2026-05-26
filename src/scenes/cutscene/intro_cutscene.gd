extends CanvasLayer
class_name IntroCutscene

var _step_queue: Array[Dictionary] = []
var _step_index: int = 0
var _busy: bool = false
var _character_x: float = -80.0

func _ready() -> void:
	name = "IntroCutscene"
	_build_scene()
	_start()

func _build_scene() -> void:
	_step_queue = [
		{"type": "walk", "px": 250},
		{"type": "talk", "speaker": "Tú", "line": "¿Sabes qué es lo que más extraño del cine antiguo, compañero?"},
		{"type": "walk", "px": 180},
		{"type": "talk", "speaker": "Tú", "line": "Cuando Tony Stark se tomaba tres minutos de la película solo para ver cómo su armadura se ensamblaba lentamente..."},
		{"type": "walk", "px": 150},
		{"type": "talk", "speaker": "Tú", "line": "O cómo se veía Bruce Banner en 2008 ya transformado. Todo tenía peso."},
		{"type": "walk", "px": 120},
		{"type": "talk", "speaker": "Tú", "line": "Ahora todo es demasiado rápido. Poco cautivante. Todo explota y a nadie le importa."},
		{"type": "arrive"},
		{"type": "talk", "speaker": "Tú", "line": "Bueno, llegamos. Dicen que esta es diferente. Vamos."},
		{"type": "fade_out", "sec": 0.6},
		{"type": "flash", "sec": 1.5, "line": "INTERSTELLAR 3"},
		{"type": "fade_in", "sec": 0.4, "walk": 60, "people": true},
		{"type": "wait", "sec": 1.0},
		{"type": "talk", "speaker": "Tú", "line": "..."},
		{"type": "disperse"},
		{"type": "walk", "px": 40},
		{"type": "talk", "speaker": "Tú", "line": "Al menos la música estaba buena. Vamos a casa."},
		{"type": "fade_out", "sec": 1.0},
		{"type": "end"},
	]

func _start() -> void:
	$Cinema.hide()
	$People.hide()
	$Flash.hide()
	$TextBox.hide()
	_character_x = $Character.position.x
	_process_next()

func _process_next() -> void:
	if _step_index >= _step_queue.size():
		return
	_busy = true
	var s = _step_queue[_step_index]
	_step_index += 1
	match s["type"]:
		"walk":
			_do_walk(s["px"])
		"talk":
			_do_talk(s.get("speaker", ""), s["line"])
		"arrive":
			_do_arrive()
		"fade_out":
			_do_fade_out(s["sec"])
		"fade_in":
			_do_fade_in(s["sec"], s.get("walk", 0), s.get("people", false))
		"flash":
			_do_flash(s["sec"], s["line"])
		"wait":
			await get_tree().create_timer(s["sec"]).timeout
			_busy = false
			_process_next()
		"disperse":
			_do_disperse()
		"end":
			SceneLoader.load_scene("res://src/scenes/world_map/world_map.tscn", SceneLoader.TransitionType.FADE)

func _do_walk(px: float) -> void:
	var target_x = _character_x + px
	var tween = create_tween().set_parallel(true)
	tween.tween_property($Character, "position:x", target_x, 2.0)
	tween.tween_property($Pet, "position:x", target_x - 20, 2.0)
	await tween.finished
	_character_x = target_x
	_busy = false
	_process_next()

func _do_talk(speaker: String, line: String) -> void:
	$TextBox/Speaker.text = speaker
	$TextBox/Text.text = line
	$TextBox.show()
	await get_tree().create_timer(2.5).timeout
	$TextBox.hide()
	_busy = false
	_process_next()

func _do_arrive() -> void:
	var t = create_tween()
	t.tween_property($Cinema, "modulate:a", 1.0, 0.8)
	await t.finished
	_busy = false
	_process_next()

func _do_fade_out(sec: float) -> void:
	var t = create_tween()
	t.tween_property($FadeRect, "color:a", 1.0, sec)
	await t.finished
	_busy = false
	_process_next()

func _do_fade_in(sec: float, walk_px: float, show_people: bool) -> void:
	if show_people:
		$People.show()
		$Cinema.modulate.a = 1.0
		_character_x = 200.0
		$Character.position.x = _character_x
		$Pet.position.x = _character_x - 20
		if walk_px > 0:
			var target_x = _character_x + walk_px
			var t2 = create_tween().set_parallel(true)
			t2.tween_property($Character, "position:x", target_x, 1.2)
			t2.tween_property($Pet, "position:x", target_x - 20, 1.2)
			_character_x = target_x
	var t = create_tween()
	t.tween_property($FadeRect, "color:a", 0.0, sec)
	await t.finished
	_busy = false
	_process_next()

func _do_flash(sec: float, line: String) -> void:
	$Flash/Label.text = line
	$Flash.show()
	await get_tree().create_timer(sec).timeout
	$Flash.hide()
	_busy = false
	_process_next()

func _do_disperse() -> void:
	var t = create_tween()
	var people_count = $People.get_child_count()
	for i in range(people_count):
		var p = $People.get_child(i)
		var dir = Vector2(randf_range(-100, 100), randf_range(-80, 80))
		t.parallel().tween_property(p, "position", p.position + dir, 0.8)
		t.parallel().tween_property(p, "modulate:a", 0.0, 0.8)
	await t.finished
	$People.hide()
	for i in range(people_count):
		var p = $People.get_child(i)
		p.modulate.a = 1.0
	_busy = false
	_process_next()
