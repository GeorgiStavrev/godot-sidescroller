extends CharacterBody2D


const MAX_SPEED = 130.0
const JUMP_VELOCITY = -300.0
const GROUND_ACCELERATION = 800.0  # How fast Mario accelerates on ground
const GROUND_FRICTION = 1000.0     # How fast Mario decelerates on ground
const AIR_ACCELERATION = 400.0     # How fast Mario accelerates in air (less control)
const AIR_FRICTION = 200.0         # How fast Mario decelerates in air


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	
	if is_on_floor():
		# Ground movement with acceleration and friction
		if direction:
			# Accelerate towards max speed
			velocity.x = move_toward(velocity.x, direction * MAX_SPEED, GROUND_ACCELERATION * delta)
		else:
			# Apply friction when no input
			velocity.x = move_toward(velocity.x, 0, GROUND_FRICTION * delta)
	else:
		# Air movement with less control
		if direction:
			# Accelerate in air (slower than on ground)
			velocity.x = move_toward(velocity.x, direction * MAX_SPEED, AIR_ACCELERATION * delta)
		else:
			# Less friction in air
			velocity.x = move_toward(velocity.x, 0, AIR_FRICTION * delta)

	move_and_slide()
