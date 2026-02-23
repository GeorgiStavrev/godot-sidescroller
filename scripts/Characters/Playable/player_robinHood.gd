extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var weapon_slot: Node2D = $WeaponSlot

const BOW_SCENE = preload("res://scenes/Weapons/bow.tscn")

const MAX_SPEED = 130.0
const RUN_SPEED = 200.0
const JUMP_VELOCITY = -300.0
const JUMP_VELOCITY_RUNNING = -360.0
const GROUND_ACCELERATION = 800.0
const GROUND_FRICTION = 1000.0
const GROUND_FRICTION_FAST = 200.0
const AIR_ACCELERATION = 400.0
const AIR_FRICTION = 200.0
const INERTIA_THRESHOLD = 100.0
const AIM_ANGLE = 45.0  # Degrees for up/down aiming

var _facing_right: bool = true
var _current_weapon: Node = null
var _aim_direction: Vector2 = Vector2.RIGHT


func _ready() -> void:
	add_to_group("saveable")
	add_to_group("player")
	equip_weapon(BOW_SCENE)


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_jump()
	_update_aim()
	_handle_shoot()

	var direction := _get_input_direction()
	var max_speed := _get_max_speed()

	_update_animation(direction)
	_update_weapon()
	_apply_movement(delta, direction, max_speed)
	move_and_slide()


func equip_weapon(weapon_scene: PackedScene) -> void:
	unequip_weapon()
	_current_weapon = weapon_scene.instantiate()
	weapon_slot.add_child(_current_weapon)


func unequip_weapon() -> void:
	if _current_weapon:
		_current_weapon.queue_free()
		_current_weapon = null


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta


func _handle_jump() -> void:
	if not Input.is_action_just_pressed("jump"):
		return
	if not is_on_floor():
		return

	var is_running := Input.is_action_pressed("sprint")
	var has_momentum: bool = is_running and abs(velocity.x) > INERTIA_THRESHOLD
	velocity.y = JUMP_VELOCITY_RUNNING if has_momentum else JUMP_VELOCITY


func _update_aim() -> void:
	var horizontal := 1.0 if _facing_right else -1.0
	var vertical := 0.0

	if Input.is_action_pressed("aim_up"):
		vertical = -1.0
	elif Input.is_action_pressed("aim_down"):
		vertical = 1.0

	if vertical != 0.0:
		var angle_rad := deg_to_rad(AIM_ANGLE) * vertical
		# Invert rotation when facing left
		if not _facing_right:
			angle_rad = -angle_rad
		_aim_direction = Vector2(horizontal, 0).rotated(angle_rad)
	else:
		_aim_direction = Vector2(horizontal, 0)


func _handle_shoot() -> void:
	if not Input.is_action_just_pressed("shoot"):
		return
	if not _current_weapon:
		return
	if not _current_weapon.has_method("shoot"):
		return

	_current_weapon.shoot(_aim_direction)


func _get_input_direction() -> float:
	var direction := 0.0
	if Input.is_action_pressed("run_left"):
		_facing_right = false
		animated_sprite.flip_h = true
		direction -= 1.0
	if Input.is_action_pressed("run_right"):
		_facing_right = true
		animated_sprite.flip_h = false
		direction += 1.0
	return direction


func _get_max_speed() -> float:
	if Input.is_action_pressed("sprint"):
		return RUN_SPEED
	return MAX_SPEED


func _update_animation(direction: float) -> void:
	if not is_on_floor():
		animated_sprite.play("run")
	elif direction == 0.0:
		animated_sprite.play("idle")
	else:
		animated_sprite.play("run")


func _update_weapon() -> void:
	if not _current_weapon:
		return

	if _current_weapon.has_method("set_flip"):
		_current_weapon.set_flip(not _facing_right)

	if _current_weapon.has_method("set_aim"):
		_current_weapon.set_aim(_aim_direction)

	if _facing_right:
		weapon_slot.position.x = abs(weapon_slot.position.x)
	else:
		weapon_slot.position.x = -abs(weapon_slot.position.x)


func _apply_movement(delta: float, direction: float, max_speed: float) -> void:
	if is_on_floor():
		_apply_ground_movement(delta, direction, max_speed)
	else:
		_apply_air_movement(delta, direction, max_speed)


func _apply_ground_movement(delta: float, direction: float, max_speed: float) -> void:
	if direction:
		velocity.x = move_toward(velocity.x, direction * max_speed, GROUND_ACCELERATION * delta)
	else:
		var friction := (
			GROUND_FRICTION_FAST if abs(velocity.x) > INERTIA_THRESHOLD else GROUND_FRICTION
		)
		velocity.x = move_toward(velocity.x, 0, friction * delta)


func _apply_air_movement(delta: float, direction: float, max_speed: float) -> void:
	if direction:
		velocity.x = move_toward(velocity.x, direction * max_speed, AIR_ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, AIR_FRICTION * delta)


func serialize() -> Dictionary:
	return {
		"position_x": position.x,
		"position_y": position.y,
		"velocity_x": velocity.x,
		"velocity_y": velocity.y,
		"facing_right": _facing_right,
	}


func deserialize(data: Dictionary) -> void:
	position.x = data.get("position_x", position.x)
	position.y = data.get("position_y", position.y)
	velocity.x = data.get("velocity_x", 0.0)
	velocity.y = data.get("velocity_y", 0.0)
	_facing_right = data.get("facing_right", true)
	animated_sprite.flip_h = not _facing_right
