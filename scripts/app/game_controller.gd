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
	hud.view_requested.connect(_toggle_view)
	hud.sound_changed.connect(func(value: bool): _audio.enabled = value)
	hud.guide_changed.connect(func(value: bool): _guides = value; _refresh_aim())
	_new_rack(false)
	var resumed := _load_session()
	hud.show_home(resumed)
	get_tree().auto_accept_quit = false

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_session(); get_tree().quit()

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
			hud.set_status("Cue ball in hand. Click a clear place on the cloth." if _placing else "A measured stroke. Line up the next one.")
			if _pots == 15: hud.set_status("Table cleared. Beautifully played. Start a fresh rack from the menu.")
			_save_session()
		table_view.sync_balls(balls)
		_update_score()
	_refresh_aim()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_ESCAPE:
				if hud.menu_visible(): hud.hide_menu()
				else: hud.show_home(true)
			KEY_SPACE:
				if not hud.menu_visible(): _on_shoot_requested(power,spin)
			KEY_U: _undo_shot()
			KEY_V: _toggle_view()
			KEY_LEFT, KEY_RIGHT:
				if not _shot_in_motion and not _stroke_pending and not hud.menu_visible():
					aim_direction = aim_direction.rotated((-.001 if event.keycode==KEY_LEFT else .001) * (.2 if event.shift_pressed else 1.0))
	if hud.menu_visible() or _shot_in_motion or _stroke_pending: return
	if event is InputEventMouseMotion and not _placing:
		var target := table_view.project_mouse_to_table(event.position,BallState.RADIUS)
		var difference := target-_cue_ball().position
		if difference.length_squared() > .0004: aim_direction=difference.normalized()
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and _placing:
		_place_cue(table_view.project_mouse_to_table(event.position,BallState.RADIUS))

func _refresh_aim() -> void:
	hud.set_can_shoot(not _shot_in_motion and not _placing and not _stroke_pending)
	var state: Array = [aim_direction, _cue_ball().position, power, _shot_in_motion, _placing, _stroke_pending, _guides]
	if state == _last_aim_state: return
	_last_aim_state = state
	table_view.set_aim(balls,aim_direction,_cue_ball(),power,not _shot_in_motion and not _placing and not _stroke_pending)
	if "_aim_mesh" in table_view and not _guides: table_view._aim_mesh.hide(); table_view._ghost_ball.hide()

func _new_rack(persist: bool = true) -> void:
	_shot_generation += 1
	_last_aim_state.clear()
	balls = RackBuilder.create_eight_ball_rack(table)
	stepper=PhysicsStepper.new(); _shot_in_motion=false; _stroke_pending=false; _placing=false
	_undo.clear(); _strokes=0; _pots=0
	hud.reset_spin(); hud.set_status("Move the pointer to aim. Set the power. Make it count.")
	table_view.sync_balls(balls); _refresh_aim(); _update_score()
	if persist: _save_session()

func _on_shoot_requested(selected_power: float, selected_spin: Vector2) -> void:
	if _shot_in_motion or _stroke_pending or _placing or hud.menu_visible(): return
	power=selected_power; spin=selected_spin
	_undo = _copy_balls(balls); _undo_strokes=_strokes; _undo_pots=_pots
	var generation := _shot_generation
	_stroke_pending=true; hud.set_can_shoot(false)
	if table_view.has_method("play_stroke"): table_view.play_stroke()
	await get_tree().create_timer(.1).timeout
	if generation != _shot_generation: return
	_stroke_pending=false
	if hud.menu_visible():
		_last_aim_state.clear()
		return
	if strike_model.apply(_cue_ball(),aim_direction,.25+power*7.75,spin,0.0,physics_config):
		_strokes+=1; _shot_in_motion=true; _audio.play_contact("cue",1.5+power*3)
		hud.set_status("Watch the cue ball. Let the table settle.")
	_refresh_aim()

func _place_cue(at: Vector2) -> void:
	var bound := table.half_size - Vector2.ONE*(BallState.RADIUS+.008)
	if absf(at.x)>bound.x or absf(at.y)>bound.y: return
	for ball in balls:
		if ball.number!=0 and ball.is_on_table() and ball.position.distance_to(at)<BallState.RADIUS*2.05: return
	var cue := _cue_ball(); cue.position=at; cue.height=BallState.RADIUS; cue.phase=BallState.Phase.IN_PLAY
	cue.velocity=Vector2.ZERO; cue.angular_velocity=Vector3.ZERO; cue.vertical_velocity=0; cue.pocket_id=-1
	_placing=false; hud.set_status("Cue ball placed. Find your next line.")
	table_view.sync_balls(balls); _save_session()

func _undo_shot() -> void:
	if _undo.is_empty() or _stroke_pending: return
	_last_aim_state.clear()
	balls=_copy_balls(_undo); _undo.clear(); _strokes=_undo_strokes; _pots=_undo_pots
	stepper=PhysicsStepper.new(); _shot_in_motion=false; _placing=not _cue_ball().is_on_table()
	hud.set_status("Shot restored. Try a different line or touch.")
	table_view.sync_balls(balls); _refresh_aim(); _update_score(); _save_session()

func _toggle_view() -> void:
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
	var states: Array=[]
	var source := _undo if _shot_in_motion or _stroke_pending else balls
	for ball in source: states.append(Array(ball.canonical_state()))
	var file := FileAccess.open(session_path+".tmp",FileAccess.WRITE)
	if file==null: return
	file.store_string(JSON.stringify({"version":1,"balls":states,"strokes":_undo_strokes if _shot_in_motion else _strokes,"pots":_undo_pots if _shot_in_motion else _pots}))
	file.close()
	DirAccess.rename_absolute(session_path+".tmp",session_path)

func _load_session() -> bool:
	if not FileAccess.file_exists(session_path): return false
	var data = JSON.parse_string(FileAccess.get_file_as_string(session_path))
	if not data is Dictionary or data.get("version")!=1 or not data.get("balls") is Array or data.balls.size()!=16: return false
	var restored: Array[BallState]=[]
	var numbers: Dictionary = {}
	for state in data.balls:
		if not state is Array or state.size()!=17: return false
		for value in state:
			if not (value is float or value is int) or not is_finite(float(value)): return false
		if int(state[0])!=restored.size() or state[15]<0 or state[15]>4: return false
		var number := int(state[1])
		if number < 0 or number > 15 or numbers.has(number) or (restored.is_empty() and number != 0): return false
		numbers[number] = true
		if int(state[15]) in [BallState.Phase.AIRBORNE, BallState.Phase.FALLING]: return false
		if int(state[15]) == BallState.Phase.OFF_TABLE and state[4] > BallState.OFF_TABLE_TERMINAL_HEIGHT + .001: return false
		var orientation := Quaternion(state[11],state[12],state[13],state[14])
		if orientation.length_squared() < .5 or orientation.length_squared() > 1.5: return false
		var ball:=BallState.new(int(state[0]),int(state[1]),Vector2(state[2],state[3]))
		ball.height=state[4];ball.velocity=Vector2(state[5],state[6]);ball.vertical_velocity=state[7]
		ball.angular_velocity=Vector3(state[8],state[9],state[10]);ball.orientation=Quaternion(state[11],state[12],state[13],state[14]).normalized()
		ball.phase=int(state[15]);ball.pocket_id=int(state[16]);restored.append(ball)
	_last_aim_state.clear()
	balls=restored;_strokes=int(data.get("strokes",0));_pots=int(data.get("pots",0));_placing=not _cue_ball().is_on_table()
	table_view.sync_balls(balls);_refresh_aim();_update_score()
	return true
