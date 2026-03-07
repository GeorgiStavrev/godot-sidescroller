extends Area2D
class_name Hitbox

@export var size: Vector2 = Vector2(14, 15):
	set(value):
		size = value
		_update_shape()

@export var offset: Vector2 = Vector2.ZERO:
	set(value):
		offset = value
		_update_shape()

@export var damage_multiplier: float = 1.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	add_to_group("hitbox")
	_update_shape()


func _update_shape() -> void:
	if not collision_shape:
		return
	var shape := collision_shape.shape as RectangleShape2D
	if shape:
		shape.size = size
	collision_shape.position = offset


func hit(damage: float) -> void:
	Debug.print(NodeTools.get_node_path(self), " was hit (damage:" + str(damage) + ").")
	self._forward_damage_to_parent(damage * damage_multiplier)


func _forward_damage_to_parent(damage: float) -> void:
	var parent := get_parent()
	if parent and parent.has_method("take_damage"):
		parent.take_damage(damage)


func get_damage_receiver() -> Node:
	return get_parent()
