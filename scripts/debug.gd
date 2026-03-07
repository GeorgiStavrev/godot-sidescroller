# debug.gd
class_name Debug


static func print(...args: Array) -> void:
	if GameManager.debug_mode:
		print(args)
