extends Node3D
class_name GameController

const AudioScript = preload("res://scripts/presentation/table_audio.gd")
@onready var table_view: TablePresentation = $TablePresentation
@onready var hud: GameHUD = $GameHUD
var table := TableSpec.new()
var physics_config := PhysicsConfig.new()
var stepper := PhysicsStepper.new()
var strike_model := CueStrikeModel.new()
var balls: Array[BallState] = []
var aim_direction := Vector2.RIGHT
var power := .42
var spin := Vector2.ZERO
var _shot_in_motion := false
var _stroke_pending := false
var _shot_generation := 0
var _placing := false
var _aim_gesture := false
var _placement_cursor := Vector2.ZERO
var _placement_cursor_active := false
var _guides := true
var _overhead := true
var _undo: Array[BallState] = []
var _undo_strokes := 0
var _undo_pots := 0
var _strokes := 0
var _pots := 0
var session_path := "user://practice.json"
var _last_aim_state: Array = []
var _audio: TableAudio
const StrokePowerModel = preload("res://scripts/sim/stroke_power.gd")

func _ready() -> void:
	Engine.max_fps = 60
	table_view.build(table)
	table_view.set_overhead(true)
	_audio = AudioScript.new(); add_child(_audio)
	hud.shoot_requested.connect(_on_shoot_requested)
	hud.rack_requested.connect(_new_rack)
	hud.mode_requested.connect(func(_mode: String): _new_rack())
	hud.power_changed.connect(func(value: float): power = value)
	hud.spin_changed.connect(func(value: Vector2): spin = value)
	hud.undo_requested.connect(_undo_shot)
	hud.menu_requested.connect(_open_menu)
	hud.view_requested.connect(_toggle_view)
	hud.sound_changed.connect(func(value: bool): _audio.enabled = value)
	hud.guide_changed.connect(func(value: bool): _guides = value; _refresh_aim())
	hud.play_area_changed.connect(_on_play_area_changed)
	_new_rack(false)
	var resumed := _load_session()
	hud.show_home(resumed)
	get_tree().auto_accept_quit = false

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_session(); get_tree().quit()
	elif what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		_cancel_aim_gesture()
		_cancel_pending_stroke()

func _process(delta: float) -> void:
	if hud.menu_visible() or _stroke_pending: return
	if _shot_in_motion:
		stepper.advance(balls, delta, physics_config, table)
		for event in stepper.drain_events():
			match event["kind"]:
				"ball_contact": _audio.play_contact("ball", event["speed"])
				"rail": _audio.play_contact("rail", event["speed"])
				"pocket":
					_audio.play_contact("pocket", maxf(1.0,event["speed"]))
					if event["number"] != 0: _pots += 1
		if stepper.are_balls_settled(balls, physics_config):
			_shot_in_motion = false
			_placing = not _cue_ball().is_on_table()
			_placement_cursor_active = false
			if _placing: get_viewport().gui_release_focus()
			hud.set_status("Cue ball in hand. Click clear cloth, or use arrows and Enter to place." if _placing else "A measured stroke. Line up the next one.")
			if _pots == 15: hud.set_status("Table cleared. Beautifully played. Start a fresh rack from the menu.")
			_save_session()
		table_view.sync_balls(balls)
		_update_score()
	_refresh_aim()

func _input(event: InputEvent) -> void:
	# Observe releases before GUI controls can consume them; presses still start only
	# in _unhandled_input, after the GUI has had its normal chance to handle them.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_cancel_aim_gesture()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_ESCAPE:
				if hud.menu_visible(): hud.hide_menu()
				elif not hud.release_control_focus(): _open_menu()
			KEY_SPACE:
				if not hud.menu_visible(): _on_shoot_requested(power,spin)
			KEY_U: _undo_shot()
			KEY_V: _toggle_view()
			KEY_P:
				if not _shot_in_motion and not _stroke_pending and not _placing: hud.focus_power()
			KEY_S:
				if not _shot_in_motion and not _stroke_pending and not _placing: hud.focus_spin()
			KEY_TAB:
				if not _shot_in_motion and not _stroke_pending and not _placing and not hud.menu_visible() and get_viewport().gui_get_focus_owner() == null:
					hud.focus_practice_controls(event.shift_pressed)
			KEY_ENTER, KEY_KP_ENTER:
				if _placing and not hud.menu_visible():
					_ensure_placement_cursor()
					_place_cue(_placement_cursor)
			KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN:
				if _placing and not hud.menu_visible():
					_move_placement_cursor(event.keycode, event.shift_pressed)
				elif event.keycode in [KEY_LEFT, KEY_RIGHT] and not _shot_in_motion and not _stroke_pending and not _aim_gesture and not hud.menu_visible():
					aim_direction = aim_direction.rotated((-.001 if event.keycode==KEY_LEFT else .001) * (.2 if event.shift_pressed else 1.0))
	if hud.menu_visible() or _shot_in_motion or _stroke_pending: return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _placing:
			_place_cue(table_view.project_mouse_to_table(event.position,BallState.RADIUS))
		elif not _aim_gesture and _begin_aim_gesture(event.position):
			_aim_gesture = true
	elif event is InputEventMouseMotion:
		if _placing:
			_placement_cursor = table_view.project_mouse_to_table(event.position, BallState.RADIUS)
			_placement_cursor_active = true
			hud.set_status("Click or Enter to place the cue ball." if _can_place_cue(_placement_cursor) else "No room here. Move to clear cloth.")
			_refresh_aim()
		elif _aim_gesture:
			if (event.button_mask & MOUSE_BUTTON_MASK_LEFT) == 0:
				_cancel_aim_gesture()
			else:
				_update_aim_from_pointer(event.position)

func _begin_aim_gesture(screen_position: Vector2) -> bool:
	var target := table_view.project_mouse_to_table(screen_position,BallState.RADIUS)
	if not _is_playable_cloth_position(target): return false
	hud.release_control_focus()
	_update_aim_direction(target)
	return true

func _update_aim_from_pointer(screen_position: Vector2) -> void:
	var target := table_view.project_mouse_to_table(screen_position,BallState.RADIUS)
	if _is_playable_cloth_position(target): _update_aim_direction(target)

func _is_playable_cloth_position(position: Vector2) -> bool:
	return not table.outside_table(position) and table.pocket_at(position) < 0

func _update_aim_direction(target: Vector2) -> void:
	var difference := target-_cue_ball().position
	if difference.length_squared() > .0004: aim_direction=difference.normalized()

func _cancel_aim_gesture() -> void:
	_aim_gesture = false

func _open_menu() -> void:
	_cancel_pending_stroke()
	_cancel_aim_gesture()
	hud.show_home(true)

func _on_play_area_changed(area: Rect2) -> void:
	_cancel_aim_gesture()
	_last_aim_state.clear()
	table_view.set_play_area(area)

func _refresh_aim() -> void:
	table_view.set_play_area(hud.table_area_rect())
	hud.set_can_shoot(not _shot_in_motion and not _placing and not _stroke_pending)
	if _placing:
		_ensure_placement_cursor()
		table_view.set_aim(balls, aim_direction, _cue_ball(), power, false)
		table_view.set_placement_preview(_placement_cursor, _can_place_cue(_placement_cursor))
		return
	_placement_cursor_active = false
	var state: Array = [aim_direction, _cue_ball().position, power, spin, _shot_in_motion, _placing, _stroke_pending, _guides]
	if state == _last_aim_state: return
	_last_aim_state = state
	table_view.set_aim(balls,aim_direction,_cue_ball(),power,not _shot_in_motion and not _placing and not _stroke_pending, spin, _launch_direction(aim_direction, power, spin))
	if "_aim_mesh" in table_view and not _guides: table_view._aim_mesh.hide(); table_view._ghost_ball.hide()

func _new_rack(persist: bool = true) -> void:
	table_view.cancel_stroke()
	_cancel_aim_gesture()
	_shot_generation += 1
	_last_aim_state.clear()
	balls = RackBuilder.create_eight_ball_rack(table)
	stepper=PhysicsStepper.new(); _shot_in_motion=false; _stroke_pending=false; _placing=false
	_placement_cursor_active = false
	_undo.clear(); _strokes=0; _pots=0
	hud.reset_spin(); hud.set_status("Click and drag on the cloth to aim. Release to retain your line.")
	table_view.sync_balls(balls); _refresh_aim(); _update_score()
	if persist: _save_session()

func _launch_direction(direction: Vector2, selected_power: float, selected_spin: Vector2) -> Vector2:
	var preview := _cue_ball().duplicate_state()
	# A separate strike model keeps preview diagnostics out of the actual shot.
	if CueStrikeModel.new().apply(preview, direction, StrokePowerModel.cue_speed(selected_power), selected_spin, 0.0, physics_config):
		return preview.velocity.normalized()
	return direction

func _on_shoot_requested(selected_power: float, selected_spin: Vector2) -> void:
	if _shot_in_motion or _stroke_pending or _placing or hud.menu_visible(): return
	var shot_speed := StrokePowerModel.cue_speed(selected_power)
	if shot_speed <= 0.0 or not selected_spin.is_finite() or selected_spin.length() > CueStrikeModel.MAX_TIP_OFFSET + 1.0e-6: return
	_cancel_aim_gesture()
	hud.release_control_focus()
	power = clampf(selected_power, 0.0, 1.0)
	spin = selected_spin
	var shot_direction := aim_direction
	_undo = _copy_balls(balls)
	_undo_strokes = _strokes
	_undo_pots = _pots
	var generation := _shot_generation
	# Prepare the visible contact from the same frozen inputs as the strike.
	table_view.set_aim(balls, shot_direction, _cue_ball(), power, true, selected_spin, _launch_direction(shot_direction, power, selected_spin))
	if not _guides:
		table_view._aim_mesh.hide()
		table_view._ghost_ball.hide()
	_stroke_pending = true
	hud.set_can_shoot(false)
	table_view.play_stroke(func():
		if generation != _shot_generation or not _stroke_pending: return
		_stroke_pending = false
		if hud.menu_visible():
			_last_aim_state.clear()
			return
		if strike_model.apply(_cue_ball(), shot_direction, shot_speed, selected_spin, 0.0, physics_config):
			_strokes += 1
			_shot_in_motion = true
			_audio.play_contact("cue", shot_speed)
			hud.set_status("Watch the cue ball. Let the table settle.")
		_refresh_aim()
	)

func _cancel_pending_stroke() -> void:
	if not _stroke_pending: return
	_shot_generation += 1
	table_view.cancel_stroke()
	_stroke_pending = false
	_last_aim_state.clear()
	_refresh_aim()

func _can_place_cue(at: Vector2) -> bool:
	if not at.is_finite() or not table.is_supported(at): return false
	var bound := table.half_size - Vector2.ONE*(BallState.RADIUS+.008)
	if absf(at.x)>bound.x or absf(at.y)>bound.y: return false
	for ball in balls:
		if ball.number!=0 and ball.is_on_table() and ball.position.distance_to(at)<BallState.RADIUS*2.05: return false
	var nose_offset := table.cushion_nose_height - BallState.RADIUS
	var clearance := sqrt(maxf(0.0, BallState.RADIUS * BallState.RADIUS - nose_offset * nose_offset))
	for segment in table.rail_segments():
		if at.distance_to(Geometry2D.get_closest_point_to_segment(at, segment.a, segment.b)) < clearance:
			return false
	return true

func _ensure_placement_cursor() -> void:
	if _placement_cursor_active: return
	_placement_cursor_active = true
	hud.set_status("Cue ball in hand. Click clear cloth, or use arrows and Enter to place.")
	_placement_cursor = Vector2(-table.half_size.x * 0.5, 0.0)
	if _can_place_cue(_placement_cursor): return
	for x in range(-10, 11):
		for z in range(-4, 5):
			var point := Vector2(x * 0.1, z * 0.1)
			if _can_place_cue(point):
				_placement_cursor = point
				return

func _move_placement_cursor(keycode: Key, fine: bool) -> void:
	_ensure_placement_cursor()
	var step := 0.001 if fine else 0.01
	match keycode:
		KEY_LEFT: _placement_cursor.x -= step
		KEY_RIGHT: _placement_cursor.x += step
		KEY_UP: _placement_cursor.y -= step
		KEY_DOWN: _placement_cursor.y += step
	var bound := table.half_size - Vector2.ONE * (BallState.RADIUS + 0.008)
	_placement_cursor = _placement_cursor.clamp(-bound, bound)
	hud.set_status("Enter places the cue ball." if _can_place_cue(_placement_cursor) else "No room here. Use arrows to find clear cloth.")
	_refresh_aim()

func _place_cue(at: Vector2) -> void:
	if not _can_place_cue(at): return
	var cue := _cue_ball(); cue.position=at; cue.height=BallState.RADIUS; cue.phase=BallState.Phase.IN_PLAY
	cue.velocity=Vector2.ZERO; cue.angular_velocity=Vector3.ZERO; cue.vertical_velocity=0; cue.pocket_id=-1
	_placing=false; _placement_cursor_active=false; hud.set_status("Cue ball placed. Find your next line.")
	_last_aim_state.clear()
	table_view.sync_balls(balls); _refresh_aim(); _save_session()

func _undo_shot() -> void:
	_cancel_aim_gesture()
	if _undo.is_empty() or _stroke_pending: return
	_last_aim_state.clear()
	balls=_copy_balls(_undo); _undo.clear(); _strokes=_undo_strokes; _pots=_undo_pots
	stepper=PhysicsStepper.new(); _shot_in_motion=false; _placing=not _cue_ball().is_on_table()
	_placement_cursor_active = false
	hud.set_status("Shot restored. Try a different line or touch.")
	table_view.sync_balls(balls); _refresh_aim(); _update_score(); _save_session()

func _toggle_view() -> void:
	if _stroke_pending: return
	_cancel_aim_gesture()
	_overhead=not _overhead
	table_view.set_overhead(_overhead)
func _update_score() -> void:
	hud.set_score("OPEN PRACTICE", "%02d strokes     /     %02d of 15 pocketed" % [_strokes,_pots],"THE PRACTICE ROOM  /  9-FOOT TABLE")
func _cue_ball() -> BallState:
	return balls[0] if not balls.is_empty() else null
func _copy_balls(source: Array[BallState]) -> Array[BallState]:
	var copy: Array[BallState]=[]
	for ball in source: copy.append(ball.duplicate_state())
	return copy

func _save_session() -> void:
	if balls.is_empty(): return
	var pending := _shot_in_motion or _stroke_pending
	var source: Array[BallState] = _undo if pending else balls
	if source.size() != 16: return
	var strokes := _undo_strokes if pending else _strokes
	var pots := _undo_pots if pending else _pots
	if not _save_counters_are_valid(strokes, pots): return
	var states: Array=[]
	var restored: Array[BallState]=[]
	for ball in source:
		var state := Array(ball.canonical_state())
		states.append(state)
		var candidate := _validated_saved_ball(state, restored.size())
		if candidate == null: return
		restored.append(candidate)
	if not _saved_balls_are_valid(restored): return
	var temporary_path := session_path + ".tmp"
	var file := FileAccess.open(temporary_path,FileAccess.WRITE)
	if file==null: return
	file.store_string(JSON.stringify({"version":1,"balls":states,"strokes":strokes,"pots":pots}))
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK: return
	# A failed rename leaves the previous destination intact; do not remove it first.
	var rename_error := DirAccess.rename_absolute(ProjectSettings.globalize_path(temporary_path), ProjectSettings.globalize_path(session_path))
	if rename_error != OK:
		push_warning("Could not replace saved session (error %d)." % rename_error)

func _load_session() -> bool:
	if not FileAccess.file_exists(session_path): return false
	var parser := JSON.new()
	if parser.parse(FileAccess.get_file_as_string(session_path)) != OK: return false
	var data = parser.data
	if not data is Dictionary: return false
	if not _save_integer_is_valid(data.get("version")) or data.version != 1 or not data.get("balls") is Array or data.balls.size() != 16: return false
	var strokes = data.get("strokes", 0)
	var pots = data.get("pots", 0)
	if not _save_counters_are_valid(strokes, pots): return false
	var restored: Array[BallState]=[]
	for state in data.balls:
		var ball := _validated_saved_ball(state, restored.size())
		if ball == null: return false
		restored.append(ball)
	if not _saved_balls_are_valid(restored): return false
	table_view.cancel_stroke()
	_shot_generation += 1
	_cancel_aim_gesture()
	_last_aim_state.clear()
	balls=restored;_strokes=strokes;_pots=pots;_placing=not _cue_ball().is_on_table()
	_placement_cursor_active = false
	_shot_in_motion=false;_stroke_pending=false;_undo.clear()
	table_view.sync_balls(balls);_refresh_aim();_update_score()
	return true

func _save_counters_are_valid(strokes: Variant, pots: Variant) -> bool:
	return _save_integer_is_valid(strokes) and _save_integer_is_valid(pots) and strokes >= 0 and strokes <= 9007199254740991 and pots >= 0 and pots <= 15

func _save_integer_is_valid(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value) == floor(float(value))

func _validated_saved_ball(state: Variant, expected_id: int) -> BallState:
	if not state is Array or state.size() != 17: return null
	for value in state:
		if not (value is float or value is int) or not is_finite(float(value)): return null
	for index in [0, 1, 15, 16]:
		if not _save_integer_is_valid(state[index]): return null
	var id := int(state[0])
	var number := int(state[1])
	var phase := int(state[15])
	var pocket_id := int(state[16])
	if id != expected_id or number < 0 or number > 15 or (expected_id == 0 and number != 0) or (expected_id > 0 and number == 0): return null
	if phase < BallState.Phase.IN_PLAY or phase > BallState.Phase.OFF_TABLE: return null
	# Version 1 stores no simulation clock. Only settled and terminal phases are recoverable.
	if phase == BallState.Phase.AIRBORNE or phase == BallState.Phase.FALLING: return null
	if phase == BallState.Phase.IN_PLAY and (absf(state[5]) > 0.00001 or absf(state[6]) > 0.00001 or absf(state[7]) > 0.00001 or absf(state[8]) > 0.00001 or absf(state[9]) > 0.00001 or absf(state[10]) > 0.00001): return null
	if phase == BallState.Phase.IN_PLAY and pocket_id != -1: return null
	if phase == BallState.Phase.POCKETED and (pocket_id < 0 or pocket_id > 5 or state[4] > BallState.OFF_TABLE_TERMINAL_HEIGHT + 0.001): return null
	if phase == BallState.Phase.OFF_TABLE and (pocket_id != -1 or absf(state[4] - BallState.OFF_TABLE_TERMINAL_HEIGHT) > 0.001 or absf(state[5]) > 0.00001 or absf(state[6]) > 0.00001 or absf(state[7]) > 0.00001 or absf(state[8]) > 0.00001 or absf(state[9]) > 0.00001 or absf(state[10]) > 0.00001): return null
	if phase == BallState.Phase.IN_PLAY and absf(state[4] - BallState.RADIUS) > 0.001: return null
	var position := Vector2(state[2], state[3])
	if phase == BallState.Phase.IN_PLAY and not table.is_supported(position): return null
	if phase == BallState.Phase.IN_PLAY:
		var nose_offset := table.cushion_nose_height - BallState.RADIUS
		var clearance := sqrt(maxf(0.0, BallState.RADIUS * BallState.RADIUS - nose_offset * nose_offset))
		for segment in table.rail_segments():
			var closest := Geometry2D.get_closest_point_to_segment(position,segment.a,segment.b)
			if position.distance_to(closest) < clearance - 0.0001: return null
	var terminal_margin := table.pocket_depth + 0.5
	if absf(position.x) > table.half_size.x + terminal_margin or absf(position.y) > table.half_size.y + terminal_margin: return null
	if phase == BallState.Phase.OFF_TABLE and not table.outside_table(position): return null
	var orientation := Quaternion(state[11],state[12],state[13],state[14])
	if orientation.length_squared() < .5 or orientation.length_squared() > 1.5: return null
	var ball := BallState.new(id, number, position)
	ball.height=state[4];ball.velocity=Vector2(state[5],state[6]);ball.vertical_velocity=state[7]
	ball.angular_velocity=Vector3(state[8],state[9],state[10]);ball.orientation=orientation.normalized()
	ball.phase=phase;ball.pocket_id=pocket_id
	return ball

func _saved_balls_are_valid(saved: Array[BallState]) -> bool:
	if saved.size() != 16: return false
	var numbers: Dictionary = {}
	for index in range(saved.size()):
		var ball := saved[index]
		if ball.id != index or numbers.has(ball.number): return false
		numbers[ball.number] = true
		if ball.phase != BallState.Phase.IN_PLAY: continue
		for other_index in range(index):
			var other := saved[other_index]
			if other.phase == BallState.Phase.IN_PLAY and ball.position.distance_to(other.position) < BallState.RADIUS * 2.0 - 0.00001: return false
	return numbers.size() == 16 and saved[0].number == 0
