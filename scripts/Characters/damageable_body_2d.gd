extends CharacterBody2D

class_name DamageableBody2D

signal damage_taken(amount, has_died, health_left)

var max_health: float
var health: float
var animations: AnimatedSprite2D


func take_damage(damage: float) -> void:
	Debug.print(NodeTools.get_node_path(self) + " took " + str(damage) + " damage")
	health -= damage
	animations.play("hurt")
	if health <= 0:
		animations.play("death")
	damage_taken.emit(damage, health <= 0, health)


func _on_animation_finished() -> void:
	if animations.animation == "hurt":
		animations.play("default")
	if animations.animation == "death":
		queue_free()


func show_hit_label(text: String, settings: LabelSettings = null) -> void:
	FloatingLabel.spawn(self, text, settings, Vector2(0, -10))
