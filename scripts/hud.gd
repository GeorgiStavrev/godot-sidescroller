extends CanvasLayer

@onready var coin_label: Label = $HUDContainer/CoinLabel
@onready var coin_icon: TextureRect = $HUDContainer/CoinIcon

func _ready() -> void:
	# Connect to game manager signals
	GameManager.coins_changed.connect(_on_coins_changed)
	# Update initial display
	_update_coin_display()

func _on_coins_changed(new_total: int) -> void:
	_update_coin_display()

func _update_coin_display() -> void:
	if coin_label:
		var coin_text = str(GameManager.coins)
		# Pad with zeros to always show 2 digits (e.g., "00", "01", "10")
		if coin_text.length() < 2:
			coin_text = "0" + coin_text
		coin_label.text = "x" + coin_text
