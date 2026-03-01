extends Area2D

const SPEED = 30.0
const MAX_HEALTH = 20.0

var direction = 1
var health: float = MAX_HEALTH
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	add_to_group("saveable")
	add_to_group("enemies")
	animated_sprite.animation_finished.connect(_on_animation_finished)


func _on_animation_finished() -> void:
	if animated_sprite.animation == "hurt":
		animated_sprite.play("default")
	if animated_sprite.animation == "death":
		queue_free()


func _process(delta: float) -> void:
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	elif ray_cast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false

	self.position.x += direction * SPEED * delta


func take_damage(damage: float) -> void:
	health -= damage
	animated_sprite.play("hurt")
	if health <= 0:
		animated_sprite.play("death")


func serialize() -> Dictionary:
	return {
		"position_x": position.x,
		"position_y": position.y,
		"direction": direction,
	}


func deserialize(data: Dictionary) -> void:
	position.x = data.get("position_x", position.x)
	position.y = data.get("position_y", position.y)
	direction = data.get("direction", direction)
	animated_sprite.flip_h = direction == -1


func _on_animated_finished() -> void:
	if animated_sprite.animation == "hurt":
		animated_sprite.play("default")
	if animated_sprite.animation == "death":
		queue_free()
