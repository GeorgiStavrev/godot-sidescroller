extends NPCNode

const SPEED = 30.0
const MAX_HEALTH = 20.0
const GRAVITY = 400.0
const CONTACT_DAMAGE = 10.0

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft


func _ready() -> void:
	add_to_group("saveable")
	add_to_group("enemies")
	self.max_health = MAX_HEALTH
	self.health = self.max_health
	self.animations = get_node("AnimatedSprite2D")
	self.direction = 1


func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0.0

	# Horizontal movement and direction change
	if ray_cast_right.is_colliding():
		direction = -1
		animations.flip_h = true
	elif ray_cast_left.is_colliding():
		direction = 1
		animations.flip_h = false

	velocity.x = direction * SPEED
	move_and_slide()
