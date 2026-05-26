extends Node
class_name VFXManager

enum EffectType {
	SLASH,
	HIT_SPARK,
	DUST,
	CHARGE_AURA,
	CRITICAL_HIT,
	DEATH_DISSOLVE,
	EXPLOSION
}

const EFFECT_DATA := {
	EffectType.SLASH: {"frames": 4, "frame_duration": 0.06, "color": Color.WHITE},
	EffectType.HIT_SPARK: {"frames": 3, "frame_duration": 0.05, "color": Color.YELLOW},
	EffectType.DUST: {"frames": 3, "frame_duration": 0.08, "color": Color.TAN},
	EffectType.CHARGE_AURA: {"frames": 4, "frame_duration": 0.1, "color": Color.CYAN},
	EffectType.CRITICAL_HIT: {"frames": 5, "frame_duration": 0.07, "color": Color.ORANGE_RED},
	EffectType.DEATH_DISSOLVE: {"frames": 6, "frame_duration": 0.07, "color": Color.PURPLE},
	EffectType.EXPLOSION: {"frames": 6, "frame_duration": 0.06, "color": Color.ORANGE}
}

static func play(type: EffectType, position: Vector2, parent: Node = null) -> void:
	var fx = Node2D.new()
	fx.global_position = position
	fx.z_index = 50

	var sprite = Sprite2D.new()
	sprite.texture = _generate_texture(type)
	sprite.modulate = EFFECT_DATA[type]["color"]
	sprite.centered = true
	fx.add_child(sprite)
	sprite.position = Vector2.ZERO

	if parent:
		parent.add_child(fx)
	else:
		var wm = GameManager.world_map_scene
		if wm:
			wm.add_child(fx)
		else:
			Engine.get_main_loop().root.add_child(fx)

	var frames = EFFECT_DATA[type]["frames"]
	var frame_time = EFFECT_DATA[type]["frame_duration"]
	_animate_sprite(sprite, frames, frame_time, fx)

static func _animate_sprite(sprite: Sprite2D, frames: int, frame_time: float, fx: Node2D) -> void:
	var tween = fx.create_tween()
	tween.set_parallel(true)
	for i in frames:
		var scale_val = 1.0 + (float(i) / float(frames)) * 0.5
		tween.tween_property(sprite, "scale", Vector2(scale_val, scale_val), frame_time)
	tween.tween_property(sprite, "modulate:a", 0.0, frame_time * frames)
	await tween.finished
	fx.queue_free()

static func _generate_texture(_type: EffectType) -> Texture2D:
	var image = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	var tex = ImageTexture.create_from_image(image)
	return tex

static func play_slash(pos: Vector2, parent: Node = null) -> void:
	play(EffectType.SLASH, pos, parent)

static func play_spark(pos: Vector2, parent: Node = null) -> void:
	play(EffectType.HIT_SPARK, pos, parent)

static func play_dust(pos: Vector2, parent: Node = null) -> void:
	play(EffectType.DUST, pos, parent)

static func play_charge_aura(pos: Vector2, parent: Node = null) -> void:
	play(EffectType.CHARGE_AURA, pos, parent)

static func play_critical(pos: Vector2, parent: Node = null) -> void:
	play(EffectType.CRITICAL_HIT, pos, parent)

static func play_death(pos: Vector2, parent: Node = null) -> void:
	play(EffectType.DEATH_DISSOLVE, pos, parent)

static func play_explosion(pos: Vector2, parent: Node = null) -> void:
	play(EffectType.EXPLOSION, pos, parent)
