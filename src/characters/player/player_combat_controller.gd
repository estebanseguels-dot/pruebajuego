extends Node
class_name PlayerCombatController

const _CS = preload("res://src/systems/combat/camera_shake.gd")
const _HP = preload("res://src/systems/combat/hit_pause.gd")
const _DP = preload("res://src/systems/combat/damage_popup.gd")

enum AttackState {
	IDLE,
	STARTUP,
	ACTIVE,
	RECOVERY,
	CHARGE,
	CHARGED_STARTUP,
	CHARGED_ACTIVE,
	CHARGED_RECOVERY,
	HURT,
	DEATH
}

signal attack_state_changed(state: AttackState)
signal attack_hit(target: Node2D, damage: int)

@export var light_attack_cost: float = 15.0
@export var charged_attack_cost: float = 35.0
@export var light_attack_damage: int = 10
@export var charged_attack_damage: int = 25

@export var startup_frames: float = 0.12
@export var active_frames: float = 0.08
@export var recovery_frames: float = 0.18

@export var charged_startup_frames: float = 0.25
@export var charged_active_frames: float = 0.12
@export var charged_recovery_frames: float = 0.30

@export var charge_hold_time: float = 0.5
@export var combo_window: float = 0.4
@export var knockback_force: float = 250.0

@onready var hitbox = get_parent().get_node("HitboxComponent")
@onready var stamina = get_parent().get_node("StaminaComponent")
@onready var health = get_parent().get_node("HealthComponent")
var player
var current_state = AttackState.IDLE
var current_combo: int = 0
var charge_progress: float = 0.0
var is_charging: bool = false
var _state_timer: float = 0.0
var _combo_timer: float = 0.0
var _facing_when_attacked: Vector2
var _hold_time: float = 0.0
var _input_locked: bool = false

func _ready() -> void:
	player = get_parent()
	hitbox.damage = light_attack_damage
	hitbox.knockback_force = knockback_force
	hitbox.hit_hurtbox.connect(_on_hit_hurtbox)
	health.damaged.connect(_on_player_damaged)
	health.died.connect(_on_player_died)

func _process(delta: float) -> void:
	if GameManager.is_transitioning:
		return

	_combo_timer -= delta
	if _combo_timer <= 0.0 and current_combo > 0:
		current_combo = 0

	match current_state:
		AttackState.IDLE:
			_handle_attack_input(delta)
		AttackState.CHARGE:
			_handle_charge(delta)
		AttackState.HURT:
			_state_timer -= delta
			if _state_timer <= 0.0:
				_set_state(AttackState.IDLE)
				player.set_can_move(true)
		AttackState.STARTUP, AttackState.ACTIVE, AttackState.RECOVERY, \
		AttackState.CHARGED_STARTUP, AttackState.CHARGED_ACTIVE, AttackState.CHARGED_RECOVERY:
			_state_timer -= delta
			if _state_timer <= 0.0:
				_advance_state()

func _set_state(new_state) -> void:
	current_state = new_state
	attack_state_changed.emit(new_state)

func _handle_attack_input(delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		_input_locked = false
		_hold_time = 0.0
		if stamina.has_enough(light_attack_cost):
			stamina.consume(light_attack_cost)
			current_combo = clampi(current_combo + 1, 1, 2)
			_start_attack("light")
		return

	if current_state != AttackState.IDLE:
		return

	if Input.is_action_pressed("attack") and not _input_locked:
		_hold_time += delta
		if _hold_time >= charge_hold_time:
			if stamina.has_enough(charged_attack_cost):
				stamina.consume(charged_attack_cost)
				_start_charge()

func _handle_charge(delta: float) -> void:
	charge_progress += delta

	if Input.is_action_just_released("attack"):
		if charge_progress >= charge_hold_time * 0.5:
			_execute_charged_attack()
		else:
			_set_state(AttackState.IDLE)
			player.set_can_move(true)
		return

	if charge_progress >= charge_hold_time * 2.0:
		_execute_charged_attack()

func _start_attack(type: String) -> void:
	_facing_when_attacked = player.facing_direction
	hitbox.knockback_force = knockback_force
	_position_hitbox(_facing_when_attacked)

	if type == "light":
		hitbox.damage = light_attack_damage + (current_combo * 3)
		_state_timer = startup_frames
		_set_state(AttackState.STARTUP)
	else:
		hitbox.damage = charged_attack_damage
		hitbox.knockback_force = knockback_force * 1.5
		_state_timer = charged_startup_frames
		_set_state(AttackState.CHARGED_STARTUP)

	player.set_can_move(false)

func _advance_state() -> void:
	match current_state:
		AttackState.STARTUP:
			hitbox.active = true
			_state_timer = active_frames
			_set_state(AttackState.ACTIVE)
		AttackState.ACTIVE:
			hitbox.active = false
			_state_timer = recovery_frames
			_set_state(AttackState.RECOVERY)
		AttackState.RECOVERY:
			_set_state(AttackState.IDLE)
			player.set_can_move(true)
			_combo_timer = combo_window
		AttackState.CHARGED_STARTUP:
			hitbox.active = true
			_state_timer = charged_active_frames
			_set_state(AttackState.CHARGED_ACTIVE)
		AttackState.CHARGED_ACTIVE:
			hitbox.active = false
			_state_timer = charged_recovery_frames
			_set_state(AttackState.CHARGED_RECOVERY)
		AttackState.CHARGED_RECOVERY:
			_set_state(AttackState.IDLE)
			player.set_can_move(true)

func _start_charge() -> void:
	_input_locked = true
	_facing_when_attacked = player.facing_direction
	_position_hitbox(_facing_when_attacked)
	charge_progress = 0.0
	is_charging = true
	player.set_can_move(true)
	player.speed *= 0.5
	_set_state(AttackState.CHARGE)

func _execute_charged_attack() -> void:
	is_charging = false
	player.speed /= 0.5
	_position_hitbox(_facing_when_attacked)
	_state_timer = charged_startup_frames
	player.set_can_move(false)
	_set_state(AttackState.CHARGED_STARTUP)

func _on_hit_hurtbox(hurtbox, hit_position: Vector2) -> void:
	var is_charged = current_state in [AttackState.CHARGED_ACTIVE, AttackState.CHARGED_STARTUP]

	if is_charged:
		_CS.shake(8.0, 0.25)
		_HP.pause(0.12, 0.05)
	else:
		_CS.shake(4.0, 0.15)
		_HP.pause(0.08, 0.05)

	var popup = _DP.new()
	get_tree().root.add_child(popup)
	popup.show_damage(hitbox.damage, hit_position, is_charged)

	attack_hit.emit(hurtbox.get_parent() as Node2D, hitbox.damage)

func _on_player_damaged(amount: int, knockback_dir: Vector2) -> void:
	if current_state == AttackState.DEATH:
		return

	if is_charging:
		is_charging = false
		player.speed /= 0.5

	_set_state(AttackState.HURT)
	hitbox.active = false
	player.velocity = knockback_dir
	player.set_can_move(false)
	_state_timer = 0.3

	_CS.shake(5.0, 0.2)
	stamina.refill()

func _on_player_died() -> void:
	_set_state(AttackState.DEATH)
	hitbox.active = false
	player.set_can_move(false)
	player.velocity = Vector2.ZERO

func is_attacking() -> bool:
	return current_state in [
		AttackState.STARTUP, AttackState.ACTIVE, AttackState.RECOVERY,
		AttackState.CHARGED_STARTUP, AttackState.CHARGED_ACTIVE, AttackState.CHARGED_RECOVERY
	]

func get_attack_animation() -> String:
	var base = "attack"
	if current_state in [AttackState.CHARGED_STARTUP, AttackState.CHARGED_ACTIVE, AttackState.CHARGED_RECOVERY]:
		base = "attack_charged"
	var dir = _facing_when_attacked
	if abs(dir.x) > abs(dir.y):
		return base + ("_right" if dir.x > 0 else "_left")
	else:
		return base + ("_down" if dir.y > 0 else "_up")

func get_hurt_animation() -> String:
	var dir = player.facing_direction
	if abs(dir.x) > abs(dir.y):
		return "hurt_right" if dir.x > 0 else "hurt_left"
	else:
		return "hurt_down" if dir.y > 0 else "hurt_up"

func _position_hitbox(dir: Vector2) -> void:
	var offset = 22.0
	var shape_node = hitbox.get_node("CollisionShape2D") as CollisionShape2D
	if not shape_node:
		return
	if abs(dir.x) > abs(dir.y):
		shape_node.position = Vector2(offset if dir.x > 0 else -offset, 0)
	else:
		shape_node.position = Vector2(0, offset if dir.y > 0 else -offset)
