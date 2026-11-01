extends RefCounted
class_name StrokePower

const MAX_CUE_SPEED := 8.0
const MIN_NONZERO_CUE_SPEED := 0.075
const REMAINING_CUE_SPEED_RANGE := MAX_CUE_SPEED - MIN_NONZERO_CUE_SPEED


static func cue_speed(power: float) -> float:
	if not is_finite(power) or power <= 0.0:
		return 0.0
	var bounded_power := minf(power, 1.0)
	return MIN_NONZERO_CUE_SPEED + REMAINING_CUE_SPEED_RANGE * bounded_power * bounded_power
