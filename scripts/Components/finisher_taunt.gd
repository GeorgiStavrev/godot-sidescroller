extends Node2D

@onready var sfx_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

@export
var label_settings: LabelSettings = preload("res://templates/finisher_label.tres").duplicate()

var node: DamageableBody2D


func _ready() -> void:
	self.node = NodeTools.get_ancestor_by_class(self, DamageableBody2D)
	if self.node == null:
		push_error("Could not find node to attach finisher_taunt to.")
	else:
		self.node.connect("damage_taken", _on_damage_taken)


func _on_damage_taken(damage: float, has_died: bool, health: float) -> void:
	if not has_died and self.node.health > 0 and self.node.health / self.node.max_health < 0.2:
		node.show_hit_label("FINISH HIM", label_settings)
		sfx_player.play()
