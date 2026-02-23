extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var collision_shape_crouching: CollisionShape2D = $CollisionShape2DCrouching


func _ready() -> void:
	add_to_group("saveable")


const MAX_SPEED = 130.0
const RUN_SPEED = 200.0  # Speed when holding Ctrl (run button)
const CROUCH_SPEED = 60.0  # Slower speed when crouching
const JUMP_VELOCITY = -300.0
const JUMP_VELOCITY_RUNNING = -360.0  # Higher jump when running fast (like Mario)
const GROUND_ACCELERATION = 800.0  # How fast Player accelerates on ground
const GROUND_FRICTION = 1000.0  # How fast Player decelerates on ground
const GROUND_FRICTION_FAST = 200.0  # Less friction when moving fast (more inertia)
const AIR_ACCELERATION = 400.0  # How fast Player accelerates in air (less control)
const AIR_FRICTION = 200.0  # How fast Player decelerates in air
const INERTIA_THRESHOLD = 100.0  # Speed threshold for applying reduced friction

var _is_crouching: bool = false


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_update_crouch_state()
	_handle_jump()

	var direction := _get_input_direction()
	var max_speed := _get_max_speed()

	_update_collision_and_animation(direction)
	_apply_movement(delta, direction, max_speed)
	move_and_slide()


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta


func _update_crouch_state() -> void:
	if not is_on_floor():
		_is_crouching = false
		return

	var wants_to_crouch := Input.is_action_pressed("crouch")
	if wants_to_crouch:
		_is_crouching = true
	elif _is_crouching and not _can_stand_up():
		_is_crouching = true
	else:
		_is_crouching = false


func _can_stand_up() -> bool:
	if collision_shape:
		collision_shape.disabled = false
	if collision_shape_crouching:
		collision_shape_crouching.disabled = true
	var can_stand := not test_move(global_transform, Vector2.ZERO)
	if collision_shape:
		collision_shape.disabled = true
	if collision_shape_crouching:
		collision_shape_crouching.disabled = false
	return can_stand


func _handle_jump() -> void:
	if not Input.is_action_just_pressed("jump"):
		return
	if not is_on_floor() or _is_crouching:
		return

	var is_running := Input.is_action_pressed("sprint")
	var has_momentum: bool = is_running and abs(velocity.x) > INERTIA_THRESHOLD
	velocity.y = JUMP_VELOCITY_RUNNING if has_momentum else JUMP_VELOCITY


func _get_input_direction() -> float:
	var direction := 0.0
	if Input.is_action_pressed("run_left"):
		animated_sprite.flip_h = true
		direction -= 1.0
	if Input.is_action_pressed("run_right"):
		animated_sprite.flip_h = false
		direction += 1.0
	return direction


func _get_max_speed() -> float:
	if _is_crouching:
		return CROUCH_SPEED
	elif Input.is_action_pressed("sprint"):
		return RUN_SPEED
	else:
		return MAX_SPEED


func _update_collision_and_animation(direction: float) -> void:
	if not is_on_floor():
		_set_crouching_collision()
		animated_sprite.play("jump")
	elif _is_crouching:
		_set_crouching_collision()
		animated_sprite.play("crouch" if direction == 0.0 else "crouch_move")
	else:
		_set_standing_collision()
		animated_sprite.play("idle" if direction == 0.0 else "run")


func _set_standing_collision() -> void:
	if collision_shape:
		collision_shape.disabled = false
	if collision_shape_crouching:
		collision_shape_crouching.disabled = true


func _set_crouching_collision() -> void:
	if collision_shape:
		collision_shape.disabled = true
	if collision_shape_crouching:
		collision_shape_crouching.disabled = false


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
		"flip_h": animated_sprite.flip_h,
	}


func deserialize(data: Dictionary) -> void:
	position.x = data.get("position_x", position.x)
	position.y = data.get("position_y", position.y)
	velocity.x = data.get("velocity_x", 0.0)
	velocity.y = data.get("velocity_y", 0.0)
	animated_sprite.flip_h = data.get("flip_h", false)

	# Reset camera smoothing to prevent it from animating to the new position
	var camera := get_node_or_null("Camera2D") as Camera2D
	if camera:
		camera.force_update_scroll()
		camera.reset_smoothing()
