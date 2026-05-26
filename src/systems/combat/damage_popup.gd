extends Node2D
class_name DamagePopup

@export var font_size: int = 14
@export var rise_speed: float = 40.0
@export var fade_duration: float = 0.6
@export var color_normal: Color = Color.WHITE
@export var color_critical: Color = Color.RED
@export var color_heal: Color = Color.GREEN_YELLOW

var _label: Label
var _elapsed: float = 0.0

func _ready() -> void:
	_label = Label.new()
	_label.z_index = 10
	_label.add_theme_font_size_override("font_size", font_size)
	_label.position = Vector2(-30, -10)
	add_child(_label)

func show_damage(amount: int, position: Vector2, is_critical: bool = false, is_heal: bool = false) -> void:
	global_position = position
	_label.text = str(amount)
	if is_heal:
		_label.add_theme_color_override("font_color", color_heal)
		_label.text = "+" + _label.text
	elif is_critical:
		_label.add_theme_color_override("font_color", color_critical)
		_label.text = _label.text + "!"
	else:
		_label.add_theme_color_override("font_color", color_normal)

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position", position + Vector2(0, -30), fade_duration)
	tween.tween_property(_label, "modulate:a", 0.0, fade_duration).set_delay(0.1)
	await tween.finished
	queue_free()
