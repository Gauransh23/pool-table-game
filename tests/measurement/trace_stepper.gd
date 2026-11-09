extends PhysicsStepper
# Only constructed by the acquisition runner. Gameplay never loads this script.
var records: Array = []
var overflow := false
var origin_usec := Time.get_ticks_usec()
var fixed_step_seconds := PhysicsConfig.new().fixed_step
const LIMIT := 30000

func record(kind: String, payload: Dictionary) -> void:
	var start := Time.get_ticks_usec()
	if records.size() >= LIMIT:
		overflow = true
		return
	records.append({"kind":kind,"wall_usec":start-origin_usec,"tick":tick_count,"simulation_seconds":tick_count*fixed_step_seconds,"payload":payload})

func step_fixed(balls: Array, delta: float, config: PhysicsConfig, table: TableSpec) -> void:
	super.step_fixed(balls,delta,config,table)
	record("state", {"balls":preload("res://tests/measurement/shot_fixture.gd").states(balls)})

func drain_events() -> Array[Dictionary]:
	var events := super.drain_events()
	for event in events:
		record("event", {"event":event,"event_tick_seconds":event.tick*fixed_step_seconds,"time_resolution":"fixed tick; no substep root timestamp"})
	return events
