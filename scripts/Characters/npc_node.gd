extends DamageableBody2D

class_name NPCNode

var direction: int


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
	animations.flip_h = direction == -1
