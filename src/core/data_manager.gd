extends Node

const SAVE_PATH := "user://save_game.json"

func save_game() -> bool:
	var data = {
		"player": GameManager.player_data.duplicate(),
		"inventory": GameManager.inventory.duplicate(),
		"equipment": GameManager.equipment.duplicate()
	}

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	return true

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return false

	var json = JSON.new()
	var err = json.parse(file.get_as_text())
	file.close()
	if err != OK:
		return false

	var data = json.data as Dictionary
	GameManager.player_data = data.get("player", GameManager.player_data)
	GameManager.inventory = data.get("inventory", {})
	GameManager.equipment = data.get("equipment", {"weapon": null, "armor": null, "accessory": null})
	return true

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func delete_save() -> bool:
	if not has_save():
		return false
	DirAccess.remove_absolute(SAVE_PATH)
	return true
