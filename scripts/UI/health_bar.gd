extends ProgressBar

## Generic health bar that can be attached to any node with health.
## Automatically detects parent's health and max_health properties.

@export var hide_when_full: bool = true
@export var offset: Vector2 = Vector2(0, -10)
@export var fill_color: Color = Color.GREEN
@export var bg_color: Color = Color.DARK_RED

var _parent: Node = null


func _ready() -> void:
	_setup_colors()
	_parent = get_parent()
	if _parent:
		_init_from_parent()
		_update_visibility()


func _setup_colors() -> void:
	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = fill_color
	add_theme_stylebox_override("fill", fill_style)

	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = bg_color
	add_theme_stylebox_override("background", bg_style)


func _process(_delta: float) -> void:
	if _parent and "health" in _parent:
		value = _parent.health
		_update_visibility()


func _init_from_parent() -> void:
	# Try to get max health from parent
	if "MAX_HEALTH" in _parent:
		max_value = _parent.MAX_HEALTH
	elif "max_health" in _parent:
		max_value = _parent.max_health
	else:
		max_value = 100.0

	# Set initial health
	if "health" in _parent:
		value = _parent.health
	else:
		value = max_value

	# Position above parent, centered horizontally
	position = Vector2(offset.x - size.x / 2, offset.y)


func set_health(current: float, maximum: float = -1.0) -> void:
	if maximum > 0:
		max_value = maximum
	value = current
	_update_visibility()


func _update_visibility() -> void:
	if hide_when_full:
		visible = value < max_value
