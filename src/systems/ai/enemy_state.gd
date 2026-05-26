extends Node
class_name EnemyState

enum StateType { IDLE, PATROL, CHASE, ATTACK, RETREAT, HURT, DEATH }

var state_type: StateType : set = _set_type
var fsm
var enemy
var _active: bool = false

func _set_type(_v: StateType) -> void:
	state_type = _v

func setup(machine, controller) -> void:
	fsm = machine
	enemy = controller

func enter() -> void:
	_active = true

func exit() -> void:
	_active = false

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func is_active() -> bool:
	return _active

func can_transition_to(_target: StateType) -> bool:
	return _active
