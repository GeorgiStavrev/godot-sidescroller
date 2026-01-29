extends GutTest


func before_each() -> void:
	GameManager.reset()


func after_each() -> void:
	GameManager.reset()
	# Clean up any test save files
	if FileAccess.file_exists(GameManager.SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(GameManager.SAVE_PATH))


func test_collected_coins_included_in_save_data() -> void:
	GameManager.collect_coin("/root/Level/Coins/Coin1")
	GameManager.collect_coin("/root/Level/Coins/Coin2")
	GameManager.current_level_path = "res://scenes/level_1.tscn"
	GameManager._captured_node_data = []

	var result = GameManager.save_game()
	assert_true(result, "Save should succeed")

	# Read the save file and verify collected_coins is present
	var file = FileAccess.open(GameManager.SAVE_PATH, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	json.parse(json_string)
	var data: Dictionary = json.data

	assert_true(data.has("collected_coins"), "Save should have collected_coins")
	assert_eq(data.collected_coins.size(), 2, "Should have 2 collected coins")
	assert_true("/root/Level/Coins/Coin1" in data.collected_coins)
	assert_true("/root/Level/Coins/Coin2" in data.collected_coins)


func test_save_preserves_coin_count() -> void:
	GameManager.coins = 5
	GameManager.current_level_path = "res://scenes/level_1.tscn"
	GameManager._captured_node_data = []

	GameManager.save_game()

	var file = FileAccess.open(GameManager.SAVE_PATH, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	json.parse(json_string)
	var data: Dictionary = json.data

	assert_eq(data.coins, 5)


func test_save_preserves_lives() -> void:
	GameManager.lives = 2
	GameManager.current_level_path = "res://scenes/level_1.tscn"
	GameManager._captured_node_data = []

	GameManager.save_game()

	var file = FileAccess.open(GameManager.SAVE_PATH, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	json.parse(json_string)
	var data: Dictionary = json.data

	assert_eq(data.lives, 2)


func test_save_preserves_level_path() -> void:
	GameManager.current_level_path = "res://scenes/level_1.tscn"
	GameManager._captured_node_data = []

	GameManager.save_game()

	var file = FileAccess.open(GameManager.SAVE_PATH, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	json.parse(json_string)
	var data: Dictionary = json.data

	assert_eq(data.level_path, "res://scenes/level_1.tscn")
