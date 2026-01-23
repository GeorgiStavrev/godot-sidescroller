extends AnimatableBody2D

@onready var raycast_left: RayCast2D = $RaycastLeft
@onready var raycast_right: RayCast2D = $RaycastRight

@export var speed: float = 50.0
var direction: int = -1


func _ready() -> void:
	sync_to_physics = true


func _physics_process(delta: float) -> void:
	if raycast_left.is_colliding():
		direction = 1
	elif raycast_right.is_colliding():
		direction = -1

	self.position.x += direction * speed * delta
