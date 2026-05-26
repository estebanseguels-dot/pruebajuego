extends CanvasLayer
class_name CharacterCreator

enum Step { GENDER, PET, CUSTOMIZE }

var _current_step: Step = Step.GENDER

var _gender: String = "male"
var _pet: String = "dog"
var _hair_index: int = 0
var _hair_color_index: int = 0
var _skin_color_index: int = 0

const HAIR_STYLES: Array[String] = ["Despeinado", "Corto", "Largo", "Pompadour"]
const HAIR_COLORS: Array[Color] = [
	Color(0.95, 0.85, 0.4), Color(0.3, 0.2, 0.1), Color(0.1, 0.1, 0.1),
	Color(0.7, 0.2, 0.1), Color(0.8, 0.6, 0.3), Color(0.9, 0.5, 0.1)
]
const SKIN_COLORS: Array[Color] = [
	Color(0.95, 0.8, 0.65), Color(0.75, 0.55, 0.35), Color(0.5, 0.35, 0.2),
	Color(0.85, 0.7, 0.5), Color(0.6, 0.4, 0.25), Color(1.0, 0.9, 0.75)
]
const HAIR_COLOR_NAMES: Array[String] = ["Rubio", "Castaño", "Negro", "Pelirrojo", "Dorado", "Naranja"]
const SKIN_COLOR_NAMES: Array[String] = ["Claro", "Oscuro", "Moreno", "Trigueño", "Canela", "Marfil"]

func _ready() -> void:
	name = "CharacterCreator"
	_show_step(Step.GENDER)

func _show_step(step: Step) -> void:
	_current_step = step
	$GenderPanel.visible = step == Step.GENDER
	$PetPanel.visible = step == Step.PET
	$CustomizePanel.visible = step == Step.CUSTOMIZE
	_update_preview()

func _on_gender_male_pressed() -> void:
	_gender = "male"
	_show_step(Step.PET)

func _on_gender_female_pressed() -> void:
	_gender = "female"
	_show_step(Step.PET)

func _on_pet_dog_pressed() -> void:
	_pet = "dog"
	_show_step(Step.CUSTOMIZE)

func _on_pet_cat_pressed() -> void:
	_pet = "cat"
	_show_step(Step.CUSTOMIZE)

func _on_hair_prev_pressed() -> void:
	_hair_index = posmod(_hair_index - 1, HAIR_STYLES.size())
	_update_preview()

func _on_hair_next_pressed() -> void:
	_hair_index = posmod(_hair_index + 1, HAIR_STYLES.size())
	_update_preview()

func _on_hair_color_prev_pressed() -> void:
	_hair_color_index = posmod(_hair_color_index - 1, HAIR_COLORS.size())
	_update_preview()

func _on_hair_color_next_pressed() -> void:
	_hair_color_index = posmod(_hair_color_index + 1, HAIR_COLORS.size())
	_update_preview()

func _on_skin_prev_pressed() -> void:
	_skin_color_index = posmod(_skin_color_index - 1, SKIN_COLORS.size())
	_update_preview()

func _on_skin_next_pressed() -> void:
	_skin_color_index = posmod(_skin_color_index + 1, SKIN_COLORS.size())
	_update_preview()

func _on_confirm_pressed() -> void:
	var hair_col = HAIR_COLORS[_hair_color_index]
	var skin_col = SKIN_COLORS[_skin_color_index]
	GameManager.player_data["gender"] = _gender
	GameManager.player_data["pet"] = _pet
	GameManager.player_data["hair_style"] = HAIR_STYLES[_hair_index]
	GameManager.player_data["hair_color"] = [hair_col.r, hair_col.g, hair_col.b]
	GameManager.player_data["skin_color"] = [skin_col.r, skin_col.g, skin_col.b]
	SceneLoader.load_scene("res://src/scenes/cutscene/intro_cutscene.tscn", SceneLoader.TransitionType.FADE)

func _update_preview() -> void:
	if not is_node_ready():
		return
	var hair_col = HAIR_COLORS[_hair_color_index]
	var skin_col = SKIN_COLORS[_skin_color_index]
	$CustomizePanel/Controls/HairRow/HairStyleLabel.text = HAIR_STYLES[_hair_index]
	$CustomizePanel/Controls/HairRow/HairSwatch.color = hair_col
	$CustomizePanel/Controls/HairColorRow/HairColorLabel.text = HAIR_COLOR_NAMES[_hair_color_index]
	$CustomizePanel/Controls/HairColorRow/HairColorSwatch.color = hair_col
	$CustomizePanel/Controls/SkinRow/SkinColorLabel.text = SKIN_COLOR_NAMES[_skin_color_index]
	$CustomizePanel/Controls/SkinRow/SkinSwatch.color = skin_col
