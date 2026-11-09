extends RefCounted
# Version 1 deliberately accepts only settled practice starts on the current profile.
static func validate(data: Variant) -> String:
	if not data is Dictionary: return "fixture must be an object"
	if data.get("schema") != "long-rail-shot/1": return "unsupported fixture schema"
	if data.get("units") != "m,s,kg,rad": return "unsupported units"
	if data.get("profile") != "active-default": return "unsupported profile"
	if data.get("seed") != 0: return "active physics is seedless; seed must be zero"
	if not data.get("id") is String or data.id.is_empty(): return "missing fixture id"
	if not data.get("ticks") is float and not data.get("ticks") is int: return "ticks must be numeric"
	if not is_finite(float(data.ticks)) or data.ticks < 1 or data.ticks > 9600 or data.ticks != int(data.ticks): return "ticks outside bounded domain"
	if not data.get("balls") is Array or data.balls.size() != 16: return "require full 16-ball inventory"
	var ids := {}
	var numbers := {}
	for state in data.balls:
		if not state is Array or state.size() != 17: return "invalid canonical ball state"
		for value in state:
			if not (value is float or value is int) or not is_finite(float(value)): return "nonfinite or nonnumeric state"
		for index in [0, 1, 15, 16]:
			if state[index] != int(state[index]): return "noninteger identity/phase"
		if state[0] < 0 or state[0] > 15 or state[1] < 0 or state[1] > 15 or ids.has(int(state[0])) or numbers.has(int(state[1])): return "duplicate/out-of-range identity"
		ids[int(state[0])] = true
		numbers[int(state[1])] = true
		if state[15] != BallState.Phase.IN_PLAY and state[15] != BallState.Phase.POCKETED: return "start must be settled"
		if state[16] < -1 or state[16] > 5: return "invalid pocket identity"
		for index in range(5, 11):
			if state[index] != 0: return "moving fixture start"
		var q := Quaternion(state[11],state[12],state[13],state[14])
		if absf(q.length_squared()-1.0) > 1e-6: return "invalid orientation"
		if state[15] == BallState.Phase.IN_PLAY:
			if absf(state[2]) > 1.2 or absf(state[3]) > .56 or absf(state[4]-BallState.RADIUS) > 1e-6 or state[16] != -1: return "invalid on-table state"
		elif state[4] != -.18 or state[16] == -1: return "invalid pocketed state"
	if data.balls[0][1] != 0: return "cue must be first in controller inventory"
	var cue: Array = data.balls[0]
	if cue[15] != BallState.Phase.IN_PLAY: return "cue must be on table"
	for i in range(16):
		for j in range(i+1,16):
			var a: Array = data.balls[i]; var b: Array = data.balls[j]
			if a[15] == 0 and b[15] == 0 and Vector2(a[2],a[3]).distance_to(Vector2(b[2],b[3])) < 2*BallState.RADIUS: return "overlapping start"
	var input: Variant = data.get("input")
	if not input is Dictionary: return "missing input"
	for key in ["power", "angle_radians", "tip_x", "tip_y"]:
		if not (input.get(key) is float or input.get(key) is int) or not is_finite(float(input[key])): return "invalid input"
	if input.power <= 0 or input.power > 1 or Vector2(input.tip_x,input.tip_y).length() > CueStrikeModel.MAX_TIP_OFFSET: return "unsupported input"
	if not data.get("expected_events") is Array or data.expected_events.is_empty(): return "expected events required"
	for kind in data.expected_events:
		if kind not in ["ball_contact","rail","pocket"]: return "invalid expected event kind"
	return ""

static func instantiate_balls(data: Dictionary) -> Array[BallState]:
	var balls: Array[BallState] = []
	for s in data.balls:
		var ball := BallState.new(int(s[0]),int(s[1]),Vector2(s[2],s[3]))
		ball.height=s[4]; ball.velocity=Vector2(s[5],s[6]); ball.vertical_velocity=s[7]
		ball.angular_velocity=Vector3(s[8],s[9],s[10]); ball.orientation=Quaternion(s[11],s[12],s[13],s[14])
		ball.phase=int(s[15]); ball.pocket_id=int(s[16]); balls.append(ball)
	return balls

static func states(balls: Array) -> Array:
	var result := []
	for ball in balls: result.append(Array(ball.canonical_state()))
	return result
