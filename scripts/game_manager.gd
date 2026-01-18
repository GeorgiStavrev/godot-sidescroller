extends Node

# Game Manager - Singleton to track game state
signal coin_collected(amount: int)
signal coins_changed(new_total: int)

var coins: int = 0:
	set(value):
		coins = value
		coins_changed.emit(coins)


func _ready() -> void:
	# Reset coins when the game manager is ready (scene loaded)
	reset()


func collect_coin() -> void:
	coins += 1
	coin_collected.emit(1)


func reset() -> void:
	coins = 0
