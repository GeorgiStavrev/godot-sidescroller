extends Label
class_name FloatingLabel

const FLOAT_DISTANCE = 20.0
const FLOAT_DURATION = 0.8


func _ready() -> void:
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y - FLOAT_DISTANCE, FLOAT_DURATION)
	tween.tween_property(self, "modulate:a", 0.0, FLOAT_DURATION)
	tween.chain().tween_callback(queue_free)


static func spawn(
	parent: Node, text: String, settings: LabelSettings = null, offset: Vector2 = Vector2.ZERO
) -> FloatingLabel:
	var label := FloatingLabel.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = offset

	if settings:
		label.label_settings = settings
	else:
		# Default styling if no settings provided
		label.add_theme_color_override("font_color", Color.RED)
		label.add_theme_color_override("font_outline_color", Color.BLACK)
		label.add_theme_constant_override("outline_size", 2)

	parent.add_child(label)
	return label
