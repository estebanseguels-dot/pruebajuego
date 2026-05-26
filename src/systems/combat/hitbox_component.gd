extends Area2D
class_name HitboxComponent

signal hit_hurtbox(hurtbox, hit_position: Vector2)

@export var damage: int = 10
@export var knockback_force: float = 200.0
@export var active: bool = false : set = _set_active

var _already_hit = []

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _set_active(value: bool) -> void:
	active = value
	monitoring = value
	_already_hit.clear()
	if value:
		for area in get_overlapping_areas():
			_check_hurtbox(area)

func _on_area_entered(area: Area2D) -> void:
	_check_hurtbox(area)

func _check_hurtbox(area: Area2D) -> void:
	if not active:
		return

	var hurtbox = area
	if not hurtbox.has_method(&"can_be_hit"):
		return
	if hurtbox in _already_hit:
		return
	if not hurtbox.can_be_hit():
		return

	_already_hit.append(hurtbox)

	var health = hurtbox.health
	if health and not health.is_dead:
		var dir = Vector2.ZERO
		var owner_node = owner if owner else get_parent()
		if owner_node and hurtbox.owner:
			dir = (hurtbox.owner.global_position - owner_node.global_position).normalized()
		health.take_damage(damage, dir * knockback_force)

	hit_hurtbox.emit(hurtbox, global_position)
