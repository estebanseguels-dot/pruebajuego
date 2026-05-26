extends Node
class_name StaminaComponent

signal stamina_changed(current: float, max_stamina: float)
signal depleted
signal recharged

@export var max_stamina: float = 100.0
@export var regen_rate: float = 20.0
@export var regen_delay: float = 0.6

var current_stamina: float : set = _set_stamina
var _regen_timer: float = 0.0
var _can_regen: bool = true

func _ready() -> void:
	current_stamina = max_stamina

func _set_stamina(value: float) -> void:
	current_stamina = clampf(value, 0.0, max_stamina)
	stamina_changed.emit(current_stamina, max_stamina)

func _process(delta: float) -> void:
	if not _can_regen:
		_regen_timer -= delta
		if _regen_timer <= 0.0:
			_can_regen = true

	if _can_regen and current_stamina < max_stamina:
		current_stamina += regen_rate * delta

func consume(amount: float) -> bool:
	if current_stamina < amount:
		return false

	current_stamina -= amount
	_can_regen = false
	_regen_timer = regen_delay

	if current_stamina <= 0.0:
		depleted.emit()

	return true

func has_enough(amount: float) -> bool:
	return current_stamina >= amount

func refill() -> void:
	current_stamina = max_stamina
	_can_regen = true

func get_percentage() -> float:
	return current_stamina / max_stamina
