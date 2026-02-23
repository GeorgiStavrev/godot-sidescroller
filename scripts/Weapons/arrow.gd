extends Area2D

const HEALTH = 10.0
const SPEED = 300.0
const GRAVITY = 20.0
const LIFETIME = 30.0
const PLAIN_DAMAGE = 10.0

var velocity: Vector2 = Vector2.ZERO
var direction: Vector2 = Vector2.RIGHT


func _ready() -> void:
	velocity = direction * SPEED
	rotation = velocity.angle()
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

	# Auto-remove after lifetime
	var timer := get_tree().create_timer(LIFETIME)
	timer.timeout.connect(queue_free)


func _physics_process(delta: float) -> void:
	# Apply gravity
	velocity.y += GRAVITY * delta

	# Move arrow
	position += velocity * delta

	# Rotate to face velocity direction
	rotation = velocity.angle()


func _on_body_entered(body: Node2D) -> void:
	# Ignore the player
	if body.is_in_group("player"):
		return
	print("arrow entered body", body)
	if body.has_method("take_damage"):
		body.take_damage(PLAIN_DAMAGE)
	# Destroy enemies
	if body.is_in_group("enemies"):
		body.queue_free()
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		if area.has_method("take_damage"):
			area.take_damage(PLAIN_DAMAGE)
		else:
			area.queue_free()
	queue_free()
