extends CanvasLayer
class_name CombatHUD

@onready var player_hp_bar = $PlayerInfo/PlayerHPBar
@onready var player_hp_label = $PlayerInfo/PlayerHPLabel
@onready var stamina_bar = $PlayerInfo/StaminaBar
@onready var enemy_panel = $EnemyInfo
@onready var enemy_hp_bar = $EnemyInfo/EnemyHPBar
@onready var enemy_name_label = $EnemyInfo/EnemyNameLabel
@onready var target_reticle = $TargetReticle

var _player_health
var _player_stamina
var _current_target: Node2D = null
var _last_enemy_health

func _ready() -> void:
	name = "CombatHUD"
	target_reticle.hide()
	enemy_panel.hide()

func setup(player_health, player_stamina) -> void:
	_player_health = player_health
	_player_stamina = player_stamina
	player_health.hp_changed.connect(_on_player_hp_changed)
	player_stamina.stamina_changed.connect(_on_stamina_changed)
	_on_player_hp_changed(player_health.current_health, player_health.max_health)
	_on_stamina_changed(player_stamina.current_stamina, player_stamina.max_stamina)

func _on_player_hp_changed(current: int, max_hp: int) -> void:
	if player_hp_bar:
		player_hp_bar.value = current
		player_hp_bar.max_value = max_hp
		player_hp_label.text = "%d/%d" % [current, max_hp]

func _on_stamina_changed(current: float, max_stamina: float) -> void:
	if stamina_bar:
		stamina_bar.value = current
		stamina_bar.max_value = max_stamina

func set_target(enemy: Node2D) -> void:
	if _last_enemy_health and _last_enemy_health.hp_changed.is_connected(_on_enemy_hp_changed):
		_last_enemy_health.hp_changed.disconnect(_on_enemy_hp_changed)

	_current_target = enemy

	if enemy and is_instance_valid(enemy):
		target_reticle.global_position = enemy.global_position + Vector2(0, -40)
		target_reticle.show()
		enemy_panel.show()
		var health = _get_health_component(enemy)
		if health:
			_last_enemy_health = health
			enemy_name_label.text = enemy.name
			enemy_hp_bar.value = health.current_health
			enemy_hp_bar.max_value = health.max_health
			health.hp_changed.connect(_on_enemy_hp_changed)
	else:
		target_reticle.hide()
		enemy_panel.hide()
		_last_enemy_health = null

func _on_enemy_hp_changed(current: int, max_hp: int) -> void:
	if not is_instance_valid(_current_target):
		clear_target()
		return
	if enemy_hp_bar:
		enemy_hp_bar.value = current
		enemy_hp_bar.max_value = max_hp

func clear_target() -> void:
	set_target(null)

func _get_health_component(node):
	return node.get_node("HealthComponent") if node and node.has_node("HealthComponent") else null

func update_player_hp(current: int, max_hp: int) -> void:
	player_hp_bar.value = current
	player_hp_bar.max_value = max_hp
	player_hp_label.text = "%d/%d" % [current, max_hp]
