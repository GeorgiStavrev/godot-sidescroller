extends Control

@onready var start_button: Button = $VBoxContainer/StartButton
@onready var continue_button: Button = $VBoxContainer/ContinueButton
@onready var save_button: Button = $VBoxContainer/SaveButton
@onready var load_button: Button = $VBoxContainer/LoadButton
@onready var exit_button: Button = $VBoxContainer/ExitButton


func _ready() -> void:
	_update_button_visibility()
	_update_focus_neighbors()

	if GameManager.level_active:
		continue_button.grab_focus()
	else:
		start_button.grab_focus()


func _update_button_visibility() -> void:
	# Continue and Save only show if a level is active
	continue_button.visible = GameManager.level_active
	save_button.visible = GameManager.level_active

	# Load only shows if there's a save file
	load_button.visible = GameManager.has_save_file()


func _update_focus_neighbors() -> void:
	# Build list of visible buttons in order
	var visible_buttons: Array[Button] = []
	for button in [start_button, continue_button, save_button, load_button, exit_button]:
		if button.visible:
			visible_buttons.append(button)

	# Set focus neighbors for wrapping navigation
	for i in visible_buttons.size():
		var button := visible_buttons[i]
		var prev_button := visible_buttons[
			(i - 1 + visible_buttons.size()) % visible_buttons.size()
		]
		var next_button := visible_buttons[(i + 1) % visible_buttons.size()]
		button.focus_neighbor_top = button.get_path_to(prev_button)
		button.focus_neighbor_bottom = button.get_path_to(next_button)


func _on_start_pressed() -> void:
	GameManager.reset()
	GameManager.level_active = true
	var start_scene = "res://scenes/level_1.tscn"
	GameManager.current_level_path = start_scene
	get_tree().change_scene_to_file(start_scene)


func _on_continue_pressed() -> void:
	if GameManager.current_level_path != "":
		get_tree().change_scene_to_file(GameManager.current_level_path)


func _on_save_pressed() -> void:
	if GameManager.save_game():
		print("Game saved!")
		_update_button_visibility()
		_update_focus_neighbors()


func _on_load_pressed() -> void:
	GameManager.load_game()


func _on_exit_pressed() -> void:
	get_tree().quit()
