extends Control
class_name OptionsMenu

@onready var frame_label = $Panel/Body/FrameRow/Value
@onready var bg_label = $Panel/Body/BgRow/Value
@onready var preview_frame = $Panel/Body/Preview/FrameBg
@onready var preview_bg = $Panel/Body/Preview/TextBoxBg

func populate() -> void:
	_update_labels()
	_update_preview()

func _on_frame_prev_pressed() -> void:
	TextBoxConfig.frame_style = posmod(TextBoxConfig.frame_style - 1, TextBoxConfig.frame_names.size())
	TextBoxConfig.save_settings()
	_update_labels()
	_update_preview()

func _on_frame_next_pressed() -> void:
	TextBoxConfig.frame_style = posmod(TextBoxConfig.frame_style + 1, TextBoxConfig.frame_names.size())
	TextBoxConfig.save_settings()
	_update_labels()
	_update_preview()

func _on_bg_prev_pressed() -> void:
	TextBoxConfig.bg_style = posmod(TextBoxConfig.bg_style - 1, TextBoxConfig.bg_names.size())
	TextBoxConfig.save_settings()
	_update_labels()
	_update_preview()

func _on_bg_next_pressed() -> void:
	TextBoxConfig.bg_style = posmod(TextBoxConfig.bg_style + 1, TextBoxConfig.bg_names.size())
	TextBoxConfig.save_settings()
	_update_labels()
	_update_preview()

func _update_labels() -> void:
	frame_label.text = TextBoxConfig.get_frame_name()
	bg_label.text = TextBoxConfig.get_bg_name()

func _update_preview() -> void:
	var f = TextBoxConfig.frame_style
	var b = TextBoxConfig.bg_style
	var sb = StyleBoxFlat.new()

	match f:
		0:
			sb.bg_color = Color(0.3, 0.3, 0.35)
			sb.set_border_width_all(2)
			sb.border_color = Color(0.7, 0.7, 0.8)
		1:
			sb.bg_color = Color(0.25, 0.2, 0.3)
			sb.set_border_width_all(4)
			sb.border_color = Color(0.9, 0.75, 0.4)
		2:
			sb.bg_color = Color(0.2, 0.2, 0.2)
			sb.set_border_width_all(1)
			sb.border_color = Color(0.5, 0.5, 0.5)

	preview_frame.add_theme_stylebox_override("panel", sb)

	match b:
		0:
			preview_bg.color = Color(0.08, 0.08, 0.12, 0.92)
		1:
			preview_bg.color = Color(0.85, 0.8, 0.7, 0.95)
		2:
			preview_bg.color = Color(0.0, 0.0, 0.0, 0.4)

func _on_back_pressed() -> void:
	hide()
