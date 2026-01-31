extends GutTest

var platform: AnimatableBody2D
var platform_scene: PackedScene


func before_all() -> void:
	platform_scene = load("res://scenes/self_directed_platform.tscn")


func before_each() -> void:
	platform = platform_scene.instantiate()
	add_child(platform)
	await get_tree().process_frame


func after_each() -> void:
	if platform:
		platform.queue_free()
		platform = null


func test_serialize_returns_dictionary() -> void:
	var data = platform.serialize()
	assert_typeof(data, TYPE_DICTIONARY)


func test_serialize_contains_position_x() -> void:
	var data = platform.serialize()
	assert_true(data.has("position_x"))


func test_serialize_contains_position_y() -> void:
	var data = platform.serialize()
	assert_true(data.has("position_y"))


func test_serialize_contains_direction() -> void:
	var data = platform.serialize()
	assert_true(data.has("direction"))


func test_deserialize_restores_position() -> void:
	var test_data := {"position_x": 500.0, "position_y": 100.0, "direction": 1}
	platform.deserialize(test_data)

	assert_eq(platform.position.x, 500.0)
	assert_eq(platform.position.y, 100.0)


func test_deserialize_restores_direction() -> void:
	var test_data := {"position_x": 0.0, "position_y": 0.0, "direction": 1}
	platform.deserialize(test_data)
	assert_eq(platform.direction, 1)


func test_serialize_deserialize_roundtrip() -> void:
	# Use deserialize to set position (works with AnimatableBody2D sync_to_physics)
	platform.deserialize({"position_x": 250.0, "position_y": 350.0, "direction": -1})

	var data = platform.serialize()
	platform.deserialize({"position_x": 0.0, "position_y": 0.0, "direction": 1})

	platform.deserialize(data)

	assert_eq(platform.position.x, 250.0)
	assert_eq(platform.position.y, 350.0)
	assert_eq(platform.direction, -1)
