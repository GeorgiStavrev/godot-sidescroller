extends Control

@onready var start_button: Button = $VBoxContainer/StartButton


func _ready() -> void:
	start_button.grab_focus()


func _on_start_pressed() -> void:
	GameManager.reset()
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()
