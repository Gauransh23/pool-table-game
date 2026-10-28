extends CanvasLayer
class_name GameHUD

const SpinPadScript = preload("res://scripts/ui/spin_pad.gd")

signal shoot_requested(power: float, spin: Vector2)
signal rack_requested
signal power_changed(value: float)
signal spin_changed(value: Vector2)

var power: float = 0.42
var selected_spin: Vector2 = Vector2.ZERO
var _status: Label
var _power_readout: Label
var _power_slider: HSlider
var _spin_pad: SpinPad
var _shoot_button: Button
var _rack_button: Button


func _ready() -> void:
	_build()


func set_status(text: String) -> void:
	if is_instance_valid(_status):
		_status.text = text


func set_can_shoot(can_shoot: bool) -> void:
	if is_instance_valid(_shoot_button):
		_shoot_button.disabled = not can_shoot


func _build() -> void:
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	var brand := VBoxContainer.new()
	brand.position = Vector2(44.0, 34.0)
	brand.add_theme_constant_override("separation", 1)
	root.add_child(brand)
	var title := _label("LONG RAIL", 25, Color("#f1e8d6"))
	title.add_theme_constant_override("outline_size", 0)
	brand.add_child(title)
	var subtitle := _label("THE PRACTICE TABLE", 11, Color("#c3a878"))
	brand.add_child(subtitle)
	var right := VBoxContainer.new()
	right.anchor_left = 1.0
	right.anchor_right = 1.0
	right.offset_left = -312.0
	right.offset_right = -44.0
	right.offset_top = 38.0
	right.offset_bottom = 122.0
	right.alignment = BoxContainer.ALIGNMENT_END
	right.add_theme_constant_override("separation", 4)
	root.add_child(right)
	var status_label := _label("PRACTICE  /  9-FOOT TABLE", 14, Color("#f1e8d6"))
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	right.add_child(status_label)
	_status = _label("MOVE TO AIM · SET SPIN · TAKE YOUR TIME", 10, Color("#b5ad98"))
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	right.add_child(_status)
	var footer := PanelContainer.new()
	footer.anchor_left = 0.025
	footer.anchor_right = 0.975
	footer.anchor_top = 1.0
	footer.anchor_bottom = 1.0
	footer.offset_top = -164.0
	footer.offset_bottom = -28.0
	footer.add_theme_stylebox_override("panel", _panel_style())
	root.add_child(footer)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 24)
	footer.add_child(row)
	var spin_column := VBoxContainer.new()
	spin_column.add_theme_constant_override("separation", 3)
	row.add_child(spin_column)
	spin_column.add_child(_label("TIP POSITION", 10, Color("#c7b998")))
	_spin_pad = SpinPadScript.new()
	_spin_pad.spin_changed.connect(_on_spin_changed)
	spin_column.add_child(_spin_pad)
	var power_column := VBoxContainer.new()
	power_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	power_column.add_theme_constant_override("separation", 8)
	row.add_child(power_column)
	var power_header := HBoxContainer.new()
	power_column.add_child(power_header)
	power_header.add_child(_label("SHOT SPEED", 10, Color("#c7b998")))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	power_header.add_child(spacer)
	_power_readout = _label("42%", 12, Color("#f1e8d6"))
	power_header.add_child(_power_readout)
	_power_slider = HSlider.new()
	_power_slider.min_value = 0.08
	_power_slider.max_value = 1.0
	_power_slider.step = 0.01
	_power_slider.value = power
	_power_slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_power_slider.value_changed.connect(_on_power_changed)
	power_column.add_child(_power_slider)
	var note := _label("Drag the slider for a measured stroke. Spin stays honest to the contact point.", 10, Color("#aba38f"))
	power_column.add_child(note)
	var action_spacer := Control.new()
	action_spacer.custom_minimum_size.x = 32.0
	row.add_child(action_spacer)
	var actions := VBoxContainer.new()
	actions.custom_minimum_size.x = 202.0
	actions.add_theme_constant_override("separation", 8)
	row.add_child(actions)
	_shoot_button = Button.new()
	_shoot_button.text = "TAKE SHOT  ↗"
	_shoot_button.custom_minimum_size = Vector2(202.0, 48.0)
	_shoot_button.add_theme_font_size_override("font_size", 13)
	_shoot_button.add_theme_color_override("font_color", Color("#171a18"))
	_shoot_button.add_theme_color_override("font_hover_color", Color("#171a18"))
	_shoot_button.add_theme_stylebox_override("normal", _button_style(Color("#d6b578")))
	_shoot_button.add_theme_stylebox_override("hover", _button_style(Color("#e5c58a")))
	_shoot_button.add_theme_stylebox_override("pressed", _button_style(Color("#ba9257")))
	_shoot_button.add_theme_stylebox_override("disabled", _button_style(Color("#75654c")))
	_shoot_button.pressed.connect(_on_shoot_pressed)
	actions.add_child(_shoot_button)
	_rack_button = Button.new()
	_rack_button.text = "RE-RACK"
	_rack_button.custom_minimum_size = Vector2(202.0, 32.0)
	_rack_button.add_theme_font_size_override("font_size", 10)
	_rack_button.add_theme_color_override("font_color", Color("#d3cbb8"))
	_rack_button.add_theme_stylebox_override("normal", _button_style(Color(0.1, 0.13, 0.12, 0.6)))
	_rack_button.add_theme_stylebox_override("hover", _button_style(Color(0.2, 0.24, 0.21, 0.82)))
	_rack_button.add_theme_stylebox_override("pressed", _button_style(Color(0.12, 0.16, 0.14, 0.82)))
	_rack_button.pressed.connect(func() -> void: rack_requested.emit())
	actions.add_child(_rack_button)
	var instruction := _label("AIM WITH THE POINTER  ·  SPACE TO SHOOT", 10, Color("#a6a08f"))
	instruction.position = Vector2(44.0, 112.0)
	root.add_child(instruction)


func _on_power_changed(value: float) -> void:
	power = value
	_power_readout.text = "%d%%" % roundi(power * 100.0)
	power_changed.emit(power)


func _on_spin_changed(value: Vector2) -> void:
	selected_spin = value
	spin_changed.emit(selected_spin)


func _on_shoot_pressed() -> void:
	shoot_requested.emit(power, selected_spin)


func _label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.052, 0.047, 0.91)
	style.border_color = Color(0.55, 0.44, 0.29, 0.56)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 9
	style.corner_radius_top_right = 9
	style.corner_radius_bottom_left = 9
	style.corner_radius_bottom_right = 9
	style.content_margin_left = 20.0
	style.content_margin_right = 20.0
	style.content_margin_top = 12.0
	style.content_margin_bottom = 12.0
	return style


func _button_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left = 14.0
	style.content_margin_right = 14.0
	style.content_margin_top = 7.0
	style.content_margin_bottom = 7.0
	return style
