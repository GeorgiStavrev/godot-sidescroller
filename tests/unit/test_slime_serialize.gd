extends GutTest

var slime: Node2D
var slime_scene: PackedScene


func before_all() -> void:
	slime_scene = load("res://scenes/slime.tscn")


func before_each() -> void:
	slime = slime_scene.instantiate()
	add_child(slime)
	await get_tree().process_frame


func after_each() -> void:
	if slime:
		slime.queue_free()
		slime = null


func test_serialize_returns_dictionary() -> void:
	var data = slime.serialize()
	assert_typeof(data, TYPE_DICTIONARY)


func test_serialize_contains_position_x() -> void:
	var data = slime.serialize()
	assert_true(data.has("position_x"))


func test_serialize_contains_position_y() -> void:
	var data = slime.serialize()
	assert_true(data.has("position_y"))


func test_serialize_contains_direction() -> void:
	var data = slime.serialize()
	assert_true(data.has("direction"))


func test_deserialize_restores_position() -> void:
	var test_data := {"position_x": 300.0, "position_y": 400.0, "direction": 1}
	slime.deserialize(test_data)

	assert_eq(slime.position.x, 300.0)
	assert_eq(slime.position.y, 400.0)


func test_deserialize_restores_direction() -> void:
	var test_data := {"position_x": 0.0, "position_y": 0.0, "direction": -1}
	slime.deserialize(test_data)
	assert_eq(slime.direction, -1)


func test_direction_negative_flips_sprite() -> void:
	slime.deserialize({"position_x": 0, "position_y": 0, "direction": -1})
	assert_true(slime.animated_sprite.flip_h, "Sprite should flip when direction is -1")


func test_direction_positive_unflips_sprite() -> void:
	slime.deserialize({"position_x": 0, "position_y": 0, "direction": 1})
	assert_false(slime.animated_sprite.flip_h, "Sprite should not flip when direction is 1")


func test_serialize_deserialize_roundtrip() -> void:
	slime.position = Vector2(500, 600)
	slime.direction = -1

	var data = slime.serialize()

	slime.position = Vector2.ZERO
	slime.direction = 1

	slime.deserialize(data)

	assert_eq(slime.position.x, 500.0)
	assert_eq(slime.position.y, 600.0)
	assert_eq(slime.direction, -1)
