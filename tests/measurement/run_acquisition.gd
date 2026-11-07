extends SceneTree
const Fixture = preload("res://tests/measurement/shot_fixture.gd")
const Trace = preload("res://tests/measurement/trace_stepper.gd")
var output := ""
var fixture_path := "res://tests/fixtures/three_ball_v1.json"
var failures: Array[String] = []

func _initialize() -> void: call_deferred("run")
func check(condition: bool, message: String) -> void:
	if not condition: failures.append(message); printerr(message)

func replay(data: Dictionary, instrumented: bool) -> Dictionary:
	var balls := Fixture.instantiate_balls(data)
	var stepper: PhysicsStepper = Trace.new() if instrumented else PhysicsStepper.new()
	var config := PhysicsConfig.new()
	var table := TableSpec.new()
	var shot: Dictionary = data.input
	CueStrikeModel.new().apply(balls[0],Vector2.from_angle(shot.angle_radians),preload("res://scripts/sim/stroke_power.gd").cue_speed(shot.power),Vector2(shot.tip_x,shot.tip_y),0.0,config)
	var events := []
	var start := Time.get_ticks_usec()
	for tick in range(int(data.ticks)):
		stepper.step_fixed(balls,config.fixed_step,config,table)
		events.append_array(stepper.drain_events())
	return {"states":Fixture.states(balls),"events":events,"elapsed_usec":Time.get_ticks_usec()-start,"records":stepper.records if instrumented else [],"overflow":stepper.overflow if instrumented else false}

func run() -> void:
	var native := false
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--output="): output=arg.trim_prefix("--output=")
		if arg.begins_with("--fixture="): fixture_path=arg.trim_prefix("--fixture=")
		if arg == "--native": native=true
	if output.is_empty(): printerr("--output required"); quit(1); return
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(fixture_path))
	var error := Fixture.validate(data)
	if not error.is_empty(): printerr("INVALID FIXTURE: "+error); quit(1); return
	# Mutations exercise validator rather than a parallel Python schema.
	for mutation in ["empty","version","duplicate","nan","moving","overlap","orientation","horizon","infinite_horizon","input"]:
		var bad: Dictionary = data.duplicate(true)
		match mutation:
			"empty": bad.balls=[]
			"version": bad.schema="future"
			"duplicate": bad.balls[1][0]=0
			"nan": bad.balls[0][2]=NAN
			"moving": bad.balls[0][5]=.1
			"overlap": bad.balls[1][2]=bad.balls[0][2]
			"orientation": bad.balls[0][14]=0
			"horizon": bad.ticks=0
			"infinite_horizon": bad.ticks=INF
			"input": bad.input.power=0
		check(not Fixture.validate(bad).is_empty(),"validator accepted "+mutation)
	var baseline := replay(data,false)
	# Global cosmetic RNG consumption must not affect the seedless physics stream.
	seed(1234)
	for i in range(1000): randf()
	var repeated := replay(data,false)
	var observed := replay(data,true)
	var observed_again := replay(data,true)
	var samples: Array = observed.records.filter(func(r): return r.kind == "state").map(func(r): return r.payload.balls)
	var repeated_samples: Array = observed_again.records.filter(func(r): return r.kind == "state").map(func(r): return r.payload.balls)
	check(samples == repeated_samples,"per-tick sampled replay differs")
	check(baseline.states == repeated.states and baseline.events == repeated.events,"same-build replay differs after cosmetic RNG consumption")
	check(baseline.states == observed.states and baseline.events == observed.events,"observer altered replay")
	check(not observed.overflow and not observed.records.is_empty(),"empty/overflow replay trace")
	for kind in data.expected_events:
		check(baseline.events.any(func(e): return e.kind == kind),"missing expected replay event: "+kind)
	# Paired complete-run timings include serialization/state collection, not just append.
	var timings := []
	for i in range(5):
		var plain := replay(data,false)
		var traced := replay(data,true)
		timings.append({"plain_usec":plain.elapsed_usec,"traced_usec":traced.elapsed_usec})
	var raw := {"schema":"long-rail-acquisition/1","fixture":data,"engine":Engine.get_version_info(),"os":OS.get_name(),"device":OS.get_processor_name(),"precision":"Godot standard build; Vector fields engine real_t; canonical PackedFloat64Array","rng":"physics seedless; presentation consumes no physical RNG; global RNG perturbation tested","initial":data.balls,"terminal":observed.states,"events":observed.events,"records":observed.records,"paired_replay_timings":timings,"native":false,"config":numeric_properties(PhysicsConfig.new()),"table":numeric_properties(TableSpec.new()),"limitations":["same build/platform reproducibility only","tick quantization is not exact impact time","wall delivery and frame post-draw timestamps are not display presentation or audible onset","no calibration or perception claim"]}
	if native: await capture_native(data,raw)
	raw["failures"]=failures
	raw["status"]="PASS" if failures.is_empty() else "FAIL"
	var file := FileAccess.open(output,FileAccess.WRITE)
	if file == null: printerr("cannot write acquisition: "+output); quit(1); return
	file.store_string(JSON.stringify(raw)); file.flush()
	check(file.get_error() == OK,"failed acquisition write")
	file.close()
	print("ACQUISITION ",raw.status," output=",output)
	quit(0 if failures.is_empty() else 1)

func capture_native(data: Dictionary, raw: Dictionary) -> void:
	if DisplayServer.get_name() == "headless": check(false,"native capture requires a windowed display"); return
	root.size=Vector2i(1600,900)
	var game = load("res://scenes/main.tscn").instantiate()
	var session := "user://acquisition-%d.json" % Time.get_ticks_usec()
	game.session_path=session
	root.add_child(game)
	game.hud.hide_menu()
	await game.table_view._camera_tween.finished
	game.balls=Fixture.instantiate_balls(data)
	game._pots=13
	game._update_score()
	game.power=data.input.power
	game.spin=Vector2(data.input.tip_x,data.input.tip_y)
	game.hud._power.value=game.power
	game.hud._spin.spin=game.spin
	game.hud.selected_spin=game.spin
	game.aim_direction=Vector2.from_angle(data.input.angle_radians)
	game.table_view.sync_balls(game.balls)
	game._last_aim_state.clear(); game._refresh_aim()
	for i in range(3): await process_frame
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png(output+".png") == OK,"native screenshot failed")
	var tracer = Trace.new()
	game.stepper=tracer
	tracer.record("input_request", {"input":data.input,"origin":"scripted controller call; no OS input timestamp"})
	game._on_shoot_requested(data.input.power,Vector2(data.input.tip_x,data.input.tip_y))
	var was_pending := true
	var start := Time.get_ticks_usec()
	var termination_reason := "timeout"
	while Time.get_ticks_usec()-start < 12000000:
		await process_frame
		tracer.record("frame_process", {"pending":game._stroke_pending,"moving":game._shot_in_motion,"process_delta_seconds":game.get_process_delta_time()})
		if was_pending and game._shot_in_motion:
			tracer.record("cue_contact_observed", {"resolution":"first observer frame after controller applies strike"})
			was_pending=false
		await RenderingServer.frame_post_draw
		tracer.record("frame_post_draw", {})
		if Time.get_ticks_usec()-start >= 12000000: break
		if tracer.tick_count >= data.ticks:
			termination_reason="horizon"
			break
		if not was_pending and not game._shot_in_motion and not game._stroke_pending and tracer.are_balls_settled(game.balls,game.physics_config):
			termination_reason="settled"
			break
	var termination := {"reason":termination_reason,"tick":tracer.tick_count,"elapsed_wall_usec":Time.get_ticks_usec()-start,"deadline_usec":12000000,"controller_moving":game._shot_in_motion,"controller_pending":game._stroke_pending,"balls_settled":tracer.are_balls_settled(game.balls,game.physics_config)}
	tracer.record("termination",termination)
	check(termination_reason != "timeout","native acquisition timed out before horizon/settlement")
	check(not was_pending and tracer.tick_count > 0,"native acquisition had no shot")
	check(not tracer.overflow,"native trace overflow")
	for kind in data.expected_events:
		check(tracer.records.any(func(r): return r.kind == "event" and r.payload.event.kind == kind),"missing native event: "+kind)
	raw.native=true
	raw["native_records"]=tracer.records
	raw["native_termination"]=termination
	raw["native_terminal"]=Fixture.states(game.balls)
	raw["native_ticks"]=tracer.tick_count
	raw["native_window"]={"window":str(root.size),"framebuffer":str(root.get_texture().get_size()),"screen_scale":DisplayServer.screen_get_scale(),"refresh_hz":DisplayServer.screen_get_refresh_rate(),"renderer":RenderingServer.get_current_rendering_method(),"screenshot":output+".png","thermal_power_cache":"uncontrolled; short development capture"}
	game.queue_free()
	await process_frame
	for candidate in [session,session+".tmp"]:
		if FileAccess.file_exists(candidate): DirAccess.remove_absolute(candidate)

func numeric_properties(object: Object) -> Dictionary:
	var result := {}
	for property in object.get_property_list():
		if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			var value: Variant = object.get(property.name)
			if value is float or value is int or value is bool: result[property.name]=value
	return result
