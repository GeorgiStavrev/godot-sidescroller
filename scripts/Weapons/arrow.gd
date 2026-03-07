extends RigidBody2D

const MIN_SPEED = 200.0
const MAX_SPEED = 800.0
const LIFETIME = 10.0
const MIN_DAMAGE = 5.0
const MAX_DAMAGE = 25.0
const MIN_SPEED_TO_DAMAGE = 50.0
const MIN_POWER_TO_STICK = 0.5  # Minimum charge ratio to stick to surfaces

var direction: Vector2 = Vector2.RIGHT
var shooter_velocity: Vector2 = Vector2.ZERO
var power: float = 1.0
var _has_stopped: bool = false
var _has_collided: bool = false


func _ready() -> void:
	var speed := MIN_SPEED + (MAX_SPEED - MIN_SPEED) * power
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

	# Skip bodies that have hitbox children - let area detection handle them
	if _has_hitbox_child(body):
		return

	if body.is_in_group("enemies"):
		_has_stopped = true
		body.queue_free()
		freeze = true
		return

	# Surfaces: check velocity before sticking
	if linear_velocity.length() < MIN_SPEED_TO_DAMAGE:
		return

	# Surfaces: stick if enough charge, otherwise bounce
	if power >= MIN_POWER_TO_STICK:
		call_deferred("_stick_to_surface", body)
	# Low power arrows bounce off (physics handles it)


func _on_area_entered(area: Area2D) -> void:
	if _has_stopped:
		return

	# Check if this is a Hitbox component
	if area.is_in_group("hitbox"):
		_has_stopped = true
		var damage := MIN_DAMAGE + (MAX_DAMAGE - MIN_DAMAGE) * power
		area.hit(damage)
		# Attach to the hitbox itself
		call_deferred("_attach_to", area)
		return

	# Ignore non-enemies
	if not area.is_in_group("enemies"):
		return


func _attach_to(target: Node2D) -> void:
	if not is_instance_valid(target):
		freeze = true
		return

	freeze = true

	# Disable collisions
	var hitbox := $Hitbox as Area2D
	if hitbox:
		hitbox.monitoring = false
	contact_monitor = false

	# Get the damage receiver (parent of hitbox component) for death signal
	var damage_receiver: Node = target
	if target.has_method("get_damage_receiver"):
		damage_receiver = target.get_damage_receiver()

	# Destroy arrow when damage receiver dies
	if is_instance_valid(damage_receiver):
		damage_receiver.tree_exiting.connect(queue_free)

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


func _has_hitbox_child(node: Node) -> bool:
	for child in node.get_children():
		if child.is_in_group("hitbox"):
			return true
	return false
