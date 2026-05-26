extends Node
class_name CameraShake

static func shake(intensity: float = 4.0, duration: float = 0.2) -> void:
	var cam = _get_active_camera()
	if not cam:
		return
	var orig = cam.offset
	var elapsed = 0.0
	var tween = cam.create_tween()
	while elapsed < duration:
		var decay = 1.0 - (elapsed / duration)
		var x = randf_range(-1.0, 1.0) * intensity * decay
		var y = randf_range(-1.0, 1.0) * intensity * decay
		tween.tween_property(cam, "offset", orig + Vector2(x, y), 0.033)
		elapsed += 0.033
		await cam.get_tree().create_timer(0.033).timeout
	tween.tween_property(cam, "offset", orig, 0.05)

static func _get_active_camera() -> Camera2D:
	var wm = GameManager.world_map_scene
	if wm and is_instance_valid(wm):
		return wm.get_node("Camera2D") as Camera2D
	return null
