extends GutTest

var player: CharacterBody2D
var player_scene: PackedScene


func before_all() -> void:
	player_scene = load("res://scenes/player.tscn")


func before_each() -> void:
	player = player_scene.instantiate()
	add_child(player)
	# Wait for _ready to complete
	await get_tree().process_frame


func after_each() -> void:
	if player:
		player.queue_free()
		player = null


func test_serialize_returns_dictionary() -> void:
	var data = player.serialize()
	assert_typeof(data, TYPE_DICTIONARY)


func test_serialize_contains_position_x() -> void:
	var data = player.serialize()
	assert_true(data.has("position_x"), "Should have position_x")


func test_serialize_contains_position_y() -> void:
	var data = player.serialize()
	assert_true(data.has("position_y"), "Should have position_y")


func test_serialize_contains_velocity_x() -> void:
	var data = player.serialize()
	assert_true(data.has("velocity_x"), "Should have velocity_x")


func test_serialize_contains_velocity_y() -> void:
	var data = player.serialize()
	assert_true(data.has("velocity_y"), "Should have velocity_y")


func test_serialize_contains_flip_h() -> void:
	var data = player.serialize()
	assert_true(data.has("flip_h"), "Should have flip_h")


func test_deserialize_restores_position_x() -> void:
	var test_data := {
		"position_x": 100.0,
		"position_y": 200.0,
		"velocity_x": 0.0,
		"velocity_y": 0.0,
		"flip_h": false
	}
	player.deserialize(test_data)
	assert_eq(player.position.x, 100.0)


func test_deserialize_restores_position_y() -> void:
	var test_data := {
		"position_x": 100.0,
		"position_y": 200.0,
		"velocity_x": 0.0,
		"velocity_y": 0.0,
		"flip_h": false
	}
	player.deserialize(test_data)
	assert_eq(player.position.y, 200.0)


func test_deserialize_restores_velocity() -> void:
	var test_data := {
		"position_x": 0.0,
		"position_y": 0.0,
		"velocity_x": 50.0,
		"velocity_y": -100.0,
		"flip_h": false
	}
	player.deserialize(test_data)
	assert_eq(player.velocity.x, 50.0)
	assert_eq(player.velocity.y, -100.0)


func test_serialize_then_deserialize_roundtrip() -> void:
	player.position = Vector2(150, 250)
	player.velocity = Vector2(75, -50)

	var data = player.serialize()

	# Reset player state
	player.position = Vector2.ZERO
	player.velocity = Vector2.ZERO

	player.deserialize(data)

	assert_eq(player.position.x, 150.0)
	assert_eq(player.position.y, 250.0)
	assert_eq(player.velocity.x, 75.0)
	assert_eq(player.velocity.y, -50.0)
