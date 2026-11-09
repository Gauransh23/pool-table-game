extends SceneTree
const Fixture = preload("res://tests/measurement/power_atlas_fixture.gd")
const Inventory = preload("res://tests/measurement/shot_fixture.gd")
var game: GameController
var contacts := 0
var output := ""
var trace: FileAccess
var raw: FileAccess
var errors: Array[String] = []
var session := ""

func _initialize() -> void: call_deferred("run")
func fail(message: String) -> void:
	errors.append(message)
	printerr(message)
func json_safe(value: Variant) -> Variant:
	if value is Vector2: return [value.x,value.y]
	if value is Vector3: return [value.x,value.y,value.z]
	if value is Array:
		var result := []
		for item in value: result.append(json_safe(item))
		return result
	if value is Dictionary:
		var result := {}
		for key in value: result[key]=json_safe(value[key])
		return result
	return value
func write_row(file: FileAccess, value: Variant) -> void:
	file.store_line(JSON.stringify(json_safe(value),"",true,true))
	file.flush()
	if file.get_error()!=OK: fail("artifact write/flush failed")
func close_checked(file: FileAccess) -> void:
	file.flush()
	if file.get_error()!=OK: fail("artifact flush failed")
	file.close()
	if file.is_open(): fail("artifact close failed")

func controller_launch(f: Dictionary) -> Dictionary:
	game._cancel_pending_stroke()
	game.table_view.cancel_stroke()
	game.balls=Inventory.instantiate_balls(f)
	game._shot_in_motion=false
	game._placing=false
	game._strokes=0
	game.hud.hide_menu()
	game.aim_direction=Vector2(f.direction[0],f.direction[1])
	game.hud._power.value=f.power
	var readback: float = game.hud._power.value
	game.hud._spin.spin=Vector2(f.tip[0],f.tip[1])
	game.hud.selected_spin=game.hud._spin.spin
	game.hud.power=readback
	var before := contacts
	# Exercise the actual HUD signal, controller, and actual presentation contact closure.
	# The tween clock is advanced manually; this is not display latency evidence.
	game.hud._request_shot()
	if game._stroke_pending:
		game.table_view._stroke_tween.pause()
		game.table_view._stroke_tween.custom_step(.100001)
	var committed := game._strokes==1
	if committed != (f.power>0) or contacts-before != int(committed): fail("controller commitment mismatch: "+f.id)
	var result := {"readback":readback,"committed_power":game.power if committed else null,"committed":committed,"contacts":contacts-before,"balls":game.balls,"tip_readback":[game.hud.selected_spin.x,game.hud.selected_spin.y]}
	game.table_view.cancel_stroke()
	return result

func run() -> void:
	var fixture_path := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--fixtures="): fixture_path=arg.trim_prefix("--fixtures=")
		if arg.begins_with("--output="): output=arg.trim_prefix("--output=")
	if fixture_path.is_empty() or output.is_empty(): printerr("--fixtures and --output required"); quit(1); return
	var fixtures: Variant=JSON.parse_string(FileAccess.get_file_as_string(fixture_path))
	var problem := Fixture.validate(fixtures)
	if not problem.is_empty(): printerr("INVALID: "+problem); quit(1); return
	if Fixture.numeric_properties(PhysicsConfig.new()) != Fixture.PROFILE: printerr("runtime profile identity mismatch"); quit(1); return
	raw=FileAccess.open(output+"/raw.jsonl",FileAccess.WRITE)
	trace=FileAccess.open(output+"/traces.jsonl",FileAccess.WRITE)
	if raw==null or trace==null: printerr("cannot open atlas output"); quit(1); return
	session=output+"/isolated-session.json"
	game=load("res://scenes/main.tscn").instantiate()
	game.session_path=session
	root.add_child(game)
	game.set_process(false)
	game.hud.hide_menu()
	game.table_view._camera_tween.pause()
	game.table_view._camera_tween.custom_step(2)
	game.table_view.stroke_contact.connect(func(): contacts+=1)
	write_row(raw,{"kind":"runtime","engine":Engine.get_version_info(),"os":OS.get_name(),"architecture":Engine.get_architecture_name(),"processor":OS.get_processor_name(),"scalar_precision":"64-bit GDScript float","vector_precision":"64-bit" if Vector2(16777216,0).x+Vector2(1,0).x==Vector2(16777217,0).x else "32-bit","profile":Fixture.numeric_properties(PhysicsConfig.new()),"table":Fixture.numeric_properties(TableSpec.new()),"half_size":[1.27,.635],"clock":"Time.get_ticks_usec; manually accumulated simulation dt"})
	for f in fixtures:
		measure(f)
		if not errors.is_empty(): break
	if errors.is_empty(): boundary_probes()
	write_row(raw,{"kind":"completion","fixtures":fixtures.size(),"errors":errors})
	close_checked(raw)
	close_checked(trace)
	game.queue_free()
	await process_frame
	for candidate in [session,session+".tmp"]:
		if FileAccess.file_exists(candidate): DirAccess.remove_absolute(candidate)
	print("ATLAS fixtures=",fixtures.size()," errors=",errors.size())
	quit(0 if errors.is_empty() else 1)

func measure(f: Dictionary) -> void:
	var start := Time.get_ticks_usec()
	var config := PhysicsConfig.new()
	var table := TableSpec.new()
	table.half_size=Vector2(f.half_size[0],f.half_size[1])
	var balls: Array=Inventory.instantiate_balls(f)
	var direction := Vector2(f.direction[0],f.direction[1])
	var tip := Vector2(f.tip[0],f.tip[1])
	var strike := CueStrikeModel.new()
	var accepted := false
	var readback: Variant=null
	var committed: Variant=null
	var equivalent: Variant=null
	var tip_readback: Variant=null
	if f.modality=="controller" or f.get("controller_probe",false):
		var linked := controller_launch(f)
		readback=linked.readback
		tip_readback=linked.tip_readback
		committed=linked.committed_power
		if f.modality=="controller":
			balls=linked.balls
			accepted=linked.committed
		else:
			accepted=strike.apply(balls[0],direction,f.cue_speed,tip,f.elevation,config)
			equivalent=Inventory.states(balls)==Inventory.states(linked.balls)
			if not equivalent: fail("controller/direct launch mismatch: "+f.id)
	else:
		if f.family not in ["launch","rolling"]:
			game.hud._power.value=f.power
			readback=game.hud._power.value
		if f.family!="rolling": accepted=strike.apply(balls[0],direction,f.cue_speed,tip,f.elevation,config)
	var launch := Inventory.states(balls)
	var cue: BallState=balls[0]
	var energy := .5*BallState.MASS*(cue.velocity.length_squared()+cue.vertical_velocity*cue.vertical_velocity)+.5*BallState.INERTIA*cue.angular_velocity.length_squared()
	var actual_cue_speed: float=StrokePower.cue_speed(readback) if f.modality=="controller" else f.cue_speed
	var input_energy: float=.5*config.cue_mass*actual_cue_speed*actual_cue_speed
	var origin := cue.position
	var stepper := PhysicsStepper.new()
	var tick := 0
	var elapsed := 0.0
	var path := 0.0
	var events := []
	var changes := []
	var mode := "slide" if stepper.contact_slip(cue).length()>.0005 else "roll"
	var phase := cue.phase
	var first_roll: Variant=null
	var stable_roll: Variant=null
	var ready_time: Variant=null
	var translation_rest: Variant=null
	var spin_rest: Variant=null
	var first_contact: Variant=null
	var first_rail: Variant=null
	var contact_position: Variant=null
	var all_rest := false
	var trace_enabled: bool=f.get("trace",false)
	if trace_enabled: write_row(trace,{"id":f.id,"tick":0,"states":launch})
	while tick<int(f.ticks):
		if f.termination=="rest" and stepper.are_balls_settled(balls,config): break
		var previous := cue.position
		var before: Array=Inventory.states(balls) if f.family in ["rail","object"] else []
		stepper.step_fixed(balls,config.fixed_step,config,table)
		tick+=1
		elapsed+=config.fixed_step
		path+=previous.distance_to(cue.position)
		var drained := stepper.drain_events()
		for event in drained:
			var captured := {"event":event,"time_interval_s":[elapsed-config.fixed_step,elapsed],"before":before,"after":Inventory.states(balls),"root_time_s":null,"impulse_Ns":null,"unavailable_reason":"active event API has no substep/root/impulse seam"}
			events.append(captured)
			if event.kind=="rail" and first_rail==null: first_rail=captured
			if event.kind=="ball_contact" and first_contact==null:
				first_contact=captured
				contact_position=cue.position
		var new_mode := "slide" if stepper.contact_slip(cue).length()>.0005 else "roll"
		if new_mode!=mode or cue.phase!=phase:
			var change := {"from":mode,"to":new_mode,"phase_from":phase,"phase_to":cue.phase,"tick":tick,"time_interval_s":[elapsed-config.fixed_step,elapsed],"distance_interval_m":[previous.distance_to(origin),cue.position.distance_to(origin)],"velocity_m_s":[cue.velocity.x,cue.velocity.y],"slip_m_s":stepper.contact_slip(cue).length()}
			changes.append(change)
			if new_mode=="roll":
				if first_roll==null: first_roll=change
				stable_roll=change
			else: stable_roll=null
		mode=new_mode
		phase=cue.phase
		if cue.velocity.length()==0 and translation_rest==null: translation_rest=elapsed
		if cue.angular_velocity.length()==0 and spin_rest==null: spin_rest=elapsed
		if stepper.are_balls_settled(balls,config) and ready_time==null: ready_time=elapsed
		if trace_enabled: write_row(trace,{"id":f.id,"tick":tick,"states":Inventory.states(balls)})
		if f.termination=="horizon" and not cue.is_active() and balls.all(func(b): return not b.is_active()): break
	all_rest=stepper.are_balls_settled(balls,config)
	if tick==0 and all_rest: ready_time=0.0; translation_rest=0.0; spin_rest=0.0
	var terminal := Inventory.states(balls)
	if not Fixture.finite_tree(terminal): fail("nonfinite terminal: "+f.id)
	var displacement := cue.position-origin
	var signed_after: Variant=null
	var classification := "no_ball_contact"
	if contact_position!=null:
		signed_after=(cue.position-contact_position).dot(direction)
		classification="follow" if signed_after>.001 else ("draw" if signed_after<-.001 else "stun_or_small")
	var row := {"kind":"result","id":f.id,"family":f.family,"status":"MEASURED","input_domain":"direct cue speed" if f.family=="launch" else ("initial ball speed" if f.family=="rolling" else "HUD power"),"power_tick":f.power_tick if f.family not in ["launch","rolling"] else null,"requested_power":f.power if f.family not in ["launch","rolling"] else null,"hud_readback":readback,"committed_power":committed,"provenance":"actual HUD signal/controller/contact closure; manual tween clock" if f.modality=="controller" else "direct active strike model","controller_equivalent":equivalent,"tip_requested":f.tip,"tip_actual":[tip.x,tip.y],"hud_tip_readback":tip_readback,"tip_adjustment":"supported fixtures need no radial clamp; Vector2 conversion only","direction":f.direction,"elevation_radians":f.elevation,"cue_speed_m_s":actual_cue_speed,"accepted":accepted,"initial":f.balls,"launch":launch,"terminal":terminal,"launch_energy_J":energy,"cue_input_energy_J":input_energy,"energy_bound_J":input_energy+maxf(1e-9,1e-6*input_energy),"cue_impulse_Ns":[BallState.MASS*(launch[0][5]-f.balls[0][5]),BallState.MASS*(launch[0][7]-f.balls[0][7]),BallState.MASS*(launch[0][6]-f.balls[0][6])],"path_length_m":path,"net_displacement_m":[displacement.x,displacement.y],"signed_net_m":displacement.dot(direction),"regime_changes":changes,"first_roll_interval":first_roll,"last_stable_roll_interval":stable_roll,"translation_rest_s":translation_rest,"spin_rest_s":spin_rest,"readiness_s":ready_time,"ticks":tick,"simulation_s":elapsed,"substep_count":null,"substep_reason":"not exposed by active observer API","termination":"launch" if f.termination=="launch" else ("settled" if all_rest else ("cap" if f.termination=="rest" else "horizon")),"endpoint_to_rest":all_rest,"events":events,"first_ball_contact":first_contact,"first_rail_event":first_rail,"rail_classification":("jaw" if first_rail.event.get("jaw",false) else "straight") if first_rail!=null else "no_rail_event","cue_signed_travel_after_contact_m":signed_after,"cue_object_classification":classification,"wall_usec":Time.get_ticks_usec()-start,"observer_overflow":false,"finite":Fixture.finite_tree(terminal),"trace":trace_enabled}
	write_row(raw,row)

func boundary_probes() -> void:
	# Intentionally unsupported direct calls are isolated from qualified fixtures.
	for label in ["zero_direction","moving_ball","nan_speed","inf_speed","nan_direction","nan_tip","nan_elevation"]:
		var b := BallState.new()
		var d := Vector2.RIGHT
		var speed := 1.0
		var tip := Vector2.ZERO
		var elevation := 0.0
		match label:
			"zero_direction": d=Vector2.ZERO
			"moving_ball": b.velocity=Vector2(.1,0)
			"nan_speed": speed=NAN
			"inf_speed": speed=INF
			"nan_direction": d=Vector2(NAN,0)
			"nan_tip": tip=Vector2(NAN,0)
			"nan_elevation": elevation=NAN
		var accepted := CueStrikeModel.new().apply(b,d,speed,tip,elevation,PhysicsConfig.new())
		var finite := b.velocity.is_finite() and b.angular_velocity.is_finite() and is_finite(b.vertical_velocity)
		write_row(raw,{"kind":"unsupported_probe","id":label,"domain":"direct_model_only","accepted":accepted,"finite_outcome":finite,"states":Inventory.states([b]) if finite else null,"missing_reason":"nonfinite outcome deliberately not serialized" if not finite else null,"qualification":"unsupported; recorded behavior, not controller failure"})
	for value in [-.1,0.0,NAN,INF,1.1]:
		game._shot_in_motion=false
		game._placing=false
		game.balls=[BallState.new()]
		game._strokes=0
		game.hud.hide_menu()
		game._on_shoot_requested(value,Vector2.ZERO)
		if game._stroke_pending:
			game.table_view._stroke_tween.pause()
			game.table_view._stroke_tween.custom_step(.100001)
		var expected: bool=is_finite(value) and value>0
		if (game._strokes==1)!=expected: fail("controller power boundary handling")
		write_row(raw,{"kind":"controller_boundary","input":str(value),"committed":game._strokes==1,"committed_power":game.power if game._strokes==1 else null,"states":Inventory.states(game.balls)})
		game.table_view.cancel_stroke()
	for azimuth in range(8):
		game._shot_in_motion=false
		game.balls=[BallState.new()]
		game._strokes=0
		game._on_shoot_requested(.5,Vector2.from_angle(azimuth*TAU/8)*.50001)
		if game._stroke_pending or game._strokes!=0: fail("controller outside-tip rejection")
		write_row(raw,{"kind":"controller_boundary","input":"outside_tip_%d"%azimuth,"committed":game._strokes==1,"pending":game._stroke_pending})
