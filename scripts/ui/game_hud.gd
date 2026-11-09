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
signal guide_length_changed(value: float)
signal resume_requested
signal play_area_changed(area: Rect2)

var power := 0.42
var selected_spin := Vector2.ZERO
var called_ball := 1
var called_pocket := 0
var safety := false
var _prediction: Label
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
var _side: PanelContainer
var _footer: Label
var _focus_controls: Array[Control] = []
var _previous_focus: WeakRef
var guide_length := 1.5
var guide_settings_path := "user://guide-settings.cfg"
var _guide_length_slider: HSlider

func _load_guide_settings() -> void:
	var config := ConfigFile.new()
	if config.load(guide_settings_path) != OK: return
	var value = config.get_value("guides", "length", 1.5)
	if (value is float or value is int) and is_finite(float(value)):
		guide_length = snappedf(clampf(float(value), 0.25, 3.0), 0.05)

func _set_guide_length(value: float) -> void:
	if not is_finite(value): return
	guide_length = snappedf(clampf(value, 0.25, 3.0), 0.05)
	var config := ConfigFile.new()
	config.set_value("guides", "length", guide_length)
	var error := config.save(guide_settings_path)
	if error != OK: push_warning("Guide preference could not be saved: " + error_string(error))
	guide_length_changed.emit(guide_length)

func show_guide_length() -> void:
	_open_card()
	_card.add_child(label("Guide length", 28, Color("e9d9b8")))
	_card.add_child(label("Momentum at impact · ivory cue / dashed cyan target", 15))
	_card.add_child(label("Display magnification, independent of shot power.
Both vectors share one scale and one obstruction limit.
Follow/draw can curve later; these are not travel paths.", 14))
	var readout := label("%.2fx" % guide_length, 18)
	_card.add_child(readout)
	_guide_length_slider = HSlider.new()
	_guide_length_slider.name = "GuideLength"
	_guide_length_slider.min_value = 0.25
	_guide_length_slider.max_value = 3.0
	_guide_length_slider.step = 0.05
	_guide_length_slider.value = guide_length
	_guide_length_slider.custom_minimum_size = Vector2(460, 40)
	_guide_length_slider.tooltip_text = "Guide length: Left/Right adjusts 0.05x; Escape returns to table."
	var focus := Panel.new()
	focus.mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	focus.add_theme_stylebox_override("panel", focus_ring())
	_guide_length_slider.add_child(focus)
	focus.hide()
	_guide_length_slider.focus_entered.connect(focus.show)
	_guide_length_slider.focus_exited.connect(focus.hide)
	_guide_length_slider.value_changed.connect(func(value: float): readout.text = "%.2fx" % value; _set_guide_length(value))
	_card.add_child(_guide_length_slider)
	_card.add_child(button("Back", func(): show_home(true)))
	call_deferred("_focus_menu")


func _ready() -> void:
	_load_guide_settings()
	_build()
	_root.resized.connect(_layout_hud)
	_layout_hud()

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
	_side = side
	side.anchor_left = 1; side.anchor_right = 1
	side.offset_left = -310; side.offset_right = -24
	side.offset_top = 112; side.anchor_bottom = 1; side.offset_bottom = -60
	side.add_theme_stylebox_override("panel", panel())
	_root.add_child(side)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	side.add_child(column)
	column.add_child(label("THE STROKE", 12, Color("bda577")))
	_status = label("Click and drag on the cloth to aim. Release to retain your line.", 15)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.custom_minimum_size.y = 50
	column.add_child(_status)
	_prediction = label("", 12, Color("c4d9d9"))
	_prediction.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_prediction)
	var power_row := HBoxContainer.new()
	column.add_child(power_row)
	power_row.add_child(label("POWER", 11, Color("b6b9aa")))
	_readout = label("42%", 13)
	_readout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_readout.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	power_row.add_child(_readout)
	_power = HSlider.new()
	_power.focus_mode = Control.FOCUS_ALL
	_power.custom_minimum_size.y = 32
	# HSlider themes only highlight the grabber; draw an explicit focus outline.
	var power_focus := Panel.new()
	power_focus.mouse_filter = Control.MOUSE_FILTER_IGNORE
	power_focus.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	power_focus.add_theme_stylebox_override("panel", focus_ring())
	_power.add_child(power_focus)
	power_focus.hide()
	_power.focus_entered.connect(power_focus.show)
	_power.focus_exited.connect(power_focus.hide)
	_power.tooltip_text = "Power: Left/Right to adjust. Escape returns to table aim."
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
	var undo := button("Undo", func(): undo_requested.emit())
	var camera := button("Camera", func(): view_requested.emit())
	var menu := button("Menu", func(): menu_requested.emit())
	for action in [undo, camera, menu]: actions.add_child(action)
	var options := HBoxContainer.new()
	options.add_theme_constant_override("separation", 12)
	column.add_child(options)
	var sound := CheckBox.new()
	sound.focus_mode = Control.FOCUS_ALL
	sound.text = "Table sound"; sound.button_pressed = true
	sound.custom_minimum_size.y = 32
	sound.add_theme_font_size_override("font_size", 14)
	sound.add_theme_stylebox_override("focus", focus_ring())
	sound.toggled.connect(func(value: bool): sound_changed.emit(value))
	options.add_child(sound)
	var guides := CheckBox.new()
	guides.focus_mode = Control.FOCUS_ALL
	guides.text = "Momentum"
	guides.custom_minimum_size.y = 32
	guides.add_theme_font_size_override("font_size", 14)
	guides.add_theme_stylebox_override("focus", focus_ring())
	guides.tooltip_text = "Momentum at impact: ivory cue, dashed cyan target. Lengths show relative planar momentum with a common scale and shared obstruction limit. Follow/draw can curve later. Menu → Guide length adjusts display magnification. Clusters omitted."; guides.button_pressed = true
	guides.toggled.connect(func(value: bool): guide_changed.emit(value))
	options.add_child(guides)
	_focus_controls = [_power, _spin, _shoot, undo, camera, menu, sound, guides]
	var footer := label("Drag aim · Shift-drag fine aim · ← → adjust · P power · S tip · Space shoot · U undo · V view · Esc table/menu", 12, Color("bcc4b9"))
	_footer = footer
	footer.anchor_right = 1
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

func _layout_hud() -> void:
	_side.offset_top = 112 if _root.size.y >= 800 else 88
	_side.offset_bottom = -48
	_footer.offset_left = 24
	_footer.offset_right = -24
	play_area_changed.emit(table_area_rect())

func table_area_rect() -> Rect2:
	var top := _side.position.y
	return Rect2(24.0, top, maxf(1.0, _side.position.x - 48.0), maxf(1.0, _root.size.y - top - 48.0))

func focus_power() -> void:
	if not menu_visible(): _power.grab_focus()

func focus_practice_controls(backwards: bool = false) -> void:
	if not menu_visible():
		(_focus_controls[-1] if backwards else _power).grab_focus()

func focus_spin() -> void:
	if not menu_visible(): _spin.grab_focus()

func release_control_focus() -> bool:
	var owner := get_viewport().gui_get_focus_owner()
	if owner != null and not menu_visible() and _root.is_ancestor_of(owner):
		get_viewport().gui_release_focus()
		return true
	return false

func _open_card() -> void:
	if not menu_visible():
		var owner := get_viewport().gui_get_focus_owner()
		_previous_focus = weakref(owner) if owner != null else null
	for control in _focus_controls: control.focus_mode = Control.FOCUS_NONE
	_clear_card()
	_overlay.show()

func _focus_menu() -> void:
	if not menu_visible(): return
	var buttons: Array[Control] = []
	for child in _card.get_children():
		if child is Button or child is Range: buttons.append(child)
	for index in range(buttons.size()):
		var control := buttons[index]
		var next := buttons[(index + 1) % buttons.size()]
		var previous := buttons[(index - 1 + buttons.size()) % buttons.size()]
		control.focus_next = control.get_path_to(next)
		control.focus_previous = control.get_path_to(previous)
		control.focus_neighbor_top = control.focus_previous
		control.focus_neighbor_bottom = control.focus_next
	if not buttons.is_empty(): buttons[0].grab_focus()

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
func hide_menu() -> void:
	_overlay.hide()
	for control in _focus_controls: control.focus_mode = Control.FOCUS_ALL
	var previous = _previous_focus.get_ref() if _previous_focus != null else null
	_previous_focus = null
	if is_instance_valid(previous) and previous.is_visible_in_tree(): previous.grab_focus()
	else: get_viewport().gui_release_focus()
func _clear_card() -> void:
	for child in _card.get_children(): _card.remove_child(child); child.queue_free()
func show_home(can_resume: bool = false) -> void:
	_open_card()
	_card.add_child(label("L O N G   R A I L", 36, Color("e9d9b8")))
	_card.add_child(label("A quiet room. A precise stroke. One more rack.", 16, Color("b6b9aa")))
	if can_resume: _card.add_child(button("Return to the table", func(): hide_menu(); resume_requested.emit(), true))
	_card.add_child(button("Start a fresh rack", func(): hide_menu(); mode_requested.emit("practice"), true))
	_card.add_child(label("Pure practice • Offline • 9-foot table\nDrag cloth to aim; Shift-drag horizontally for fine aim.\nTab through controls, or P for power and S for tip position.\nEscape returns to table aim. After a scratch, arrows move\nthe cue-ball preview and Enter places it; a cloth click also works.", 13, Color("b6c0b6")))
	_card.add_child(button("Guide length", show_guide_length))
	_card.add_child(button("Sound credits", show_sound_credits))
	_card.add_child(button("Quit", func(): get_tree().quit()))
	call_deferred("_focus_menu")
func show_sound_credits() -> void:
	_open_card()
	_card.add_child(label("Sound credits", 28, Color("e9d9b8")))
	var credits := RichTextLabel.new()
	credits.name = "SoundCredits"
	credits.bbcode_enabled = true
	credits.custom_minimum_size = Vector2(480, 290)
	credits.add_theme_font_size_override("normal_font_size", 15)
	credits.text = "[b]KVV Audio[/b]\nRecorded cue hits, ball impacts and pocket drops.\n[url=https://freesound.org/people/KVV_Audio/sounds/851086/]Cue recording[/url] · [url=https://freesound.org/people/KVV_Audio/sounds/851087/]Ball recording[/url] · [url=https://freesound.org/people/KVV_Audio/sounds/851090/]Pocket recording[/url]\n[url=https://creativecommons.org/licenses/by/4.0/]Creative Commons Attribution 4.0[/url]\n\n[b]mccarthy@bedmas.com[/b]\n[url=https://freesound.org/people/mccarthy%40bedmas.com/sounds/42364/]Pool-ball-bounce-off-rail.wav[/url] · [url=https://creativecommons.org/publicdomain/zero/1.0/]CC0 1.0[/url]\n\nEdited for Long Rail: hits trimmed, downmixed,\nresampled, faded and gain matched.\nNo creator endorsement is implied."
	credits.meta_clicked.connect(func(link): OS.shell_open(str(link)))
	_card.add_child(credits)
	_card.add_child(button("Back", func(): show_home(true)))
	call_deferred("_focus_menu")

func show_choices(title: String, detail: String, choices: Array, callback: Callable) -> void:
	_open_card()
	_card.add_child(label(title, 28, Color("e9d9b8")))
	var text := label(detail, 15); text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.custom_minimum_size.x = 480; _card.add_child(text)
	for choice in choices:
		_card.add_child(button(choice["label"], func(): hide_menu(); callback.call(choice["id"])))
	call_deferred("_focus_menu")

func label(text: String, pixels: int, color: Color = Color("eee7d8")) -> Label:
	var value := Label.new(); value.text = text
	value.add_theme_font_size_override("font_size", maxi(12, pixels))
	value.add_theme_color_override("font_color", color)
	return value
func button(text: String, action: Callable, primary: bool = false) -> Button:
	var value := Button.new(); value.focus_mode = Control.FOCUS_ALL; value.text = text; value.custom_minimum_size.y = 40
	value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value.add_theme_font_size_override("font_size", 14)
	var foreground := Color("18251e") if primary else Color("e2d9c6")
	for state in ["font_color", "font_focus_color", "font_hover_color", "font_pressed_color"]:
		value.add_theme_color_override(state, foreground)
	for state in ["normal", "hover", "pressed", "disabled"]:
		var style := StyleBoxFlat.new()
		style.bg_color = (Color("c9ac73") if primary else Color("233c33")).lightened(.12 if state=="hover" else 0)
		if state=="disabled": style.bg_color = Color("526052")
		style.corner_radius_top_left = 7; style.corner_radius_top_right = 7
		style.corner_radius_bottom_left = 7; style.corner_radius_bottom_right = 7
		style.content_margin_left = 15; style.content_margin_right = 15
		value.add_theme_stylebox_override(state, style)
	value.add_theme_stylebox_override("focus", focus_ring())
	value.pressed.connect(action)
	return value
func panel() -> StyleBoxFlat:
	var style := StyleBoxFlat.new(); style.bg_color = Color("101f1c")
	style.border_color = Color("625940"); style.set_border_width_all(1)
	style.set_corner_radius_all(12); style.content_margin_left = 16; style.content_margin_right = 16
	style.content_margin_top = 16; style.content_margin_bottom = 16
	return style

func focus_ring() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color.TRANSPARENT
	style.border_color = Color("f4d492")
	style.set_border_width_all(2)
	style.set_corner_radius_all(7)
	return style

func set_prediction(text: String) -> void:
	_prediction.text = text
