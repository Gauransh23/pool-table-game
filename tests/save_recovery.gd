extends SceneTree

var checks := 0
var failures: Array[String] = []
var session_path := ""
var game: GameController

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	session_path = "user://save-recovery-%d-%d.json" % [Time.get_ticks_usec(), randi()]
	game = load("res://scenes/main.tscn").instantiate()
	game.session_path = session_path
	root.add_child(game)
	await process_frame
	game.set_process(false)
	game.hud.hide_menu()
	game._new_rack(false)
	game._strokes = 3
	game._pots = 2
	game._save_session()
	check(FileAccess.file_exists(session_path), "settled sixteen-ball session saves")
	var original := _state_snapshot()
	game.balls[1].position += Vector2(.02, 0)
	game._strokes = 20
	game._pots = 9
	check(game._load_session(), "valid v1 session loads")
	check(_snapshots_match(_state_snapshot(), original), "round trip restores all ball fields and counters")
	var shelf_state := _read_save()
	shelf_state.balls[1][2] = 0.0
	shelf_state.balls[1][3] = game.table.half_size.y - BallState.RADIUS + 0.001
	_write_save(shelf_state)
	check(game._load_session(), "settled ball in a pocket shelf region remains compatible")

	var cue_scratch := _read_save()
	cue_scratch.balls[0][4] = -0.13
	cue_scratch.balls[0][15] = BallState.Phase.POCKETED
	cue_scratch.balls[0][16] = 4
	_write_save(cue_scratch)
	check(game._load_session() and game._placing, "pocketed cue restores with ball in hand")

	game._new_rack(false)
	game._strokes = 4
	game._pots = 1
	var pre_stroke := _state_snapshot()
	game._undo = game._copy_balls(game.balls)
	game._undo_strokes = 4
	game._undo_pots = 1
	game._stroke_pending = true
	game._strokes = 5
	game.balls[1].position += Vector2(.04, 0)
	game._save_session()
	var pending_save := _read_save()
	check(pending_save.strokes == 4 and pending_save.pots == 1, "pending-stroke save pairs undo counters with undo balls")
	check(_ball_arrays_match(pending_save.balls, pre_stroke.balls), "pending-stroke save stores the settled pre-shot state")
	game._stroke_pending = false
	game._shot_in_motion = true
	game._save_session()
	pending_save = _read_save()
	check(_ball_arrays_match(pending_save.balls, pre_stroke.balls) and pending_save.strokes == 4, "moving-shot save stores the settled pre-shot state")
	game._shot_in_motion = false
	game._undo.clear()

	game._new_rack(false)
	game._strokes = 2
	game._pots = 0
	game._save_session()
	var good_text := FileAccess.get_file_as_string(session_path)
	var moving_save := _read_save()
	moving_save.balls[0][5] = 2.0
	_write_save(moving_save)
	var before_invalid := _state_snapshot()
	check(not game._load_session(), "moving IN_PLAY save is rejected")
	check(_state_snapshot() == before_invalid, "moving-save rejection leaves the live game unchanged")

	var invalid_mutations := [
		["boolean version", func(data): data.version = true],
		["overflowing stroke counter", func(data): data.strokes = 1.0e100],
		["fractional id", func(data): data.balls[1][0] = 1.5],
		["fractional phase", func(data): data.balls[1][15] = 0.5],
		["fractional pocket id", func(data): data.balls[1][16] = -1.5],
		["duplicate number", func(data): data.balls[1][1] = 0],
		["unsupported airborne phase", func(data): data.balls[1][15] = BallState.Phase.AIRBORNE],
		["invalid pocket id", func(data): data.balls[1][15] = BallState.Phase.POCKETED; data.balls[1][16] = 6],
		["out-of-table position", func(data): data.balls[1][2] = 10.0],
		["overlapping on-table balls", func(data): data.balls[1][2] = data.balls[0][2]; data.balls[1][3] = data.balls[0][3]],
		["fractional stroke counter", func(data): data.strokes = 1.5],
		["negative pot counter", func(data): data.pots = -1],
		["inconsistent terminal phase", func(data): data.balls[1][15] = BallState.Phase.OFF_TABLE; data.balls[1][4] = BallState.RADIUS],
	]
	for mutation in invalid_mutations:
		var malformed := _read_json_text(good_text)
		mutation[1].call(malformed)
		_write_save(malformed)
		var before := _state_snapshot()
		check(not game._load_session(), "rejects %s" % mutation[0])
		check(_state_snapshot() == before, "%s rejection leaves the live game unchanged" % mutation[0])

	_write_text("{\"version\":1,\"balls\":[")
	var before_truncated := _state_snapshot()
	check(not game._load_session(), "truncated JSON is rejected")
	check(_state_snapshot() == before_truncated, "truncated-file rejection leaves the live game unchanged")

	# A rejected in-memory moving state must not replace the last known-good file.
	_write_text(good_text)
	game.balls[0].velocity = Vector2(1, 0)
	game._save_session()
	check(FileAccess.get_file_as_string(session_path) == good_text, "save does not replace a good file with moving state")
	game.queue_free()
	await process_frame
	DirAccess.remove_absolute(ProjectSettings.globalize_path(session_path))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(session_path + ".tmp"))
	print("SAVE RECOVERY: %d checks, %d failures" % [checks, failures.size()])
	quit(1 if not failures.is_empty() else 0)

func check(condition: bool, description: String) -> void:
	checks += 1
	if condition:
		print("PASS: " + description)
	else:
		failures.append(description)
		printerr("FAIL: " + description)

func _state_snapshot() -> Dictionary:
	var states: Array = []
	for ball in game.balls:
		states.append(Array(ball.canonical_state()))
	return {"balls": states, "strokes": game._strokes, "pots": game._pots, "placing": game._placing}

func _snapshots_match(left: Dictionary, right: Dictionary) -> bool:
	return left.strokes == right.strokes and left.pots == right.pots and left.placing == right.placing and _ball_arrays_match(left.balls, right.balls)

func _ball_arrays_match(left: Array, right: Array) -> bool:
	if left.size() != right.size(): return false
	for ball_index in range(left.size()):
		if left[ball_index].size() != right[ball_index].size(): return false
		for value_index in range(left[ball_index].size()):
			if absf(float(left[ball_index][value_index]) - float(right[ball_index][value_index])) > 0.000001: return false
	return true

func _read_save() -> Dictionary:
	return _read_json_text(FileAccess.get_file_as_string(session_path))

func _read_json_text(contents: String) -> Dictionary:
	return JSON.parse_string(contents)

func _write_save(data: Dictionary) -> void:
	_write_text(JSON.stringify(data))

func _write_text(contents: String) -> void:
	var file := FileAccess.open(session_path, FileAccess.WRITE)
	file.store_string(contents)
	file.close()
