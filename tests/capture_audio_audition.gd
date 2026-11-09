# MovieMaker audio capture: fixed-FPS digital mix evidence, not device latency.
extends SceneTree
var audio: TableAudio
var timeline: Array = []
var event_index := 0
var elapsed := 0.0
var changed := false
var break_events := 0

func _initialize() -> void:
	root.size = Vector2i(64, 64)
	call_deferred("setup")

func setup() -> void:
	audio = TableAudio.new()
	root.add_child(audio)
	audio._cosmetic_rng.seed = 7321
	for block in [0.5, 10.5]:
		for kind_index in range(4):
			var kind: String = ["cue", "ball", "rail", "pocket"][kind_index]
			for take in range(3):
				timeline.append({"time":block + kind_index * 2.0 + take * .5,"kind":kind,"speed":1.5})
	var balls := RackBuilder.create_eight_ball_rack(TableSpec.new())
	var config := PhysicsConfig.new()
	var stepper := PhysicsStepper.new()
	balls[0].velocity = Vector2(6.0, 0.0)
	timeline.append({"time":19.0,"kind":"cue","speed":6.0})
	for step in range(int(4.0/config.fixed_step)):
		stepper.step_fixed(balls,config.fixed_step,config,TableSpec.new())
		for event in stepper.drain_events():
			var kind: String = {"ball_contact":"ball","rail":"rail","pocket":"pocket"}.get(event.kind, "")
			if kind != "":
				timeline.append({"time":19.0 + step*config.fixed_step,"kind":kind,"speed":event.speed})
				break_events += 1
	for index in range(100):
		timeline.append({"time":24.0 + index*.001,"kind":"ball","speed":8.0})
	timeline.append({"time":26.0,"kind":"pocket","speed":3.0})
	timeline.sort_custom(func(a,b): return a.time < b.time)
	for kind in audio._variants:
		audio._variants[kind] = [load("res://assets/audio/baseline/%s.wav" % kind)]
		audio._last_variant.erase(kind)

func _process(delta: float) -> bool:
	if audio == null: return false
	elapsed += delta
	if elapsed >= 9.0 and not changed:
		changed = true
		for kind in audio._variants:
			audio._variants[kind] = []
			for index in range(TableAudio.VARIANT_COUNTS[kind]):
				audio._variants[kind].append(load("res://assets/audio/%s_%02d.wav" % [kind,index+1]))
			audio._last_variant.erase(kind)
	while event_index < timeline.size() and timeline[event_index].time <= elapsed:
		var event: Dictionary = timeline[event_index]
		audio.play_contact(event.kind,event.speed)
		event_index += 1
	if elapsed >= 26.15 and audio.enabled: audio.enabled = false
	if elapsed >= 27.0:
		print("AUDIO AUDITION: events=%d physics-break=%d starts=%d steals=%d drops=%d" % [event_index,break_events,audio.voice_starts,audio.voice_steals,audio.voice_drops])
		quit()
	return false
