extends Control

@onready var timer: Timer = $Timer


func _ready() -> void:
	timer.start()


func _on_timer_timeout() -> void:
	GameManager.reset()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
