extends RefCounted
class_name OutgoingGuide

# This is a disposable replay of the ACTIVE engine, never an ideal collision oracle.
# Every result is tick sampled and deliberately ends before another interaction.
const MAX_TICKS := 1920
const BEFORE_CONTACT_SECONDS := 2.5
const AFTER_CONTACT_SECONDS := 0.8
const MAX_PATH_METERS := 0.45
const FRAME_TICKS := 32
const FRAME_BUDGET_USEC := 2500

# Observe the exact active-engine event registration without changing its solver.
# Positions are captured after its positional correction, before later substeps.
class ContactStepper extends PhysicsStepper:
	var observed: Array = []
	var first_contact: Dictionary = {}
	func _record_event(event: Dictionary) -> void:
		super._record_event(event)
		if event.kind != "ball_contact" or not first_contact.is_empty(): return
		var centers: Dictionary = {}
		for ball in observed:
			if ball.number == event.a or ball.number == event.b: centers[ball.number] = ball.position
		first_contact = {"centers": centers, "position": event.position}

var done := true
var ticks := 0
var result: Dictionary = {}
var _balls: Array[BallState] = []
var _config: PhysicsConfig
var _table: TableSpec
var _stepper := ContactStepper.new()
var _cue: BallState
var _object: BallState
var _hit_tick := -1
var _active := [true, true]
var _distance := [0.0, 0.0]

func begin(source: Array, direction: Vector2, cue_speed: float, spin: Vector2, config: PhysicsConfig, table: TableSpec) -> void:
	_balls.clear()
	result = {"status": "calculating", "incoming": PackedVector2Array(), "cue_path": PackedVector2Array(), "object_path": PackedVector2Array()}
	done = false
	ticks = 0
	_hit_tick = -1
	_active = [true, true]
	_distance = [0.0, 0.0]
	_object = null
	_cue = null
	_config = config
	_table = table
	_stepper = ContactStepper.new()
	_stepper.observed = _balls
	for ball in source:
		var copy: BallState = ball.duplicate_state()
		_balls.append(copy)
		if copy.number == 0: _cue = copy
		if copy.phase == BallState.Phase.AIRBORNE or copy.phase == BallState.Phase.FALLING:
			_finish("airborne/falling layout")
		if copy.is_active() and (copy.velocity.length() > config.sleep_speed_threshold or copy.angular_velocity.length() > config.sleep_spin_threshold):
			_finish("moving layout")
	if done: return
	if _cue == null or not direction.is_finite() or not spin.is_finite() or not is_finite(cue_speed) or not CueStrikeModel.new().apply(_cue, direction, cue_speed, spin, 0.0, config):
		_finish("no stroke")
		return
	result.incoming.append(_cue.position)

func advance(max_ticks: int = FRAME_TICKS, budget_usec: int = FRAME_BUDGET_USEC) -> void:
	var start := Time.get_ticks_usec()
	for unused in range(maxi(0, max_ticks)):
		if done: return
		_tick()
		if budget_usec > 0 and Time.get_ticks_usec() - start >= budget_usec: return

func _tick() -> void:
	_stepper.step_fixed(_balls, _config.fixed_step, _config, _table)
	ticks += 1
	var events := _stepper.drain_events()
	if _hit_tick < 0:
		var contacts: Array[Dictionary] = []
		for event in events:
			if event.kind == "ball_contact": contacts.append(event)
			elif int(event.get("number", -1)) == 0:
				_finish("rail/pocket before ball")
				return
		if not contacts.is_empty():
			if contacts.size() != 1 or (contacts[0].a != 0 and contacts[0].b != 0):
				_finish("ambiguous contacts")
				return
			var number: int = contacts[0].b if contacts[0].a == 0 else contacts[0].a
			for ball in _balls:
				if ball.number == number: _object = ball
			for event in events:
				if event.kind != "ball_contact" and int(event.get("number", -1)) in [0, number]:
					_finish("mixed first-contact tick")
					return
			if _cue.phase != BallState.Phase.IN_PLAY or _object.phase != BallState.Phase.IN_PLAY:
				_finish("nonplanar first contact")
				return
			# Frozen/near-frozen neighbours can resolve on the next tick. Do not
			# claim a two-ball result for that cluster merely because events split.
			for ball in _balls:
				if ball == _cue or ball == _object or not ball.is_on_table(): continue
				if minf(ball.position.distance_to(_cue.position), ball.position.distance_to(_object.position)) < 2.0 * BallState.RADIUS + 0.003:
					_finish("cluster: outgoing omitted")
					return
			_hit_tick = ticks
			result.contact = _stepper.first_contact.centers[0]
			result.contact_event_position = _stepper.first_contact.position
			result.object_number = number
			result.cue_speed = _cue.velocity.length()
			result.object_speed = _object.velocity.length()
			for index in range(2):
				var ball: BallState = _cue if index == 0 else _object
				var key := "cue_path" if index == 0 else "object_path"
				var registered: Vector2 = _stepper.first_contact.centers[ball.number]
				result[key].append(registered)
				if registered != ball.position:
					result[key].append(ball.position)
					_distance[index] = registered.distance_to(ball.position)
			result.incoming.append(result.contact)
		else:
			result.incoming.append(_cue.position)
		if not _cue.is_on_table():
			_finish("pocket before ball")
			return
		if _hit_tick < 0 and (ticks * _config.fixed_step >= BEFORE_CONTACT_SECONDS or _stepper.are_balls_settled(_balls, _config)):
			_finish("no first ball in horizon")
	else:
		for index in range(2):
			if not _active[index]: continue
			var ball: BallState = _cue if index == 0 else _object
			for event in events:
				if (event.kind == "ball_contact" and (event.a == ball.number or event.b == ball.number)) or int(event.get("number", -1)) == ball.number:
					_active[index] = false
			# Active ball friction produces ordinary sub-mm hops on cuts. Project
			# those center paths; omit substantial flight rather than implying masse/jump support.
			if not ball.is_on_table() or ball.height > BallState.RADIUS + 0.002 or absf(ball.vertical_velocity) > 0.2: _active[index] = false
			if _active[index]:
				var key := "cue_path" if index == 0 else "object_path"
				var previous: Vector2 = result[key][-1]
				var travel := previous.distance_to(ball.position)
				if _distance[index] + travel >= MAX_PATH_METERS:
					result[key].append(previous.lerp(ball.position, (MAX_PATH_METERS - _distance[index]) / maxf(travel, 1.0e-9)))
					_active[index] = false
				else:
					result[key].append(ball.position)
					_distance[index] += travel
		if not _active[0] and not _active[1] or (ticks - _hit_tick) * _config.fixed_step >= AFTER_CONTACT_SECONDS or _stepper.are_balls_settled(_balls, _config):
			_finish("predicted")
	if ticks >= MAX_TICKS: _finish("predicted" if _hit_tick >= 0 else "simulation limit")

func _finish(status: String) -> void:
	done = true
	result.status = status
	result.ticks = ticks
	if status != "predicted":
		result.cue_path = PackedVector2Array()
		result.object_path = PackedVector2Array()
