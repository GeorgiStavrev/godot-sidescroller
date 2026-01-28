extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	add_to_group("saveable")


const MAX_SPEED = 130.0
const RUN_SPEED = 200.0  # Speed when holding Ctrl (run button)
const JUMP_VELOCITY = -300.0
const JUMP_VELOCITY_RUNNING = -360.0  # Higher jump when running fast (like Mario)
const GROUND_ACCELERATION = 800.0  # How fast Player accelerates on ground
const GROUND_FRICTION = 1000.0  # How fast Player decelerates on ground
const GROUND_FRICTION_FAST = 200.0  # Less friction when moving fast (more inertia)
const AIR_ACCELERATION = 400.0  # How fast Player accelerates in air (less control)
const AIR_FRICTION = 200.0  # How fast Player decelerates in air
const INERTIA_THRESHOLD = 100.0  # Speed threshold for applying reduced friction


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	var is_running: bool = Input.is_action_pressed("sprint")

	# Handle jump with inertia - jump higher when running fast (like Mario)
	if Input.is_action_just_pressed("jump") and is_on_floor():
		var has_momentum: bool = is_running and abs(velocity.x) > INERTIA_THRESHOLD
		velocity.y = JUMP_VELOCITY_RUNNING if has_momentum else JUMP_VELOCITY

	# Determine current max speed based on run button
	var current_max_speed := RUN_SPEED if is_running else MAX_SPEED

	var direction := 0.0
	if Input.is_action_pressed("run_left"):
		animated_sprite.flip_h = true
		direction -= 1.0
	if Input.is_action_pressed("run_right"):
		animated_sprite.flip_h = false
		direction += 1.0

	if is_on_floor():
		if direction == 0.0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")

	# Apply movement
	if is_on_floor():
		# Ground movement with acceleration and friction
		if direction:
			# Accelerate towards current max speed (normal or run)
			velocity.x = move_toward(
				velocity.x, direction * current_max_speed, GROUND_ACCELERATION * delta
			)
		else:
			# Apply friction when no input
			var current_friction := (
				GROUND_FRICTION_FAST if abs(velocity.x) > INERTIA_THRESHOLD else GROUND_FRICTION
			)
			velocity.x = move_toward(velocity.x, 0, current_friction * delta)
	else:
		# Air movement with less control
		if direction:
			# Accelerate in air (slower than on ground)
			velocity.x = move_toward(
				velocity.x, direction * current_max_speed, AIR_ACCELERATION * delta
			)
		else:
			# Less friction in air
			velocity.x = move_toward(velocity.x, 0, AIR_FRICTION * delta)

	move_and_slide()


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
