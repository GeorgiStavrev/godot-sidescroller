class_name ChargeInfo
extends RefCounted

var power: float
var display_ratio: float
var should_release: bool
var warning_progress: float


static func create(
	p_power: float, p_display_ratio: float, p_should_release: bool, p_warning_progress: float
) -> ChargeInfo:
	var info := ChargeInfo.new()
	info.power = p_power
	info.display_ratio = p_display_ratio
	info.should_release = p_should_release
	info.warning_progress = p_warning_progress
	return info
