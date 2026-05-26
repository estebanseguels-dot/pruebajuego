extends Node

const SETTINGS_PATH := "user://settings.cfg"
const SECTION := "text_box"

var frame_style: int = 0
var bg_style: int = 0

var frame_names: Array[String] = ["Clásico", "Ornamentado", "Minimal"]
var bg_names: Array[String] = ["Oscuro", "Papel", "Transparente"]

func _ready() -> void:
	load_settings()

func load_settings() -> void:
	var cfg = ConfigFile.new()
	var err = cfg.load(SETTINGS_PATH)
	if err != OK:
		set_defaults()
		return
	frame_style = cfg.get_value(SECTION, "frame_style", 0)
	bg_style = cfg.get_value(SECTION, "bg_style", 0)

func save_settings() -> void:
	var cfg = ConfigFile.new()
	cfg.set_value(SECTION, "frame_style", frame_style)
	cfg.set_value(SECTION, "bg_style", bg_style)
	cfg.save(SETTINGS_PATH)

func set_defaults() -> void:
	frame_style = 0
	bg_style = 0

func get_frame_name() -> String:
	return frame_names[frame_style] if frame_style >= 0 and frame_style < frame_names.size() else "?"

func get_bg_name() -> String:
	return bg_names[bg_style] if bg_style >= 0 and bg_style < bg_names.size() else "?"
