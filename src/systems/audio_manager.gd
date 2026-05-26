extends Node
class_name AudioManager

var _music_player: AudioStreamPlayer
var _sfx_player: AudioStreamPlayer
var _music_fade_tween: Tween

var music_volume: float = 0.8
var sfx_volume: float = 0.9
var is_music_muted: bool = false

func _ready() -> void:
	name = "AudioManager"
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Master"
	add_child(_music_player)

	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.bus = "Master"
	add_child(_sfx_player)

func play_music(stream: AudioStream, fade_duration: float = 1.0) -> void:
	if is_music_muted:
		return
	if _music_player.stream == stream and _music_player.playing:
		return

	_music_player.stream = stream
	_music_player.volume_db = -80
	_music_player.play()
	_fade_tween(_music_player, -80.0, linear_to_db(music_volume), fade_duration)

func _fade_tween(player: AudioStreamPlayer, from_db: float, to_db: float, duration: float) -> void:
	if _music_fade_tween:
		_music_fade_tween.kill()
	_music_fade_tween = create_tween()
	_music_fade_tween.tween_property(player, "volume_db", to_db, duration)

func stop_music(fade_duration: float = 0.5) -> void:
	if not _music_player.playing:
		return
	_fade_tween(_music_player, linear_to_db(music_volume), -80.0, fade_duration)
	await get_tree().create_timer(fade_duration).timeout
	_music_player.stop()

func play_sfx(sfx: AudioStream) -> void:
	if is_music_muted or sfx_volume == 0:
		return
	_sfx_player.stream = sfx
	_sfx_player.play()

func set_music_volume(vol: float) -> void:
	music_volume = clamp(vol, 0.0, 1.0)
	if _music_player.playing:
		_music_player.volume_db = linear_to_db(music_volume)

func set_sfx_volume(vol: float) -> void:
	sfx_volume = clamp(vol, 0.0, 1.0)

func mute_music(mute: bool) -> void:
	is_music_muted = mute
	_music_player.volume_db = linear_to_db(0.0 if mute else music_volume)
