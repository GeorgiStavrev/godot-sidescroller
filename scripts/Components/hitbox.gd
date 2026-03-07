@tool
extends Area2D
class_name Hitbox

enum ShapeType { RECTANGLE, CIRCLE }

@export var shape_type: ShapeType = ShapeType.RECTANGLE:
	set(value):
		shape_type = value
		_update_shape()

@export var size: Vector2 = Vector2(14, 15):
	set(value):
		size = value
		_update_shape()

@export var radius: float = 8.0:
	set(value):
		radius = value
		_update_shape()

@export var offset: Vector2 = Vector2.ZERO:
	set(value):
		offset = value
		_update_shape()

@export var damage_multiplier: float = 1.0
@export var hit_label: String = ""  # e.g., "HEADSHOT"
@export var hit_label_settings: LabelSettings

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var parent:
	get:
		return get_parent()


func _ready() -> void:
	add_to_group("hitbox")
	_update_shape()


func _update_shape() -> void:
	if not is_inside_tree():
		return
	if not collision_shape:
		collision_shape = $CollisionShape2D
	if not collision_shape:
		return

	match shape_type:
		ShapeType.RECTANGLE:
			if not collision_shape.shape is RectangleShape2D:
				collision_shape.shape = RectangleShape2D.new()
			var rect_shape := collision_shape.shape as RectangleShape2D
			rect_shape.size = size
		ShapeType.CIRCLE:
			if not collision_shape.shape is CircleShape2D:
				collision_shape.shape = CircleShape2D.new()
			var circle_shape := collision_shape.shape as CircleShape2D
			circle_shape.radius = radius

	collision_shape.position = offset


func hit(damage: float) -> void:
	Debug.print(NodeTools.get_node_path(self), " was hit (damage:" + str(damage) + ").")
	self._forward_damage_to_parent(damage * damage_multiplier)
	if hit_label and parent and parent.has_method("show_hit_label"):
		parent.show_hit_label(hit_label, hit_label_settings)


func _forward_damage_to_parent(damage: float) -> void:
	var parent := get_parent()
	if parent and parent.has_method("take_damage"):
		parent.take_damage(damage)


func get_damage_receiver() -> Node:
	return parent
