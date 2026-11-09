extends SceneTree

class PairOracle extends PhysicsStepper:
	var post: Dictionary = {}
	var pre_tangent: Dictionary = {}
	var first_ball: BallState
	var second_ball: BallState
	func _resolve_ball_pair(a: BallState, b: BallState, c: PhysicsConfig, separation: Vector3, relative: Vector3, dt: float) -> bool:
		first_ball = a
		second_ball = b
		var waiting := post.is_empty()
		var result := super._resolve_ball_pair(a, b, c, separation, relative, dt)
		if waiting and not pre_tangent.is_empty(): post = {a.number: a.velocity, b.number: b.velocity}
		return result
	func _record_event(event: Dictionary) -> void:
		super._record_event(event)
		if event.kind == "ball_contact" and pre_tangent.is_empty(): pre_tangent = {first_ball.number: first_ball.velocity, second_ball.number: second_ball.velocity}

var checks := 0
var failures := 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		printerr("FAIL: " + message)
func _initialize() -> void: call_deferred("run")
func pair(degrees: float) -> Array:
	return [BallState.new(0, 0, -Vector2.from_angle(deg_to_rad(degrees)) * 2.0 * BallState.RADIUS - Vector2(0.05, 0.0)), BallState.new(1, 1, Vector2.ZERO)]
func prediction(layout: Array, config: PhysicsConfig, spin: Vector2 = Vector2.ZERO, speed: float = 1.4) -> Dictionary:
	var guide := OutgoingGuide.new()
	guide.begin(layout, Vector2.RIGHT, speed, spin, config, TableSpec.new())
	while not guide.done: guide.advance(32, 0)
	check(guide.result.status == "predicted", "valid pair prediction")
	return guide.result
func ratio(view: TablePresentation, result: Dictionary) -> void:
	view.set_outgoing_guide(result)
	var paths: Array = view.momentum_geometry.paths
	var speeds := [result.impact_cue_velocity.length(), result.impact_object_velocity.length()]
	if speeds[0] < 1.0e-9:
		check(paths[0].is_empty(), "zero momentum has no fabricated vector")
	else:
		var first := view._screen_point(paths[0][0]).distance_to(view._screen_point(paths[0][1]))
		var second := view._screen_point(paths[1][0]).distance_to(view._screen_point(paths[1][1]))
		check(absf(first / second - speeds[0] / speeds[1]) < 0.0002, "rendered projected centerline ratio equals speed ratio")
		print("PROJECTED lengths=", first, "/", second, " speed ratio=", speeds[0] / speeds[1], " limit=", view.momentum_geometry.common_factor)
func key(code: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	root.push_input(event, true)
	await process_frame
	event = InputEventKey.new()
	event.keycode = code
	root.push_input(event, true)
	await process_frame
func run() -> void:
	root.size = Vector2i(1100, 700)
	root.content_scale_size = root.size
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	var game = load("res://scenes/main.tscn").instantiate()
	game.session_path = "/tmp/proportional-guide-session.json"
	var prefs := "/tmp/proportional-guide-settings-%d.cfg" % Time.get_ticks_usec()
	game.get_node("GameHUD").guide_settings_path = prefs
	root.add_child(game)
	await process_frame
	game.set_process(false)
	game.hud.hide_menu()
	await game.table_view._camera_tween.finished
	var ideal := PhysicsConfig.new()
	ideal.ball_restitution = 1.0
	ideal.ball_friction = 0.0
	ideal.sliding_friction = 0.0
	ideal.rolling_resistance = 0.0
	ideal.spinning_friction = 0.0
	for degrees in [0.0, 15.0, 30.0, 45.0, 60.0, 75.0]:
		var result := prediction(pair(degrees), ideal)
		var incoming: float = result.impact_incoming_speed
		check(absf(result.impact_cue_velocity.length() - incoming * sin(deg_to_rad(degrees))) < 0.0002, "independent sin ideal speed")
		check(absf(result.impact_object_velocity.length() - incoming * cos(deg_to_rad(degrees))) < 0.0002, "independent cos ideal speed")
		check((result.impact_cue_velocity + result.impact_object_velocity - Vector2.RIGHT * incoming).length() < 0.000002, "independent vector momentum identity")
		for overhead in [true, false]:
			game.table_view.set_overhead(overhead)
			await game.table_view._camera_tween.finished
			for multiplier in [0.25, 1.5, 3.0]:
				game.table_view.set_guide_length(multiplier)
				ratio(game.table_view, result)
	var timing_difference := 0.0
	var tick_difference := 0.0
	for spin in [Vector2(-0.4, -0.3), Vector2(0.4, 0.3), Vector2.ZERO]:
		var config := PhysicsConfig.new()
		var layout := pair(30.0)
		layout[0].position.x += 0.049999
		var result := prediction(layout, config, spin, 8.0)
		CueStrikeModel.new().apply(layout[0], Vector2.RIGHT, 8.0, spin, 0.0, config)
		var oracle := PairOracle.new()
		for unused in range(1920):
			oracle.step_fixed(layout, config.fixed_step, config, TableSpec.new())
			if not oracle.post.is_empty(): break
		check(result.impact_cue_velocity.distance_to(oracle.post[0]) < 1.0e-7, "independent pair observer cue velocity parity")
		check(result.impact_object_velocity.distance_to(oracle.post[1]) < 1.0e-7, "independent pair observer target velocity parity")
		timing_difference = maxf(timing_difference, oracle.post[0].distance_to(oracle.pre_tangent[0]))
		tick_difference = maxf(tick_difference, maxf(oracle.post[0].distance_to(layout[0].velocity), oracle.post[1].distance_to(layout[1].velocity)))
		print("TIMING CASE ", spin, " incoming=", result.impact_incoming_speed, " post=", oracle.post, " tick=", layout[0].velocity, "/", layout[1].velocity, " phase=", layout[0].phase)
	check(timing_difference > 0.001, "sensitive signed-spin case rejects pre-tangential sample")
	check(tick_difference > 0.001, "sensitive case rejects tick-end sample")
	print("TIMING pre-tangent delta=", timing_difference, " tick-end delta=", tick_difference)
	var result := prediction(pair(30.0), ideal, Vector2.ZERO, 8.0)
	var old_lengths := [path_length(result.cue_path), path_length(result.object_path)]
	print("PRESERVED OLD EQUAL-CAP FAILURE: old lengths=", old_lengths, " true speed ratio=", result.impact_cue_velocity.length() / result.impact_object_velocity.length())
	check(absf(old_lengths[0] - old_lengths[1]) < 0.00001 and absf(result.impact_cue_velocity.length() / result.impact_object_velocity.length() - 1.0) > 0.2, "old equal-cap counterexample retained")
	# Force a third-ball obstruction on the target ray; shared factor must shrink cue too.
	result.blockers = [result.impact_centers[1] + result.impact_object_velocity.normalized() * 0.12]
	game.table_view.set_guide_length(3.0)
	ratio(game.table_view, result)
	check(game.table_view.momentum_geometry.limited, "unrelated ball applies shared clipping")
	result.blockers = []
	for center in [Vector2(1.1, 0.3), Vector2(0.0, 0.55)]:
		var shift: Vector2 = center - result.impact_centers[1]
		result.impact_centers[0] += shift
		result.impact_centers[1] += shift
		ratio(game.table_view, result)
		check(game.table_view.momentum_geometry.limited, "rail or pocket boundary applies shared clipping")
	var pocket := prediction(pair(30.0), ideal)
	pocket.impact_centers = {0: Vector2(-0.02, 0.48), 1: Vector2(0.0, 0.55)}
	pocket.impact_cue_velocity = Vector2(0.0, 0.5)
	pocket.impact_object_velocity = Vector2.DOWN
	ratio(game.table_view, pocket)
	check(game.table_view.momentum_geometry.limited, "open side-pocket fall edge clips both vectors")
	var pocket_path: PackedVector2Array = game.table_view.momentum_geometry.paths[1]
	var fall_distance: float = game.table_view._first_rail_distance(pocket.impact_centers[1], Vector2.DOWN)
	check(pocket_path[0].distance_to(pocket_path[1]) <= fall_distance - 0.0019, "target endpoint remains before shared pocket fall geometry")
	# Near-zero speeds have no display floor, and unconstrained magnification scales both.
	var tiny := prediction(pair(30.0), ideal)
	tiny.impact_cue_velocity *= 0.0001
	game.table_view.set_guide_length(0.25)
	ratio(game.table_view, tiny)
	var tiny_path: PackedVector2Array = game.table_view.momentum_geometry.paths[0]
	var tiny_pixels: float = game.table_view._screen_point(tiny_path[0]).distance_to(game.table_view._screen_point(tiny_path[1]))
	check(tiny_pixels > 0.0 and tiny_pixels < 0.01, "near-zero vector remains subpixel without a display length floor")
	var scaled := prediction(pair(30.0), ideal)
	game.table_view.set_guide_length(0.25)
	game.table_view.set_outgoing_guide(scaled)
	var path: PackedVector2Array = game.table_view.momentum_geometry.paths[0]
	var short_pixels: float = game.table_view._screen_point(path[0]).distance_to(game.table_view._screen_point(path[1]))
	game.table_view.set_guide_length(0.5)
	path = game.table_view.momentum_geometry.paths[0]
	check(absf(game.table_view._screen_point(path[0]).distance_to(game.table_view._screen_point(path[1])) / short_pixels - 2.0) < 0.0002, "common magnification doubles unconstrained centerlines")
	game.balls.assign(pair(30.0))
	game._placing = false
	game._last_aim_state.clear()
	for unused in range(100): game._refresh_aim()
	var cached = game._guide_prediction
	game.hud.guide_length_changed.emit(0.5)
	game._refresh_aim()
	check(game._guide_prediction == cached, "length edits rerender cached vectors without replay restart")
	root.size = Vector2i(1600, 900)
	root.content_scale_size = root.size
	await process_frame
	game._refresh_aim()
	game.table_view._process(0.0)
	check(game._guide_prediction == cached, "resize rerenders cached vectors without replay restart")
	ratio(game.table_view, scaled)
	var aim: Vector2 = game.aim_direction
	var power: float = game.power
	var strokes: int = game._strokes
	game._open_menu()
	await process_frame
	# Traverse actual menu focus to Guide length then activate through Viewport input.
	for unused in range(2): await key(KEY_TAB)
	check(root.gui_get_focus_owner().text == "Guide length", "guide length is keyboard reachable from menu")
	await key(KEY_ENTER)
	check(root.gui_get_focus_owner() == game.hud._guide_length_slider, "settings slider receives modal focus")
	var previous: float = game.hud.guide_length
	await key(KEY_RIGHT)
	check(absf(game.hud.guide_length - previous - 0.05) < 0.00001, "actual keyboard slider route adjusts length")
	await key(KEY_TAB)
	check(root.gui_get_focus_owner().text == "Back", "settings Back is reachable in modal traversal")
	await key(KEY_ENTER)
	check(game.hud.menu_visible(), "Back returns to menu")
	await key(KEY_ESCAPE)
	check(not game.hud.menu_visible(), "Escape closes settings")
	check(game.aim_direction == aim and game.power == power and game._strokes == strokes and not game._stroke_pending, "settings retain aim power and stroke count")
	var isolated := GameHUD.new()
	isolated.guide_settings_path = prefs
	isolated._load_guide_settings()
	check(isolated.guide_length == game.hud.guide_length, "dedicated preference persists in isolated file")
	for row in [[0.273, 0.25], [-10.0, 0.25], [10.0, 3.0]]:
		var config := ConfigFile.new()
		config.set_value("guides", "length", row[0])
		config.save(prefs)
		isolated._load_guide_settings()
		check(absf(isolated.guide_length - row[1]) < 0.00001, "loaded preference clamps and snaps to slider quantum")
	check(game.aim_direction == aim and game.power == power and game._strokes == strokes, "loading isolated preferences preserves live gameplay inputs")
	for invalid in ["bad", NAN, INF]:
		var config := ConfigFile.new()
		config.set_value("guides", "length", invalid)
		config.save(prefs)
		isolated.guide_length = 1.5
		isolated._load_guide_settings()
		check(isolated.guide_length == 1.5, "malformed preference safely retains default")
	isolated.free()
	DirAccess.remove_absolute(prefs)
	game.queue_free()
	await process_frame
	print("PROPORTIONAL GUIDES: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
func path_length(path: PackedVector2Array) -> float:
	var length := 0.0
	for index in range(1, path.size()): length += path[index].distance_to(path[index - 1])
	return length
