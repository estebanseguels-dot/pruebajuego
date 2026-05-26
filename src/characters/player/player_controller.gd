extends CharacterBody2D
class_name PlayerController

const _PCC = preload("res://src/characters/player/player_combat_controller.gd")

enum MoveState { IDLE, WALK, RUN }

@export var speed: float = 100.0
@export var run_speed: float = 160.0
@export var acceleration: float = 500.0
@export var friction: float = 300.0

@onready var sprite = $Sprite2D
@onready var interaction_area = $InteractionArea
@onready var combat = $PlayerCombatController

var move_state: MoveState = MoveState.IDLE
var facing_direction: Vector2 = Vector2.DOWN
var _can_move: bool = true
var _current_speed: float

var _anim_timer: float = 0.0
var _anim_idx: int = 0

var _frames: Dictionary = {}

func _ready() -> void:
	name = "Player"
	_current_speed = speed
	combat.attack_state_changed.connect(_on_combat_state_changed)

	# Load all directional frames
	var dirs = ["right", "up", "down"]

	# Idle: 1 frame per direction
	for d in dirs:
		_frames["idle_" + d] = [load("res://assets/frames2/idle_" + d + "_00.png")]

	# Walk: 5 frames, missing index 2, duplicate index 1 for 2
	for d in dirs:
		var arr = []
		for i in [0, 1, 1, 3, 4, 5]:
			arr.append(load("res://assets/frames2/walk_" + d + "_" + str(i).pad_zeros(2) + ".png"))
		_frames["walk_" + d] = arr

	# Run: 4 frames
	for d in dirs:
		var arr = []
		for i in range(4):
			var tex = load("res://assets/frames2/run_" + d + "_" + str(i).pad_zeros(2) + ".png")
			if tex == null:
				tex = load("res://assets/frames2/run_right_" + str(i).pad_zeros(2) + ".png")
			arr.append(tex)
		_frames["run_" + d] = arr

	# Hurt: 4 frames per direction
	for d in dirs:
		var arr = []
		for i in range(4):
			arr.append(load("res://assets/frames2/hurt_" + d + "_" + str(i).pad_zeros(2) + ".png"))
		_frames["hurt_" + d] = arr

	_apply_idle()

func _get_dir_key() -> String:
	var ax = abs(facing_direction.x)
	var ay = abs(facing_direction.y)
	if ax > ay:
		return "right"
	elif ay > ax:
		return "down" if facing_direction.y > 0 else "up"
	else:
		return "right" if facing_direction.x > 0 else "up"

func _apply_idle():
	var dk = _get_dir_key()
	sprite.texture = _frames["idle_" + dk][0]

func _process(delta: float) -> void:
	sprite.flip_h = facing_direction.x < 0

	if GameManager.is_transitioning:
		velocity = Vector2.ZERO
		move_and_slide()
		_anim_timer = 0.0
		return

	var input_dir = Vector2.ZERO
	input_dir.x = Input.get_axis("ui_left", "ui_right")
	input_dir.y = Input.get_axis("ui_up", "ui_down")

	if input_dir != Vector2.ZERO:
		input_dir = input_dir.normalized()
		facing_direction = input_dir

	var is_moving = _can_move and input_dir != Vector2.ZERO

	if _can_move and input_dir != Vector2.ZERO:
		var is_run = Input.is_action_pressed("run") or combat.current_state == _PCC.AttackState.CHARGE
		_current_speed = run_speed if is_run else speed
		move_state = MoveState.RUN if is_run else MoveState.WALK
		velocity = velocity.move_toward(input_dir * _current_speed, acceleration * delta)
	elif _can_move:
		move_state = MoveState.IDLE
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	else:
		if combat.current_state == _PCC.AttackState.HURT:
			velocity = velocity.move_toward(Vector2.ZERO, friction * 3.0 * delta)
		else:
			velocity = Vector2.ZERO

	move_and_slide()

	var dk = _get_dir_key()

	if not _can_move and combat.current_state == _PCC.AttackState.HURT:
		_animate("hurt", dk, delta, 8.0)
	elif is_moving:
		var anim = "run" if move_state == MoveState.RUN else "walk"
		var speed_mul = 6.0 if move_state == MoveState.RUN else 4.0
		_animate(anim, dk, delta, speed_mul)
	else:
		_apply_idle()
		_anim_timer = 0.0

func _animate(anim: String, dir: String, delta: float, speed_mul: float):
	var key = anim + "_" + dir
	var frames = _frames.get(key)
	if frames == null or frames.size() == 0:
		return
	_anim_timer += delta * speed_mul
	var new_idx = int(_anim_timer) % frames.size()
	if new_idx != _anim_idx:
		_anim_idx = new_idx
		sprite.texture = frames[_anim_idx]

func _on_combat_state_changed(state) -> void:
	_anim_timer = 0.0
	_anim_idx = 0

func set_can_move(value: bool) -> void:
	_can_move = value
	if not value:
		velocity = Vector2.ZERO

func _on_body_entered(body: Node2D) -> void:
	pass

func get_facing_cardinal() -> String:
	return _get_dir_key()
