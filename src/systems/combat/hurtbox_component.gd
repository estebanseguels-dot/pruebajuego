extends Area2D
class_name HurtboxComponent

signal took_damage(amount: int, knockback_dir: Vector2)

@export var health_component_path: NodePath = NodePath()

var health

func _ready() -> void:
	if health_component_path:
		health = get_node(health_component_path)
	else:
		var parent = get_parent()
		health = parent.get_node("HealthComponent") if parent and parent.has_node("HealthComponent") else null

func can_be_hit() -> bool:
	return health != null and not health.is_dead and not health.is_invulnerable
