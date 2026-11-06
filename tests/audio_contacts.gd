extends SceneTree

var failures := 0


func _initialize() -> void:
	Engine.max_fps = 60
	call_deferred("run")


func require(condition: bool, description: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: " + description)


func run() -> void:
	var audio := TableAudio.new()
	root.add_child(audio)
	await process_frame
	var contact_bus := AudioServer.get_bus_index(&"Contacts")
	require(contact_bus >= 0, "contact audio has a dedicated mix bus")
	if contact_bus >= 0:
		var effects := AudioServer.get_bus_effect_count(contact_bus)
		require(effects > 0, "the contact mix bus has a peak-protection effect")
		if effects > 0:
			var limiter = AudioServer.get_bus_effect(contact_bus, 0)
			require(limiter is AudioEffectHardLimiter and limiter.ceiling_db <= -2.0 and AudioServer.is_bus_effect_enabled(contact_bus, 0),
				"dense contacts retain peak headroom instead of relying on event deletion")
		require(audio._players.all(func(player: AudioStreamPlayer): return player.bus == &"Contacts"), "all contact voices use the protected bus")
	# Test event delivery without asking the headless Dummy driver to mix WAVs.
	# This fixture deliberately makes no waveform or listening claim.
	for kind in audio._sounds: audio._sounds[kind] = null
	var config := PhysicsConfig.new()
	config.sliding_friction = 0.0
	config.rolling_resistance = 0.0
	config.ball_friction = 0.0
	var balls: Array[BallState] = [
		BallState.new(0, 0, Vector2(-0.6, 0.0)),
		BallState.new(1, 1, Vector2(-0.6 + BallState.RADIUS * 2.0 + 0.0005, 0.0)),
		BallState.new(2, 2, Vector2(0.2, 0.3)),
		BallState.new(3, 3, Vector2(0.2 + BallState.RADIUS * 2.0 + 0.0005, 0.3)),
	]
	balls[0].velocity = Vector2.RIGHT
	balls[2].velocity = Vector2.RIGHT
	var stepper := PhysicsStepper.new()
	stepper.step_fixed(balls, config.fixed_step, config, TableSpec.new())
	var contacts := 0
	var before := audio._cursor
	for event in stepper.drain_events():
		if event.kind == "ball_contact":
			contacts += 1
			audio.play_contact("ball", event.speed)
	require(contacts == 2, "fixture generates two independent physical impacts in one tick")
	require(audio._cursor - before == contacts, "both simultaneous ball contacts reach the audio voice pool")
	before = audio._cursor
	for event in range(100):
		audio.play_contact("ball", 1.0 + float(event) * 0.01)
	require(audio._cursor - before == 100, "a batched event list has no unrelated-contact time gate")
	before = audio._cursor
	audio.enabled = false
	audio.play_contact("cue", 2.0)
	audio.play_contact("ball", 2.0)
	require(audio._cursor == before, "muted events do not start new voices")
	audio.enabled = true
	for speed in [-1.0, NAN, INF, 0.0]:
		audio.play_contact("ball", speed)
	require(audio._cursor == before, "invalid and silent input does not start voices")
	audio.queue_free()
	audio = null
	await process_frame
	print("AUDIO CONTACTS: %d failure(s); tests event delivery, not acoustic fidelity" % failures)
	call_deferred("finish")

func finish() -> void:
	quit(1 if failures else 0)
