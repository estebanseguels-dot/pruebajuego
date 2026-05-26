extends CharacterBody2D
class_name EnemyController

const _ES = preload("res://src/systems/ai/enemy_state.gd")
const _IDLE = preload("res://src/systems/ai/states/idle_state.gd")
const _PATROL = preload("res://src/systems/ai/states/patrol_state.gd")
const _CHASE = preload("res://src/systems/ai/states/chase_state.gd")
const _ATTACK = preload("res://src/systems/ai/states/attack_state.gd")
const _RETREAT = preload("res://src/systems/ai/states/retreat_state.gd")
const _HURT = preload("res://src/systems/ai/states/hurt_state.gd")
const _DEATH = preload("res://src/systems/ai/states/death_state.gd")

@export var enemy_type: String = "Slime"
@export var level: int = 1
@export var move_speed: float = 60.0
@export var chase_speed: float = 90.0
@export var patrol_range: float = 100.0
@export var attack_range: float = 30.0
@export var attack_damage: int = 8
@export var attack_startup: float = 0.2
@export var attack_active: float = 0.15
@export var attack_recovery: float = 0.35
@export var attack_cooldown: float = 1.5
@export var hurt_stun_time: float = 0.25
@export var friction: float = 300.0
@export var exp_value: int = 50
@export var leash_range: float = 250.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var detection_area = $DetectionArea
@onready var health = $HealthComponent
@onready var hurtbox = $HurtboxComponent
@onready var hitbox = $HitboxComponent
@onready var vfx: Node2D = $VFX
@onready var fsm = $EnemyStateMachine
var _player_ref: Node2D = null
var _facing_dir: Vector2 = Vector2.DOWN
var _attack_cooldown_timer: float = 0.0

func _ready() -> void:
	add_to_group("enemy")
	_setup_state_machine()

	detection_area.body_entered.connect(_on_detection_body_entered)
	detection_area.body_exited.connect(_on_detection_body_exited)
	health.damaged.connect(_on_took_damage)
	health.died.connect(_on_died)

func _setup_state_machine() -> void:
	var states = [
		_IDLE.new(), _PATROL.new(), _CHASE.new(),
		_ATTACK.new(), _RETREAT.new(), _HURT.new(), _DEATH.new()
	]
	for s in states:
		fsm.add_child(s)
	fsm.setup(self)
	fsm.start(_ES.StateType.IDLE)

func _process(delta: float) -> void:
	if GameManager.is_transitioning:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	_attack_cooldown_timer -= delta
	_update_animation()

func _on_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_ref = body
		if fsm.current_state and fsm.current_state.state_type in [_ES.StateType.IDLE, _ES.StateType.PATROL]:
			fsm.queue_transition(_ES.StateType.CHASE)

func _on_detection_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_ref = null

func _on_took_damage(amount: int, knockback_dir: Vector2) -> void:
	if health.is_dead:
		return
	velocity = knockback_dir
	fsm.force_transition(_ES.StateType.HURT)

func _on_died() -> void:
	fsm.force_transition(_ES.StateType.DEATH)

func update_facing(dir: Vector2) -> void:
	if dir.length_squared() > 0.001:
		_facing_dir = dir.normalized()

func position_hitbox(dir: Vector2) -> void:
	var shape = hitbox.get_node("CollisionShape2D") as CollisionShape2D
	if not shape:
		return
	if abs(dir.x) > abs(dir.y):
		shape.position = Vector2(20.0 if dir.x > 0 else -20.0, 0)
	else:
		shape.position = Vector2(0, 20.0 if dir.y > 0 else -20.0)

func get_facing_cardinal() -> String:
	if abs(_facing_dir.x) > abs(_facing_dir.y):
		return "right" if _facing_dir.x > 0 else "left"
	return "down" if _facing_dir.y > 0 else "up"

func _update_animation() -> void:
	if not animated_sprite:
		return
	var s = fsm.current_state.state_type if fsm.current_state else _ES.StateType.IDLE
	var card = get_facing_cardinal()
	match s:
		_ES.StateType.IDLE, _ES.StateType.PATROL:
			_play_anim("walk", card)
		_ES.StateType.CHASE:
			_play_anim("walk", card)
		_ES.StateType.ATTACK:
			_play_anim("attack", card)
		_ES.StateType.HURT:
			_play_anim("hurt", card)
		_ES.StateType.DEATH:
			_play_anim("death", card)

func _play_anim(base: String, card: String) -> void:
	var anim = "%s_%s" % [base, card]
	if animated_sprite.animation != anim:
		animated_sprite.animation = anim
		animated_sprite.play()
