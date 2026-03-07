extends Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var arrow_spawn: Marker2D = $ArrowSpan
@onready var nocked_arrow: Sprite2D = $NockedArrow

const ARROW_SCENE = preload("res://scenes/Weapons/arrow.tscn")
const DRAW_OFFSET = 3.0  # How far back the arrow moves when drawn (in pixels)

# Charging configuration
const MAX_CHARGE_TIME = 1.5  # Seconds to reach full charge
const AUTO_RELEASE_TIME = 2.0  # Seconds before forced release
const CHARGE_WARNING_RATIO = 0.8  # When to start warning (ratio of auto-release time)

var _nocked_arrow_base_x: float = 0.0
var _is_drawn: bool = false
var _is_reloading: bool = false

@export var reload_time: float = 0.5  # Base reload time in seconds
@export var reload_speed: float = 1.0  # Multiplier (higher = faster)


func _ready() -> void:
	if sprite:
		sprite.animation_finished.connect(_on_animation_finished)
	if nocked_arrow:
		_nocked_arrow_base_x = abs(nocked_arrow.position.x)


func is_ready() -> bool:
	return not _is_reloading


func supports_charging() -> bool:
	return true


func get_charge_info(charge_time: float) -> ChargeInfo:
	var power := clampf(charge_time / MAX_CHARGE_TIME, 0.0, 1.0)
	var display_ratio := power  # For bow, display matches power
	var should_release := charge_time >= AUTO_RELEASE_TIME

	# Calculate warning progress (0.0 = no warning, 1.0 = about to release)
	var release_ratio := charge_time / AUTO_RELEASE_TIME
	var warning_progress := 0.0
	if release_ratio >= CHARGE_WARNING_RATIO:
		warning_progress = (release_ratio - CHARGE_WARNING_RATIO) / (1.0 - CHARGE_WARNING_RATIO)

	return ChargeInfo.create(
		power, display_ratio, should_release, clampf(warning_progress, 0.0, 1.0)
	)


func start_charge() -> void:
	if _is_reloading:
		return
	_is_drawn = true
	if sprite:
		sprite.play("loaded")


func shoot(
	direction: Vector2, shooter_velocity: Vector2 = Vector2.ZERO, charge_ratio: float = 1.0
) -> void:
	if _is_reloading:
		return

	_is_drawn = false
	if sprite:
		sprite.play("shoot_from_loaded")
	if nocked_arrow:
		nocked_arrow.visible = false

	self._instantiate_arrow(direction, shooter_velocity, charge_ratio)
	self._reload()


func _instantiate_arrow(direction: Vector2, shooter_velocity: Vector2, power: float) -> void:
	var arrow = ARROW_SCENE.instantiate()
	# Offset spawn position in shoot direction to avoid spawning inside surfaces
	arrow.global_position = arrow_spawn.global_position + direction * 10.0
	arrow.direction = direction
	arrow.shooter_velocity = shooter_velocity
	arrow.power = power
	get_tree().current_scene.add_child(arrow)


func _reload() -> void:
	_is_reloading = true
	var actual_reload_time := reload_time / reload_speed
	var timer := get_tree().create_timer(actual_reload_time)
	timer.timeout.connect(_on_reload_complete)


func _on_reload_complete() -> void:
	_is_reloading = false
	if nocked_arrow:
		nocked_arrow.visible = true


func set_flip(flip_h: bool) -> void:
	if sprite:
		sprite.flip_h = flip_h
	if arrow_spawn:
		arrow_spawn.position.x = (
			-abs(arrow_spawn.position.x) if flip_h else abs(arrow_spawn.position.x)
		)
	if nocked_arrow:
		nocked_arrow.flip_v = flip_h
		var dir := -1.0 if flip_h else 1.0
		var base_pos := dir * _nocked_arrow_base_x
		var drawn_offset := -dir * DRAW_OFFSET if _is_drawn else 0.0
		nocked_arrow.position.x = base_pos + drawn_offset


func set_aim(direction: Vector2) -> void:
	# Use only vertical angle for rotation - flip_h handles horizontal direction
	var vertical_angle := asin(clamp(direction.y, -1.0, 1.0))
	# Invert rotation when sprite is flipped (otherwise it appears inverted)
	if sprite and sprite.flip_h:
		rotation = -vertical_angle
	else:
		rotation = vertical_angle


func _on_animation_finished() -> void:
	if sprite.animation in ["shoot", "shoot_from_loaded"]:
		sprite.play("idle")
