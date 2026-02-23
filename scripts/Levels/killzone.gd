extends Area2D

@onready var timer: Timer = $Timer


func _is_player_node(body: Node2D) -> bool:
	# Check if the body is the player by checking if it's a CharacterBody2D with the player script
	if body is CharacterBody2D:
		var player_script = load("res://scripts/player.gd")
		return body.get_script() == player_script
	return false


func _on_body_entered(body: Node2D) -> void:
	if _is_player_node(body):
		Engine.time_scale = 0.5
		# Disable all collision shapes to prevent further collisions during death
		for child in body.get_children():
			if child is CollisionShape2D:
				child.queue_free()
		timer.start()


func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0
	GameManager.lose_live()
	if GameManager.lives <= 0:
		GameManager.game_over()
	else:
		get_tree().reload_current_scene()
