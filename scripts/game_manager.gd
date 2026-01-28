extends Node

# Game Manager - Singleton to track game state
signal coin_collected(amount: int)
signal coins_changed(new_total: int)
signal lives_changed(new_total: int)

const SAVE_PATH := "user://savegame.json"

var coins: int = 0:
	set(value):
		coins = value
		coins_changed.emit(coins)

var lives: int = 3:
	set(value):
		lives = value
		lives_changed.emit(lives)

var level_active: bool = false
var current_level_path: String = ""
var _pending_load_data: Array = []
var _captured_node_data: Array = []


func _ready() -> void:
	reset()


func _process(_delta: float) -> void:
	# Apply pending load data once saveable nodes are ready
	if not _pending_load_data.is_empty():
		var saveable_nodes := get_tree().get_nodes_in_group("saveable")
		if saveable_nodes.size() > 0:
			_apply_node_save_data()

	if Input.is_action_just_pressed("menu"):
		var current_scene := get_tree().current_scene.scene_file_path
		if current_scene != "res://scenes/main_menu.tscn":
			level_active = true
			current_level_path = current_scene
			# Capture node data while still in the level
			_captured_node_data = _collect_node_data()
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
	level_active = false
	current_level_path = ""
	_captured_node_data = []


func _collect_node_data() -> Array:
	var nodes_data: Array = []
	for node in get_tree().get_nodes_in_group("saveable"):
		if node.has_method("serialize"):
			nodes_data.append({
				"name": node.name,
				"data": node.serialize()
			})
		else:
			push_warning("Node '%s' in 'saveable' group missing serialize()" % node.name)
	return nodes_data


func save_game() -> bool:
	var save_data := {
		"coins": coins,
		"lives": lives,
		"level_path": current_level_path,
		"nodes": _captured_node_data
	}

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open save file: %s" % FileAccess.get_open_error())
		return false

	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()
	return true


func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		push_error("No save file found")
		return false

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("Failed to open save file: %s" % FileAccess.get_open_error())
		return false

	var json_string := file.get_as_text()
	file.close()

	var json := JSON.new()
	var parse_result := json.parse(json_string)
	if parse_result != OK:
		push_error("Failed to parse save file: %s" % json.get_error_message())
		return false

	var save_data: Dictionary = json.data

	# Store data to apply after scene loads
	coins = int(save_data.get("coins", 0))
	lives = int(save_data.get("lives", 3))
	current_level_path = save_data.get("level_path", "")
	level_active = true

	# Load the level and apply node data
	if current_level_path != "":
		# Store data to apply after scene loads (will be applied in _process)
		_pending_load_data = save_data.nodes
		get_tree().change_scene_to_file(current_level_path)

	return true


func _apply_node_save_data() -> void:
	# Build a lookup of saved data by node name
	var data_by_name := {}
	for node_data in _pending_load_data:
		data_by_name[node_data.name] = node_data.data

	# Apply to all saveable nodes
	for node in get_tree().get_nodes_in_group("saveable"):
		if node.name in data_by_name and node.has_method("deserialize"):
			node.deserialize(data_by_name[node.name])

	_pending_load_data = []


func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_PATH)
