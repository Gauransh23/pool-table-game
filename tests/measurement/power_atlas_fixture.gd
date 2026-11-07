extends RefCounted
# Deliberately separate from the settled, 16-ball acquisition schema.
const SCHEMA := "long-rail-power-atlas-fixture/1"
const PROFILE := {"fixed_step":1.0/480.0,"gravity":9.81,"ball_mass":0.168,"ball_restitution":0.94,"ball_friction":0.055,"cushion_restitution":0.84,"cushion_friction":0.12,"sliding_friction":0.19,"rolling_resistance":0.012,"spinning_friction":0.0127,"sleep_speed_threshold":0.012,"sleep_spin_threshold":0.08,"max_speed":14.0,"max_substep_travel_fraction":0.45,"max_collision_iterations":6,"cue_mass":0.52,"cue_collision_efficiency":0.87,"cue_end_mass":0.008,"pocket_liner_restitution":0.2}

static func numeric_properties(object: Object) -> Dictionary:
	var result := {}
	for property in object.get_property_list():
		if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			var value: Variant = object.get(property.name)
			if value is float or value is int or value is bool: result[property.name]=value
	return result

static func finite_tree(value: Variant) -> bool:
	if value is float: return is_finite(value)
	if value is Array:
		for item in value:
			if not finite_tree(item): return false
	if value is Dictionary:
		for item in value.values():
			if not finite_tree(item): return false
	return true

static func validate(data: Variant) -> String:
	if not data is Array or data.is_empty(): return "empty/non-array fixture set"
	var ids := {}
	for f in data:
		if not f is Dictionary or not finite_tree(f): return "malformed/nonfinite fixture"
		if f.get("schema") != SCHEMA: return "schema mismatch"
		if not f.get("profile") is Dictionary or f.profile.size()!=PROFILE.size(): return "profile mismatch"
		for key in PROFILE:
			if not f.profile.has(key) or absf(float(f.profile[key])-float(PROFILE[key]))>1e-15: return "profile mismatch: "+key
		if not f.get("id") is String or f.id.is_empty() or ids.has(f.id): return "empty/duplicate id"
		ids[f.id]=true
		if f.get("family") not in ["free","launch","rail","object","rolling"]: return "unknown family"
		if not f.get("ticks") is int and not f.get("ticks") is float: return "missing cap"
		if f.ticks < 0 or f.ticks > (60000 if f.family=="rolling" else 40000) or f.ticks != int(f.ticks): return "invalid cap"
		if f.get("termination") not in ["rest","horizon","launch"]: return "invalid termination"
		if f.get("modality") not in ["controller","direct"]: return "invalid modality"
		for key in ["power","cue_speed","elevation"]:
			if not (f.get(key) is float or f.get(key) is int): return "invalid numeric input"
		if f.power < 0 or f.power > 1 or f.cue_speed < 0 or f.cue_speed > 8 or f.elevation != 0: return "unsupported qualified input"
		for key in ["tip","direction","half_size"]:
			if not f.get(key) is Array or f[key].size()!=2: return "invalid vector"
			for n in f[key]:
				if not (n is float or n is int): return "nonnumeric vector"
		if Vector2(f.tip[0],f.tip[1]).length() > .500011 or Vector2(f.direction[0],f.direction[1]).length() < .99: return "invalid input domain"
		if f.half_size[0] < 1.27 or f.half_size[1] < .635: return "invalid geometry"
		if not f.get("event_policy") is Dictionary or f.event_policy.get("required") != []: return "scout events must not be forced"
		if not f.get("balls") is Array or f.balls.is_empty() or f.balls.size()>2: return "invalid inventory"
		var ball_ids := {}
		for s in f.balls:
			if not s is Array or s.size()!=17: return "invalid canonical state"
			for n in s:
				if not (n is float or n is int): return "nonnumeric state"
			if s[0]!=int(s[0]) or ball_ids.has(s[0]) or s[0]<0 or s[0]>15 or s[1]!=s[0]: return "invalid identity"
			ball_ids[s[0]]=true
			if s[15]!=0 or s[16]!=-1 or absf(s[4]-BallState.RADIUS)>1e-9: return "invalid initial phase/height"
			if absf(s[2])>=f.half_size[0]-BallState.RADIUS or absf(s[3])>=f.half_size[1]-BallState.RADIUS: return "out of geometry"
			if absf(Quaternion(s[11],s[12],s[13],s[14]).length_squared()-1)>1e-6: return "invalid orientation"
			if f.family!="rolling":
				for index in range(5,11):
					if s[index]!=0: return "moving qualified strike"
		if f.balls[0][0]!=0: return "cue must be first"
		if f.balls.size()==2 and Vector2(f.balls[0][2],f.balls[0][3]).distance_to(Vector2(f.balls[1][2],f.balls[1][3])) < 2*BallState.RADIUS: return "overlap"
	return ""
