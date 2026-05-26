extends Node
class_name HitPause

static func pause(duration: float = 0.08, scale_factor: float = 0.0) -> void:
	if duration <= 0.0:
		return
	var tree = Engine.get_main_loop()
	tree.time_scale = scale_factor
	await tree.create_timer(duration, true, false).timeout
	tree.time_scale = 1.0
