extends GutTest


func before_each() -> void:
	GameManager.reset()


func after_each() -> void:
	GameManager.reset()


func test_initial_state() -> void:
	assert_eq(GameManager.coins, 0, "Coins should start at 0")
	assert_eq(GameManager.lives, 3, "Lives should start at 3")
	assert_eq(GameManager.level_active, false, "Level should not be active initially")


func test_collect_coin_increments_count() -> void:
	GameManager.collect_coin("")
	assert_eq(GameManager.coins, 1, "Coin count should be 1 after collecting")


func test_collect_coin_with_path_tracks_path() -> void:
	GameManager.collect_coin("/root/Level/Coins/Coin1")
	assert_true("/root/Level/Coins/Coin1" in GameManager._collected_coins)


func test_collect_multiple_coins_tracks_all_paths() -> void:
	GameManager.collect_coin("/root/Level/Coins/Coin1")
	GameManager.collect_coin("/root/Level/Coins/Coin2")
	GameManager.collect_coin("/root/Level/Coins/Coin3")
	assert_eq(GameManager._collected_coins.size(), 3)
	assert_eq(GameManager.coins, 3)


func test_collect_same_coin_twice_only_tracked_once() -> void:
	GameManager.collect_coin("/root/Level/Coins/Coin1")
	GameManager.collect_coin("/root/Level/Coins/Coin1")
	var count = 0
	for path in GameManager._collected_coins:
		if path == "/root/Level/Coins/Coin1":
			count += 1
	assert_eq(count, 1, "Same coin path should only be tracked once")
	# But coins count still increases (for scoring purposes)
	assert_eq(GameManager.coins, 2)


func test_lose_live_decrements() -> void:
	GameManager.lose_live()
	assert_eq(GameManager.lives, 2, "Lives should be 2 after losing one")


func test_reset_clears_state() -> void:
	GameManager.coins = 5
	GameManager.lives = 1
	GameManager._collected_coins.append("/root/Test/Coin")
	GameManager.level_active = true
	GameManager.reset()
	assert_eq(GameManager.coins, 0)
	assert_eq(GameManager.lives, 3)
	assert_eq(GameManager._collected_coins.size(), 0)
	assert_eq(GameManager.level_active, false)


func test_set_lives() -> void:
	GameManager.set_lives(5)
	assert_eq(GameManager.lives, 5)


func test_has_save_file_returns_false_when_no_file() -> void:
	# Clean up any existing save file
	if FileAccess.file_exists(GameManager.SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(GameManager.SAVE_PATH))
	assert_false(GameManager.has_save_file())
