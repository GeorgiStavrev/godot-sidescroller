extends Node

# Game Manager - Singleton to track game state
signal coin_collected(amount: int)
signal coins_changed(new_total: int)
signal lives_changed(new_total: int)

var coins: int = 0:
	set(value):
		coins = value
		coins_changed.emit(coins)

var lives: int = 3:
	set(value):
		lives = value
		lives_changed.emit(lives)


func _ready() -> void:
	reset()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		var current_scene := get_tree().current_scene.scene_file_path
		if current_scene != "res://scenes/main_menu.tscn":
			reset()
			get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func set_lives(_lives: int) -> void:
	self.lives = _lives


func lose_live() -> void:
	self.lives -= 1


func collect_coin() -> void:
	coins += 1
	coin_collected.emit(1)


func reset() -> void:
	coins = 0
	lives = 3
