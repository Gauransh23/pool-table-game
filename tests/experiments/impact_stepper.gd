extends "res://scripts/sim/physics_stepper.gd"
# Experimental ball-ball event slicing. Rails retain the bounded travel solver.
var exhausted_event_budgets := 0
const MAX_EVENTS := 16
const TIME_EPSILON := 1.0e-9

func step_fixed(balls: Array, delta: float, config: PhysicsConfig, table: TableSpec) -> void:
	if delta <= 0.0: return
	tick_count += 1
	var rails := table.rail_segments()
	var fastest := 0.0
	for ball in balls:
		if _can_collide(ball): fastest = maxf(fastest,maxf(ball.velocity.length(),absf(ball.vertical_velocity)))
	var limit := maxf(.006,BallState.RADIUS*config.max_substep_travel_fraction)
	var subdivisions := maxi(1,ceili(fastest*delta/limit))
	for substep in range(subdivisions):
		var remaining := delta/float(subdivisions)
		var events := 0
		while remaining > 1.0e-12:
			_snapshot(balls)
			_solve_contacts(balls,0.0,config,table,rails)
			_classify_exits(balls,table)
			var duration := remaining
			if events < MAX_EVENTS:
				duration = minf(remaining,maxf(TIME_EPSILON,_next_impact(balls,remaining)))
			else:
				exhausted_event_budgets += 1
			_snapshot(balls)
			_integrate_balls(balls,duration,config,table)
			_solve_contacts(balls,duration,config,table,rails)
			_classify_exits(balls,table)
			remaining = maxf(0.0,remaining-duration)
			events += 1

func _snapshot(balls: Array) -> void:
	_previous_positions.resize(balls.size())
	_previous_velocities.resize(balls.size())
	for i in range(balls.size()):
		var ball: BallState = balls[i]
		_previous_positions[i] = Vector3(ball.position.x,ball.height,ball.position.y)
		_previous_velocities[i] = Vector3(ball.velocity.x,ball.vertical_velocity,ball.velocity.y)

func _solve_contacts(balls: Array, duration: float, config: PhysicsConfig, table: TableSpec, rails: Array) -> void:
	for iteration in range(config.max_collision_iterations):
		var contacted := false
		for i in range(balls.size()):
			var first: BallState = balls[i]
			if not _can_collide(first): continue
			for j in range(i+1,balls.size()):
				var second: BallState = balls[j]
				if not _can_collide(second): continue
				contacted = _resolve_ball_pair(first,second,config,_previous_positions[j]-_previous_positions[i],_previous_velocities[j]-_previous_velocities[i],duration) or contacted
		# Pre-slice resolution is for ball contacts only. Keep the accepted rail /
		# slate impulse ordering after integration until that coupled model is replaced.
		if duration == 0.0:
			if not contacted: break
			continue
		for ball in balls:
			if _can_collide(ball): contacted = _resolve_rails(ball,config,table,rails) or contacted
			if ball.phase == BallState.Phase.FALLING:
				contacted = _resolve_slate_edge(ball,config,table) or contacted
				contacted = _resolve_pocket_liner(ball,config,table) or contacted
		if not contacted: break

func _next_impact(balls: Array, horizon: float) -> float:
	var earliest := horizon
	var diameter := BallState.RADIUS*2.0
	for i in range(balls.size()):
		var first: BallState = balls[i]
		if not _can_collide(first): continue
		for j in range(i+1,balls.size()):
			var second: BallState = balls[j]
			if not _can_collide(second): continue
			var p := Vector3(second.position.x-first.position.x,second.height-first.height,second.position.y-first.position.y)
			var v := Vector3(second.velocity.x-first.velocity.x,second.vertical_velocity-first.vertical_velocity,second.velocity.y-first.velocity.y)
			var c := p.length_squared()-diameter*diameter
			var a := v.length_squared()
			var b := 2.0*p.dot(v)
			if c <= 1.0e-12 or a <= 1.0e-12 or b >= 0.0: continue
			var discriminant := b*b-4.0*a*c
			if discriminant < 0.0: continue
			var t := (-b-sqrt(discriminant))/(2.0*a)
			if t >= TIME_EPSILON and t < earliest: earliest = t
	return earliest

func _resolve_ball_pair(first: BallState, second: BallState, config: PhysicsConfig, previous_separation: Vector3, previous_relative_velocity: Vector3, sub_delta: float) -> bool:
	var separation := Vector3(second.position.x-first.position.x,second.height-first.height,second.position.y-first.position.y)
	var diameter := 2.0*BallState.RADIUS
	var distance := separation.length()
	# Exactly touching, approaching spheres are a contact. A 0.1nm numerical
	# nudge lets the inherited overlap helper consume that event without drift.
	if distance >= diameter and distance <= diameter+1.0e-9:
		var normal := separation.normalized()
		var relative := Vector3(second.velocity.x-first.velocity.x,second.vertical_velocity-first.vertical_velocity,second.velocity.y-first.velocity.y)
		if relative.dot(normal) >= 0.0: return false
		first.position += Vector2(normal.x,normal.z)*1.0e-10
		second.position -= Vector2(normal.x,normal.z)*1.0e-10
		first.height += normal.y*1.0e-10
		second.height -= normal.y*1.0e-10
	return super._resolve_ball_pair(first,second,config,previous_separation,previous_relative_velocity,sub_delta)
