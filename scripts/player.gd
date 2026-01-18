extends CharacterBody2D

const MAX_SPEED = 130.0
const RUN_SPEED = 200.0  # Speed when holding Ctrl (run button)
const JUMP_VELOCITY = -300.0
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

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var is_running: bool = false
	if Input.is_action_pressed("turbo"):
		is_running = true

	# Determine current max speed based on run button
	var current_max_speed := RUN_SPEED if is_running else MAX_SPEED

	var direction := 0.0
	if Input.is_action_pressed("run_left"):
		direction -= 1.0
	if Input.is_action_pressed("run_right"):
		direction += 1.0
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
	#print('=========', '\n')
