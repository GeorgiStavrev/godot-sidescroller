extends CanvasLayer

@onready var coin_label: Label = $HUDContainer/CoinLabel
@onready var coin_icon: TextureRect = $HUDContainer/CoinIcon
@onready var lives_label: Label = $HUDContainer/LivesLabel


func _ready() -> void:
	# Connect to game manager signals
	GameManager.coins_changed.connect(_on_coins_changed)
	# Update initial display
	_update_coin_display()
	_update_lives_display(GameManager.lives)


func _on_coins_changed(new_total: int) -> void:
	_update_coin_display()


func _update_coin_display() -> void:
	if coin_label:
		var coin_text = str(GameManager.coins)
		# Pad with zeros to always show 2 digits (e.g., "00", "01", "10")
		if coin_text.length() < 2:
			coin_text = "0" + coin_text
		coin_label.text = "x" + coin_text


func _update_lives_display(new_total: int) -> void:
	if lives_label:
		var lives_text = str(new_total)
		# Pad with zeros to always show 2 digits (e.g., "00", "01", "10")
		if lives_text.length() < 2:
			lives_text = "0" + lives_text
		lives_label.text = "x" + lives_text
