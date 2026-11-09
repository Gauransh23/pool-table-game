extends SceneTree

var checks := 0
var failed := 0
var maximum_slice_usec := 0
var maximum_total_usec := 0

func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failed += 1
		printerr("FAIL: " + message)

func _initialize() -> void: call_deferred("run")

func predict(layout: Array, spin: Vector2 = Vector2.ZERO, speed: float = 1.4, direction: Vector2 = Vector2.RIGHT) -> OutgoingGuide:
	var guide := OutgoingGuide.new()
	guide.begin(layout, direction, speed, spin, PhysicsConfig.new(), TableSpec.new())
	var start := Time.get_ticks_usec()
	while not guide.done:
		var slice_start := Time.get_ticks_usec()
		var previous := guide.ticks
		guide.advance()
		check(guide.ticks - previous <= OutgoingGuide.FRAME_TICKS, "slice obeys tick cap")
		maximum_slice_usec = maxi(maximum_slice_usec, Time.get_ticks_usec() - slice_start)
	maximum_total_usec = maxi(maximum_total_usec, Time.get_ticks_usec() - start)
	check(guide.ticks <= OutgoingGuide.MAX_TICKS, "replay obeys total cap")
	return guide

func pair(cut: float = 0.0) -> Array:
	return [BallState.new(0, 0, Vector2(-0.35, 0.12)), BallState.new(1, 1, Vector2(0.0, 0.12 + cut))]

func run() -> void:
	# Independent ideal equal-mass frictionless references. No production coefficients change.
	for degrees in [0.0, 30.0, 45.0, 60.0]:
		var angle := deg_to_rad(degrees)
		var config := PhysicsConfig.new()
		config.ball_restitution = 1.0
		config.ball_friction = 0.0
		config.sliding_friction = 0.0
		config.rolling_resistance = 0.0
		config.spinning_friction = 0.0
		var cue := BallState.new(0, 0, -Vector2.from_angle(angle) * 2.0 * BallState.RADIUS - Vector2(0.05, 0.0))
		var target := BallState.new(1, 1, Vector2.ZERO)
		var preview := cue.duplicate_state()
		CueStrikeModel.new().apply(preview, Vector2.RIGHT, 1.4, Vector2.ZERO, 0.0, config)
		var speed := preview.velocity.length()
		var guide := OutgoingGuide.new()
		guide.begin([cue, target], Vector2.RIGHT, 1.4, Vector2.ZERO, config, TableSpec.new())
		while not guide.done: guide.advance()
		check(guide.result.status == "predicted", "ideal cut is predicted at %s degrees" % degrees)
		check(absf(guide.result.cue_speed - speed * sin(angle)) < 0.0002, "ideal cue speed matches sin(cut) within 0.2 mm/s")
		check(absf(guide.result.object_speed - speed * cos(angle)) < 0.0002, "ideal object speed matches cos(cut) within 0.2 mm/s")
		var stepper := PhysicsStepper.new()
		cue.velocity = preview.velocity
		for unused in range(100):
			stepper.step_fixed([cue, target], config.fixed_step, config, TableSpec.new())
			if not stepper.drain_events().is_empty(): break
		check((cue.velocity + target.velocity - preview.velocity).length() * config.ball_mass < 0.000001, "ideal vector momentum conserved within 1 micro N s")
	var layout := pair()
	var original: Array = []
	for ball in layout: original.append(ball.canonical_state())
	var head := predict(layout)
	check(head.result.status == "predicted", "head-on has a predicted first contact")
	check(head.result.object_speed > head.result.cue_speed, "head-on object receives most forward speed")
	check(head.result.cue_path[0] == head.result.contact and head.result.object_path[0].distance_to(layout[1].position) < 0.003, "outgoing paths begin at separate ball centers")
	for index in range(layout.size()): check(layout[index].canonical_state() == original[index], "replay never mutates input state")
	var cut := predict(pair(0.035))
	check(cut.result.status == "predicted", "cut has two paths")
	check(cut.result.cue_path.size() > 2 and cut.result.object_path.size() > 2, "cut supplies sampled outgoing motion")
	# Independent full active replay checks every retained outgoing sample, not
	# an ideal right-angle formula that would ignore friction and restitution.
	var replay := pair(0.035)
	var config := PhysicsConfig.new()
	CueStrikeModel.new().apply(replay[0], Vector2.RIGHT, 1.4, Vector2.ZERO, 0.0, config)
	var stepper := PhysicsStepper.new()
	var contact_tick := -1
	var matched := 0
	for tick in range(cut.ticks):
		var before_cue: Vector2 = replay[0].position
		var before_object: Vector2 = replay[1].position
		stepper.step_fixed(replay, config.fixed_step, config, TableSpec.new())
		var events := stepper.drain_events()
		for event in events:
			if event.kind == "ball_contact" and contact_tick < 0: contact_tick = tick
		if contact_tick >= 0:
			var index := tick - contact_tick
			if index < cut.result.cue_path.size():
				check(replay[0].position.distance_to(cut.result.cue_path[index]) < 1.0e-7 or index == cut.result.cue_path.size() - 1 and Geometry2D.get_closest_point_to_segment(cut.result.cue_path[index], before_cue, replay[0].position).distance_to(cut.result.cue_path[index]) < 1.0e-7, "cue sample matches active replay (final length-cap interpolation within tick)")
				matched += 1
			if index < cut.result.object_path.size(): check(replay[1].position.distance_to(cut.result.object_path[index]) < 1.0e-7 or index == cut.result.object_path.size() - 1 and Geometry2D.get_closest_point_to_segment(cut.result.object_path[index], before_object, replay[1].position).distance_to(cut.result.object_path[index]) < 1.0e-7, "object sample matches active replay (final length-cap interpolation within tick)")
	check(matched > 100, "parity covers post-contact cloth evolution")
	var draw := predict(pair(0.035), Vector2(0.0, -0.45))
	var follow := predict(pair(0.035), Vector2(0.0, 0.45))
	check(draw.result.status == "predicted" and follow.result.status == "predicted", "signed vertical spin remains predicted")
	check(draw.result.cue_path[-1].distance_to(follow.result.cue_path[-1]) > 0.03, "draw/follow evolves different cue paths after contact")
	var side := predict(pair(0.035), Vector2(0.4, 0.0))
	check(side.result.status == "predicted" and side.result.cue_path[-1].distance_to(cut.result.cue_path[-1]) > 0.005, "side spin/throw uses active strike and collision")
	check(predict(pair(), Vector2.ZERO, 0.0).result.status == "no stroke", "zero power has no outgoing prediction")
	check(predict(pair(), Vector2.ZERO, 1.4, Vector2.UP).result.status != "predicted", "no hit omits outgoing paths")
	var rail := predict([BallState.new(0, 0, Vector2(1.1, 0.2)), BallState.new(1, 1, Vector2(-0.6, 0.2))])
	check(rail.result.status == "rail/pocket before ball", "rail-before-hit is excluded")
	var cluster := pair()
	cluster.append(BallState.new(2, 2, Vector2(2.0 * BallState.RADIUS, 0.12)))
	check(predict(cluster).result.cue_path.is_empty(), "frozen cluster never claims an isolated two-ball path")
	var near_rail := [BallState.new(0, 0, Vector2(0.5, 0.2)), BallState.new(1, 1, Vector2(1.0, 0.2))]
	var stopped := predict(near_rail)
	check(stopped.result.status == "predicted" and stopped.result.object_path.size() < 300, "object guide truncates before its next rail")
	check(stopped.result.object_path[-1].x > stopped.result.object_path[0].x, "truncated guide contains no reflected leg")
	# Full rack measures the actual expensive N² layout, with frozen-contact omission.
	var rack := predict(RackBuilder.create_eight_ball_rack(TableSpec.new()), Vector2.ZERO, 8.0)
	check(rack.result.status != "predicted", "rack ambiguity is qualified")
	var scene = load("res://scenes/main.tscn").instantiate()
	scene.session_path = "/tmp/pool-outgoing-tests-%s.json" % Time.get_ticks_usec()
	root.add_child(scene)
	await process_frame
	scene.set_process(false)
	scene.hud.hide_menu()
	scene._placing = false
	var live: Array[BallState] = [BallState.new(0, 0, Vector2(-0.35, 0.12)), BallState.new(1, 1, Vector2(0.0, 0.155))]
	scene.balls = live
	scene.aim_direction = Vector2.RIGHT
	scene._last_aim_state.clear()
	scene._refresh_aim()
	var previous = scene._guide_prediction
	for unused in range(100): scene._refresh_aim()
	check(scene._guide_applied and scene._guide_prediction == previous, "idle prediction completes and stays cached")
	for overhead in [false, true]:
		scene.table_view.set_overhead(overhead)
		await scene.table_view._camera_tween.finished
		scene.table_view._process(0.0)
		var vertices: PackedVector3Array = scene.table_view._aim_immediate.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
		var first: Vector2 = scene.table_view._camera.unproject_position(vertices[6])
		var second: Vector2 = scene.table_view._camera.unproject_position(vertices[7])
		print("CAMERA RIBBON WIDTH ", overhead, " ", first.distance_to(second))
		check(absf(first.distance_to(second) - 1.5) < 0.002, "camera transition preserves 1.5 logical-pixel inner ribbon width")
		check(scene._guide_prediction == previous, "camera redraw reuses prediction without solver restart")
	root.size = Vector2i(1100, 700)
	await process_frame
	scene.table_view._process(0.0)
	var vertices: PackedVector3Array = scene.table_view._aim_immediate.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	var first: Vector2 = scene.table_view._camera.unproject_position(vertices[6])
	var second: Vector2 = scene.table_view._camera.unproject_position(vertices[7])
	print("RESIZE RIBBON WIDTH ", first.distance_to(second))
	check(absf(first.distance_to(second) - 1.5) < 0.002, "resize preserves inner ribbon width")
	scene.balls[1].position.y += 0.02
	scene._refresh_aim()
	check(scene._guide_prediction != previous, "object layout change invalidates cached outgoing paths")
	previous = scene._guide_prediction
	scene.physics_config.ball_friction += 0.001
	scene._refresh_aim()
	check(scene._guide_prediction != previous, "physics parameter change invalidates preview cache")
	scene._guides = false
	scene._refresh_aim()
	check(not scene.table_view._aim_mesh.visible and scene.hud._prediction.text.is_empty(), "guide-off clears visible paths and speed text")
	scene._placing = true
	scene._refresh_aim()
	check(scene.table_view._ghost_ball.visible, "placement retains its separate filled preview even with path guide off")
	scene.queue_free()
	await process_frame
	print("OUTGOING GUIDES: %d checks, %d failures; max slice %d us, max total %d us" % [checks, failed, maximum_slice_usec, maximum_total_usec])
	quit(1 if failed else 0)
