extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _on_body_entered(body: Node2D) -> void:
	# Check if the body is the player
	if body is CharacterBody2D:
		var player_script = load("res://scripts/player.gd")
		if body.get_script() == player_script:
			GameManager.collect_coin(str(get_path()))
			animation_player.play("pickup")
