extends CanvasLayer
class_name GameHUD

signal shoot_requested(power: float, spin: Vector2)
signal rack_requested
signal power_changed(value: float)
signal spin_changed(value: Vector2)
signal mode_requested(mode: String)
signal undo_requested
signal menu_requested
signal view_requested
signal sound_changed(enabled: bool)
signal guide_changed(enabled: bool)
signal resume_requested

var power := 0.42
var selected_spin := Vector2.ZERO
var called_ball := 1
var called_pocket := 0
var safety := false
var _status: Label
var _score: Label
var _detail: Label
var _shoot: Button
var _call_ball: OptionButton
var _call_pocket: OptionButton
var _overlay: ColorRect
var _card: VBoxContainer
var _root: Control
var _spin: SpinPad
var _power: HSlider
var _readout: Label
var _mode_label: Label
var _can_shoot := true

func _ready() -> void:
	_build()

func _build() -> void:
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)
	var brand := VBoxContainer.new()
	brand.position = Vector2(38, 28)
	_root.add_child(brand)
	brand.add_child(label("L O N G   R A I L", 27, Color("e9d9b8")))
	_mode_label = label("BILLIARDS CLUB  /  MAC EDITION", 11, Color("ad9468"))
	brand.add_child(_mode_label)
	var score_box := VBoxContainer.new()
	score_box.position = Vector2(430, 29)
	_root.add_child(score_box)
	_score = label("YOUR TABLE. YOUR NEXT SHOT.", 23)
	score_box.add_child(_score)
	_detail = label("", 13, Color("b6b9aa"))
	score_box.add_child(_detail)
	var side := PanelContainer.new()
	side.anchor_left = 1; side.anchor_right = 1
	side.offset_left = -310; side.offset_right = -24
	side.offset_top = 112; side.anchor_bottom = 1; side.offset_bottom = -60
	side.add_theme_stylebox_override("panel", panel())
	_root.add_child(side)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 15)
	side.add_child(column)
	column.add_child(label("THE STROKE", 12, Color("bda577")))
	_status = label("Click and drag on the cloth to aim. Release to retain your line.", 15)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.custom_minimum_size.y = 76
	column.add_child(_status)
	var power_row := HBoxContainer.new()
	column.add_child(power_row)
	power_row.add_child(label("POWER", 11, Color("b6b9aa")))
	_readout = label("42%", 13)
	_readout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_readout.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	power_row.add_child(_readout)
	_power = HSlider.new()
	_power.focus_mode = Control.FOCUS_NONE
	_power.min_value = 0; _power.max_value = 1; _power.step = .005; _power.value = power
	_power.value_changed.connect(func(value: float):
		power = value; _readout.text = "%.1f%%" % (value * 100.0); _refresh_shoot_enabled(); power_changed.emit(value))
	column.add_child(_power)
	var spin_row := HBoxContainer.new()
	column.add_child(spin_row)
	_spin = SpinPad.new()
	_spin.custom_minimum_size = Vector2(100, 100)
	_spin.spin_changed.connect(func(value: Vector2): selected_spin = value; spin_changed.emit(value))
	spin_row.add_child(_spin)
	var spin_words := VBoxContainer.new()
	spin_words.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	spin_row.add_child(spin_words)
	spin_words.add_child(label("TIP POSITION", 11, Color("bda577")))
	spin_words.add_child(label("Top: follow\nBottom: draw\nSides: english", 12, Color("b6b9aa")))
	column.add_child(label("PURE PRACTICE", 11, Color("bda577")))
	var explanation := label("Take your time. Explore speed and spin.\nUse Undo to try a shot again.\nScratch? Click a clear place on the cloth.", 13, Color("a7b6a9"))
	column.add_child(explanation)
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(spacer)
	_shoot = button("TAKE SHOT    ↗", func(): _request_shot(), true)
	_shoot.custom_minimum_size.y = 50
	column.add_child(_shoot)
	_readout.text = "%.1f%%" % (power * 100.0)
	_refresh_shoot_enabled()
	var actions := HBoxContainer.new()
	column.add_child(actions)
	actions.add_child(button("Undo", func(): undo_requested.emit()))
	actions.add_child(button("Camera", func(): view_requested.emit()))
	actions.add_child(button("Menu", func(): menu_requested.emit()))
	var sound := CheckBox.new()
	sound.focus_mode = Control.FOCUS_NONE
	sound.text = "Table sound"; sound.button_pressed = true
	sound.toggled.connect(func(value: bool): sound_changed.emit(value))
	column.add_child(sound)
	var guides := CheckBox.new()
	guides.focus_mode = Control.FOCUS_NONE
	guides.text = "Initial path guide"
	guides.tooltip_text = "Shows launch direction and first contact. Later spin, throw and rebounds are not predicted."; guides.button_pressed = true
	guides.toggled.connect(func(value: bool): guide_changed.emit(value))
	column.add_child(guides)
	var footer := label("DRAG  Aim; release to keep     ← →  Fine aim     SPACE  Shoot     V  Camera     U  Undo     ESC  Menu", 12, Color("a8ac9c"))
	footer.anchor_top = 1; footer.anchor_bottom = 1
	footer.offset_left = 38; footer.offset_top = -36; footer.offset_bottom = -12
	_root.add_child(footer)
	_overlay = ColorRect.new()
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.color = Color(.015,.025,.024,.88)
	_root.add_child(_overlay)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.add_child(center)
	var card_panel := PanelContainer.new()
	card_panel.custom_minimum_size = Vector2(540, 0)
	card_panel.add_theme_stylebox_override("panel", panel())
	center.add_child(card_panel)
	_card = VBoxContainer.new()
	_card.add_theme_constant_override("separation", 18)
	card_panel.add_child(_card)
	_overlay.hide()

func set_status(text: String) -> void: _status.text = text
func _request_shot() -> void:
	if power > 0.0:
		shoot_requested.emit(power, selected_spin)
func set_can_shoot(value: bool) -> void:
	_can_shoot = value
	_refresh_shoot_enabled()
func _refresh_shoot_enabled() -> void:
	if is_instance_valid(_shoot): _shoot.disabled = not _can_shoot or power <= 0.0
func set_score(title: String, detail: String, mode: String) -> void:
	_score.text = title; _detail.text = detail; _mode_label.text = mode
func select_call(number: int, pocket: int) -> void:
	called_ball = number; called_pocket = pocket
	if is_instance_valid(_call_ball): _call_ball.select(clampi(number-1,0,14))
	if is_instance_valid(_call_pocket): _call_pocket.select(pocket)
func reset_spin() -> void:
	selected_spin = Vector2.ZERO; _spin.spin = Vector2.ZERO; _spin.queue_redraw()
	spin_changed.emit(Vector2.ZERO)
func menu_visible() -> bool: return _overlay.visible
func hide_menu() -> void: _overlay.hide()
func _clear_card() -> void:
	for child in _card.get_children(): _card.remove_child(child); child.queue_free()
func show_home(can_resume: bool = false) -> void:
	_clear_card(); _overlay.show()
	_card.add_child(label("L O N G   R A I L", 36, Color("e9d9b8")))
	_card.add_child(label("A quiet room. A precise stroke. One more rack.", 16, Color("b6b9aa")))
	if can_resume: _card.add_child(button("Return to the table", func(): hide_menu(); resume_requested.emit(), true))
	_card.add_child(button("Start a fresh rack", func(): hide_menu(); mode_requested.emit("practice"), true))
	_card.add_child(label("Pure practice • Offline • 9-foot table\nClick and drag on the cloth to aim; release to retain.\nUse power and tip position to shape the shot.\nFor ball in hand, click a clear place on the cloth.", 13, Color("9da898")))
	_card.add_child(button("Quit", func(): get_tree().quit()))
func show_choices(title: String, detail: String, choices: Array, callback: Callable) -> void:
	_clear_card(); _overlay.show()
	_card.add_child(label(title, 28, Color("e9d9b8")))
	var text := label(detail, 15); text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.custom_minimum_size.x = 480; _card.add_child(text)
	for choice in choices:
		_card.add_child(button(choice["label"], func(): hide_menu(); callback.call(choice["id"])))

func label(text: String, pixels: int, color: Color = Color("eee7d8")) -> Label:
	var value := Label.new(); value.text = text
	value.add_theme_font_size_override("font_size", pixels)
	value.add_theme_color_override("font_color", color)
	return value
func button(text: String, action: Callable, primary: bool = false) -> Button:
	var value := Button.new(); value.focus_mode = Control.FOCUS_NONE; value.text = text; value.custom_minimum_size.y = 40
	value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value.add_theme_font_size_override("font_size", 14)
	value.add_theme_color_override("font_color", Color("18251e") if primary else Color("e2d9c6"))
	for state in ["normal", "hover", "pressed", "disabled"]:
		var style := StyleBoxFlat.new()
		style.bg_color = (Color("c9ac73") if primary else Color("233c33")).lightened(.12 if state=="hover" else 0)
		if state=="disabled": style.bg_color = Color("526052")
		style.corner_radius_top_left = 7; style.corner_radius_top_right = 7
		style.corner_radius_bottom_left = 7; style.corner_radius_bottom_right = 7
		style.content_margin_left = 15; style.content_margin_right = 15
		value.add_theme_stylebox_override(state, style)
	value.pressed.connect(action)
	return value
func panel() -> StyleBoxFlat:
	var style := StyleBoxFlat.new(); style.bg_color = Color("101f1c")
	style.border_color = Color("625940"); style.set_border_width_all(1)
	style.set_corner_radius_all(12); style.content_margin_left = 24; style.content_margin_right = 24
	style.content_margin_top = 24; style.content_margin_bottom = 24
	return style
