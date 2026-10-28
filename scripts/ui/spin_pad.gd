extends Control
class_name SpinPad

signal spin_changed(value: Vector2)

const MAX_STABLE_TIP_OFFSET := 0.5

var spin: Vector2 = Vector2.ZERO
var _radius: float = 0.0


func _ready() -> void:
	custom_minimum_size = Vector2(112.0, 112.0)
	mouse_filter = Control.MOUSE_FILTER_STOP


func _draw() -> void:
	var center := size * 0.5
	_radius = minf(size.x, size.y) * 0.41
	draw_circle(center, _radius, Color("#eee8d9"))
	draw_arc(center, _radius, 0.0, TAU, 64, Color("#b8ac91"), 1.2, true)
	draw_line(center + Vector2(-_radius * 0.72, 0.0), center + Vector2(_radius * 0.72, 0.0), Color("#c7bda7"), 1.0, true)
	draw_line(center + Vector2(0.0, -_radius * 0.72), center + Vector2(0.0, _radius * 0.72), Color("#c7bda7"), 1.0, true)
	draw_circle(center, 2.4, Color("#8d8067"))
	draw_circle(center + Vector2(spin.x, -spin.y) * _radius, 6.2, Color("#b5783f"))
	draw_arc(center + Vector2(spin.x, -spin.y) * _radius, 6.2, 0.0, TAU, 32, Color("#fff5df"), 1.2, true)


static func normalized_tip_offset(point: Vector2, control_size: Vector2) -> Vector2:
	var radius := minf(control_size.x, control_size.y) * 0.41
	if radius <= 0.0:
		return Vector2.ZERO
	var screen_offset := point - control_size * 0.5
	return Vector2(screen_offset.x / radius, -screen_offset.y / radius).limit_length(MAX_STABLE_TIP_OFFSET)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_button := event as InputEventMouseButton
		if mouse_button.button_index == MOUSE_BUTTON_LEFT and mouse_button.pressed:
			_update_spin(mouse_button.position)
			accept_event()
	elif event is InputEventMouseMotion:
		var mouse_motion := event as InputEventMouseMotion
		if mouse_motion.button_mask & MOUSE_BUTTON_MASK_LEFT:
			_update_spin(mouse_motion.position)
			accept_event()


func _update_spin(point: Vector2) -> void:
	spin = normalized_tip_offset(point, size)
	queue_redraw()
	spin_changed.emit(spin)
