@tool
extends Node2D

## Generic enemy spawner that spawns enemies up to a maximum count.
## Shows spawn area in editor.

@export var enemy_scene: PackedScene
@export var max_enemies: int = 5
@export var spawn_interval: float = 3.0
@export var spawn_area_min: Vector2 = Vector2(-100, -50):
	set(v):
		spawn_area_min = v
		queue_redraw()
@export var spawn_area_max: Vector2 = Vector2(100, 50):
	set(v):
		spawn_area_max = v
		queue_redraw()
@export var spawn_area_color: Color = Color(1, 0, 0, 0.3)

var _spawn_timer: float = 0.0
var _spawned_enemies: Array[Node] = []


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	# Clean up dead enemies from tracking array
	_spawned_enemies = _spawned_enemies.filter(func(e): return is_instance_valid(e))

	# Check if we can spawn
	if _spawned_enemies.size() >= max_enemies:
		return

	_spawn_timer += delta
	if _spawn_timer >= spawn_interval:
		_spawn_timer = 0.0
		_spawn_enemy()


func _spawn_enemy() -> void:
	if not enemy_scene:
		return

	var enemy := enemy_scene.instantiate()
	var spawn_x := randf_range(spawn_area_min.x, spawn_area_max.x)
	var spawn_y := randf_range(spawn_area_min.y, spawn_area_max.y)
	enemy.global_position = global_position + Vector2(spawn_x, spawn_y)

	get_tree().current_scene.add_child(enemy)
	_spawned_enemies.append(enemy)


func get_enemy_count() -> int:
	_spawned_enemies = _spawned_enemies.filter(func(e): return is_instance_valid(e))
	return _spawned_enemies.size()


func _draw() -> void:
	# Only draw in editor
	if not Engine.is_editor_hint():
		return

	# Draw spawn area rectangle
	var rect := Rect2(spawn_area_min, spawn_area_max - spawn_area_min)
	draw_rect(rect, spawn_area_color)
	draw_rect(rect, Color(1, 0, 0, 0.8), false, 2.0)

	# Draw center marker
	draw_circle(Vector2.ZERO, 5, Color.RED)
	draw_line(Vector2(-10, 0), Vector2(10, 0), Color.RED, 2.0)
	draw_line(Vector2(0, -10), Vector2(0, 10), Color.RED, 2.0)
