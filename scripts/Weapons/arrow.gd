extends RigidBody2D

const MIN_SPEED = 200.0
const MAX_SPEED = 800.0
const LIFETIME = 10.0
const MIN_DAMAGE = 5.0
const MAX_DAMAGE = 25.0
const MIN_SPEED_TO_DAMAGE = 50.0
const MIN_CHARGE_TO_STICK = 0.5  # Minimum charge ratio to stick to surfaces

var direction: Vector2 = Vector2.RIGHT
var shooter_velocity: Vector2 = Vector2.ZERO
var charge_ratio: float = 1.0
var _has_stopped: bool = false
var _has_collided: bool = false


func _ready() -> void:
	var speed := MIN_SPEED + (MAX_SPEED - MIN_SPEED) * charge_ratio
	linear_velocity = direction * speed + shooter_velocity
	rotation = linear_velocity.angle()

	body_entered.connect(_on_body_entered)

	# Connect to hitbox area for detecting Area2D enemies
	var hitbox := $Hitbox as Area2D
	if hitbox:
		hitbox.area_entered.connect(_on_area_entered)

	# Auto-remove after lifetime
	var timer := get_tree().create_timer(LIFETIME)
	timer.timeout.connect(queue_free)


func _physics_process(_delta: float) -> void:
	if _has_stopped:
		return

	# Rotate arrow to face velocity direction
	if linear_velocity.length() > MIN_SPEED_TO_DAMAGE:
		rotation = linear_velocity.angle()
	elif _has_collided:
		# Only stop if we've hit something and are now slow
		call_deferred("_stop")


func _on_body_entered(body: Node2D) -> void:
	if _has_stopped:
		return

	# Ignore the player
	if body.is_in_group("player"):
		return

	_has_collided = true

	# Only deal damage if moving fast enough
	if linear_velocity.length() < MIN_SPEED_TO_DAMAGE:
		return

	# Calculate damage based on charge
	var damage := MIN_DAMAGE + (MAX_DAMAGE - MIN_DAMAGE) * charge_ratio

	if body.has_method("take_damage"):
		body.take_damage(damage)
		_handle_enemy_hit(body)
		return

	if body.is_in_group("enemies"):
		body.queue_free()
		call_deferred("_stop")
		return

	# Surfaces: stick if enough charge, otherwise bounce
	if charge_ratio >= MIN_CHARGE_TO_STICK:
		call_deferred("_stick_to_surface", body)
	# Low power arrows bounce off (physics handles it)


func _on_area_entered(area: Area2D) -> void:
	if _has_stopped:
		return

	# Ignore non-enemies
	if not area.is_in_group("enemies"):
		return

	# Only deal damage if moving fast enough
	if linear_velocity.length() < MIN_SPEED_TO_DAMAGE:
		return

	# Calculate damage based on charge
	var damage := MIN_DAMAGE + (MAX_DAMAGE - MIN_DAMAGE) * charge_ratio

	if area.has_method("take_damage"):
		area.take_damage(damage)
		_handle_enemy_hit(area)
	else:
		area.queue_free()
		call_deferred("_stop")


func _handle_enemy_hit(target: Node2D) -> void:
	if is_instance_valid(target):
		# Attach to enemy (alive or dying) so arrow follows them
		call_deferred("_attach_to", target)
	else:
		call_deferred("_stop")


func _attach_to(target: Node2D) -> void:
	if _has_stopped:
		return
	if not is_instance_valid(target):
		_stop()
		return

	_has_stopped = true
	freeze = true

	# Disable collisions
	var hitbox := $Hitbox as Area2D
	if hitbox:
		hitbox.monitoring = false
	contact_monitor = false

	# Destroy arrow when target dies
	target.tree_exiting.connect(queue_free)

	# Reparent to target (keeps global transform)
	reparent(target)

	# Render behind the target so tip appears embedded
	z_index = -1


func _stick_to_surface(body: Node2D) -> void:
	if _has_stopped:
		return

	_has_stopped = true
	freeze = true

	# Render behind the surface so tip appears embedded
	z_index = body.z_index - 1


func _stop() -> void:
	_has_stopped = true
	freeze = true
