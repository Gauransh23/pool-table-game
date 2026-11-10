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
	for kind in TableAudio.VARIANT_COUNTS:
		require(audio._variants[kind].size() == TableAudio.VARIANT_COUNTS[kind], kind + " loads declared recorded takes")
		var previous: AudioStream = null
		for index in range(50):
			var selected := audio._next_variant(kind)
			require(selected != null, kind + " has an imported recorded stream")
			if TableAudio.VARIANT_COUNTS[kind] > 1:
				require(selected != previous, kind + " avoids immediate repeated takes")
			previous = selected
	var previous_gain := -INF
	for level in range(9):
		var speed := 0.005 * pow(1600.0, float(level) / 8.0)
		var gain := TableAudio.contact_gain_db(speed)
		require(gain > previous_gain, "nine log-spaced speeds have increasing gain")
		previous_gain = gain
	seed(7731)
	var expected_random := randf()
	seed(7731)
	audio._next_variant("ball")
	require(randf() == expected_random, "cosmetic sample selection preserves global simulation RNG")
	# Real streams exercise active tails and bounded voice allocation. Dummy
	# output proves engine lifecycle, not acoustic silence or de-click quality.
	for index in range(100): audio.play_contact("ball", 2.0)
	require(audio._players.size() == TableAudio.VOICE_BUDGET, "dense events cannot grow voice resources")
	require(audio.voice_starts + audio.voice_steals + audio.voice_drops == 100, "dense event decisions are accounted")
	require(audio._players.all(func(player: AudioStreamPlayer): return player.pitch_scale == 1.0), "shot strength never pitch-shifts recorded material")
	audio.enabled = false
	await create_timer(0.04).timeout
	await process_frame
	require(audio._players.all(func(player: AudioStreamPlayer): return not player.playing), "mute stops every active/tail voice after ramp")
	print("MUTE: active=%d fades=%d reserved=%d steals=%d drops=%d" % [audio._players.filter(func(p): return p.playing).size(),audio._fades.size(),audio._reserved.size(),audio.voice_steals,audio.voice_drops])
	require(audio._reserved.is_empty(), "mute releases reserved voices and cancels queued starts")
	audio.enabled = true
	await create_timer(0.04).timeout
	await process_frame
	require(audio._players.all(func(player: AudioStreamPlayer): return not player.playing), "unmute cannot resurrect queued contacts")
	var reused := audio._players[0]
	var real_stream: AudioStream = audio._variants["pocket"][0]
	audio._start_voice(reused, real_stream, "pocket", -18.0)
	audio._fade_out(reused)
	reused.stop()
	audio._start_voice(reused, real_stream, "pocket", -18.0)
	await create_timer(0.04).timeout
	await process_frame
	require(reused.playing and not audio._fades.has(reused), "reusing a naturally finished tail cancels its stale fade")
	reused.stop()
	var credit_path := "res://assets/audio/CREDITS.txt"
	require(FileAccess.file_exists(credit_path), "distributable sound attribution exists")
	var credit_text := FileAccess.get_file_as_string(credit_path)
	require(credit_text.contains("KVV Audio") and credit_text.contains("851086") and credit_text.contains("851087") and credit_text.contains("851090") and credit_text.contains("https://creativecommons.org/licenses/by/4.0/") and credit_text.contains("Adapted"), "sound credits retain creator, sources, licence and changes")
	var hud := GameHUD.new()
	root.add_child(hud)
	hud.show_sound_credits()
	await process_frame
	require(hud.menu_visible() and root.gui_get_focus_owner().text == "Back", "sound credits use modal Back focus")
	var displayed: RichTextLabel = hud._card.get_node("SoundCredits")
	require(displayed.text.contains("KVV Audio") and displayed.text.contains("mccarthy") and displayed.text.contains("creativecommons.org/licenses/by/4.0/"), "visible credits include source creators and licence link")
	root.gui_get_focus_owner().pressed.emit()
	await process_frame
	require(hud._card.get_children().any(func(child): return child is Button and child.text == "Sound credits"), "Back returns to home with sound credits reachable")
	hud.queue_free()
	await process_frame
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
