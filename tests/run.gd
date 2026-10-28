extends SceneTree

const BallState = preload("res://scripts/sim/ball_state.gd")
const PhysicsConfig = preload("res://scripts/sim/physics_config.gd")
const PhysicsStepper = preload("res://scripts/sim/physics_stepper.gd")
const TableSpec = preload("res://scripts/sim/table_spec.gd")
const CueStrikeModel = preload("res://scripts/sim/cue_strike_model.gd")
const RackBuilder = preload("res://scripts/game/rack_builder.gd")
const EightBallMatch = preload("res://scripts/game/eight_ball_match.gd")
const EightBallShotEvent = preload("res://scripts/game/eight_ball_shot_event.gd")
const EightBallRules = preload("res://scripts/game/eight_ball_rules.gd")

var failures := 0
var assertions := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_test_equal_mass_head_on_collision_transfers_motion()
	_test_sliding_friction_transitions_to_rolling_without_reversal()
	_test_cushion_contact_reverses_normal_motion()
	_test_fixed_step_results_ignore_frame_chunking()
	_test_center_strike_has_no_spin_and_top_strike_adds_follow()
	_test_side_pocket_is_a_drop_event_not_a_trigger_teleport()
	_test_elevated_cue_produces_a_gravity_driven_airborne_ball()
	_test_eight_ball_rack_has_sixteen_separate_states()
	_test_nine_foot_table_uses_wpa_playing_surface_and_pocket_ranges()
	_test_open_table_assigns_group_only_on_called_pocket()
	_test_wrong_first_contact_fouls_and_grants_ball_in_hand()
	_test_called_pocket_mismatch_does_not_assign_a_group()
	_test_early_eight_loses_the_rack()
	_test_legal_called_eight_wins_after_group_is_cleared()
	_test_called_safety_passes_turn_after_legal_pot()
	_test_legal_break_pot_keeps_table_open_and_shooter_at_table()
	_test_legal_break_without_a_pot_passes_turn()
	_test_eight_on_legal_break_requires_a_choice()
	_test_scratch_on_break_requires_ball_in_hand_choice()
	_test_illegal_break_can_rerack_for_opponent()
	_test_out_of_turn_eight_is_a_losing_foul()
	_test_invalid_shooter_does_not_mutate_match()
	_test_invalid_call_does_not_hide_a_physical_foul()
	_test_no_rail_after_contact_is_a_standard_foul()
	_test_wrong_pocket_on_eight_loses_the_rack()
	_test_scratch_while_pocketing_eight_loses_the_rack()
	if failures == 0:
		print("PASS: %d simulation and rules assertions" % assertions)
		quit(0)
	else:
		printerr("FAIL: %d of %d physics assertions" % [failures, assertions])
		quit(1)


func _test_equal_mass_head_on_collision_transfers_motion() -> void:
	var config = _quiet_config()
	config.ball_restitution = 1.0
	config.ball_friction = 0.0
	var table = TableSpec.new()
	var first = BallState.new(0, 0, Vector2(-0.033, 0.0))
	var second = BallState.new(1, 1, Vector2(0.033, 0.0))
	first.velocity = Vector2(1.0, 0.0)
	var stepper = PhysicsStepper.new()
	stepper.advance([first, second], 0.12, config, table)
	_assert_near(first.velocity.x, 0.0, 0.03, "head-on striker nearly stops")
	_assert_near(second.velocity.x, 1.0, 0.03, "head-on object ball receives speed")
	_assert_true(first.position.distance_to(second.position) >= 2.0 * BallState.RADIUS - 0.0005,
		"colliding balls do not remain interpenetrating")


func _test_sliding_friction_transitions_to_rolling_without_reversal() -> void:
	var config = _quiet_config()
	config.sliding_friction = 0.2
	var ball = BallState.new(0, 0, Vector2.ZERO)
	ball.velocity = Vector2(1.0, 0.0)
	var stepper = PhysicsStepper.new()
	stepper.advance([ball], 0.25, config, TableSpec.new())
	var contact_slip = stepper.contact_slip(ball)
	_assert_true(ball.angular_velocity.z < -0.5, "forward sliding develops rolling spin")
	_assert_true(contact_slip.length() < 0.08, "sliding transitions toward rolling")
	_assert_true(ball.velocity.x > 0.0, "friction does not reverse translational motion")


func _test_cushion_contact_reverses_normal_motion() -> void:
	var config = _quiet_config()
	config.cushion_restitution = 0.82
	var table = TableSpec.new()
	var ball = BallState.new(0, 1, Vector2(table.half_size.x - BallState.RADIUS - 0.01, 0.0))
	ball.velocity = Vector2(2.0, 0.0)
	var stepper = PhysicsStepper.new()
	stepper.advance([ball], 0.025, config, table)
	_assert_true(ball.velocity.x < 0.0, "cushion sends the ball back into the table")
	_assert_true(ball.position.x <= table.half_size.x - BallState.RADIUS + 0.001,
		"cushion contact keeps the ball inside the playing boundary")


func _test_fixed_step_results_ignore_frame_chunking() -> void:
	var config = _quiet_config()
	config.sliding_friction = 0.17
	var one_frame_ball = BallState.new(0, 0, Vector2(-0.4, 0.1))
	var split_frame_ball = one_frame_ball.duplicate_state()
	one_frame_ball.velocity = Vector2(2.2, 0.37)
	split_frame_ball.velocity = one_frame_ball.velocity
	var one_frame_stepper = PhysicsStepper.new()
	var split_frame_stepper = PhysicsStepper.new()
	one_frame_stepper.advance([one_frame_ball], 0.5, config, TableSpec.new())
	split_frame_stepper.advance([split_frame_ball], 0.2, config, TableSpec.new())
	split_frame_stepper.advance([split_frame_ball], 0.3, config, TableSpec.new())
	_assert_near(one_frame_ball.position.distance_to(split_frame_ball.position), 0.0, 1.0e-9,
		"fixed simulation gives identical position across render-frame chunking")
	_assert_near(one_frame_ball.velocity.distance_to(split_frame_ball.velocity), 0.0, 1.0e-9,
		"fixed simulation gives identical velocity across render-frame chunking")


func _test_center_strike_has_no_spin_and_top_strike_adds_follow() -> void:
	var config = _quiet_config()
	var centered = BallState.new(0, 0, Vector2.ZERO)
	var elevated_tip = BallState.new(1, 0, Vector2.ZERO)
	var strike = CueStrikeModel.new()
	strike.apply(centered, Vector2.RIGHT, 2.5, Vector2.ZERO, 0.0, config)
	strike.apply(elevated_tip, Vector2.RIGHT, 2.5, Vector2(0.0, 0.3), 0.0, config)
	_assert_near(centered.angular_velocity.length(), 0.0, 1.0e-8, "center-ball contact does not invent spin")
	_assert_true(elevated_tip.angular_velocity.z < centered.angular_velocity.z,
		"tip above center generates forward rolling spin")
	_assert_true(elevated_tip.velocity.x > 0.0, "cue strike transfers momentum into the ball")


func _test_side_pocket_is_a_drop_event_not_a_trigger_teleport() -> void:
	var config = _quiet_config()
	var table = TableSpec.new()
	var ball = BallState.new(0, 1, Vector2(0.0, table.half_size.y - BallState.RADIUS - 0.012))
	ball.velocity = Vector2(0.0, 1.4)
	var stepper = PhysicsStepper.new()
	stepper.advance([ball], 0.02, config, table)
	_assert_true(ball.phase == BallState.Phase.FALLING, "side-pocket entry begins a physical drop")
	_assert_true(ball.height >= 0.0, "ball remains visible while it falls below the cloth")
	stepper.advance([ball], 0.18, config, table)
	_assert_true(ball.phase == BallState.Phase.POCKETED, "ball is captured only after falling into the pocket")


func _test_elevated_cue_produces_a_gravity_driven_airborne_ball() -> void:
	var config = _quiet_config()
	var ball = BallState.new(0, 0, Vector2.ZERO)
	var strike = CueStrikeModel.new()
	strike.apply(ball, Vector2.RIGHT, 3.0, Vector2.ZERO, deg_to_rad(22.0), config)
	var stepper = PhysicsStepper.new()
	stepper.advance([ball], 0.12, config, TableSpec.new())
	_assert_true(ball.phase == BallState.Phase.AIRBORNE, "elevated cue strike produces an airborne cue ball")
	_assert_true(ball.height > BallState.RADIUS + 0.05, "airborne trajectory rises above the cloth")
	_assert_true(ball.vertical_velocity < 2.0, "gravity reduces vertical speed during flight")


func _test_eight_ball_rack_has_sixteen_separate_states() -> void:
	var balls: Array[BallState] = RackBuilder.create_eight_ball_rack(TableSpec.new())
	_assert_true(balls.size() == 16, "eight-ball rack contains the cue ball and fifteen object balls")
	var numbers := {}
	for ball in balls:
		numbers[ball.number] = true
	_assert_true(numbers.size() == 16, "rack contains each ball number exactly once")
	_assert_true(numbers.has(8), "eight ball is present in the center row")


func _test_nine_foot_table_uses_wpa_playing_surface_and_pocket_ranges() -> void:
	var table = TableSpec.new()
	_assert_near(table.half_size.x * 2.0, 2.54, 1.0e-7, "nine-foot playing length follows WPA equipment dimensions")
	_assert_near(table.half_size.y * 2.0, 1.27, 1.0e-7, "nine-foot playing width follows WPA equipment dimensions")
	_assert_true(table.corner_mouth >= 0.1143 and table.corner_mouth <= 0.1175,
		"corner opening starts inside the WPA mouth range")
	_assert_true(table.side_mouth >= 0.127 and table.side_mouth <= 0.130175,
		"side opening starts inside the WPA mouth range")


func _test_open_table_assigns_group_only_on_called_pocket() -> void:
	var match_state = _normal_match()
	var shot = EightBallShotEvent.new(0)
	shot.first_contact_number = 9
	shot.called_ball_number = 9
	shot.called_pocket_id = 2
	shot.pocketed_numbers = PackedInt32Array([9])
	shot.pocket_ids[9] = 2
	var result = EightBallRules.new().apply_shot(match_state, shot)
	_assert_true(match_state.player_groups[0] == EightBallMatch.Group.STRIPES,
		"legally pocketed called stripe assigns stripes")
	_assert_true(match_state.current_player == 0, "called legal pot keeps the shooter at the table")
	_assert_true(not match_state.remaining_balls.has(9), "pocketed called ball leaves the rack state")
	_assert_true(not result["foul"], "legal open-table group assignment is not a foul")


func _test_wrong_first_contact_fouls_and_grants_ball_in_hand() -> void:
	var match_state = _normal_match()
	match_state.player_groups = PackedInt32Array([EightBallMatch.Group.SOLIDS, EightBallMatch.Group.STRIPES])
	var shot = EightBallShotEvent.new(0)
	shot.first_contact_number = 9
	shot.called_ball_number = 1
	shot.called_pocket_id = 0
	shot.rail_after_contact = true
	var result = EightBallRules.new().apply_shot(match_state, shot)
	_assert_true(result["foul"], "wrong group contacted first is a foul")
	_assert_true(match_state.current_player == 1, "foul passes the turn")
	_assert_true(match_state.cue_ball_in_hand, "foul grants cue-ball-in-hand")


func _test_called_pocket_mismatch_does_not_assign_a_group() -> void:
	var match_state = _normal_match()
	var shot = EightBallShotEvent.new(0)
	shot.first_contact_number = 11
	shot.called_ball_number = 11
	shot.called_pocket_id = 1
	shot.pocketed_numbers = PackedInt32Array([11])
	shot.pocket_ids[11] = 4
	var result = EightBallRules.new().apply_shot(match_state, shot)
	_assert_true(match_state.player_groups[0] == EightBallMatch.Group.OPEN,
		"pocketing the called ball in another pocket does not assign a group")
	_assert_true(match_state.current_player == 1, "called-pocket mismatch passes the turn")
	_assert_true(not result["foul"], "a called-pocket miss is not a physical foul")


func _test_early_eight_loses_the_rack() -> void:
	var match_state = _normal_match()
	match_state.player_groups = PackedInt32Array([EightBallMatch.Group.SOLIDS, EightBallMatch.Group.STRIPES])
	match_state.remaining_balls = PackedInt32Array([2, 8, 9])
	var shot = EightBallShotEvent.new(0)
	shot.first_contact_number = 2
	shot.called_ball_number = 2
	shot.called_pocket_id = 0
	shot.pocketed_numbers = PackedInt32Array([8])
	shot.pocket_ids[8] = 3
	var result = EightBallRules.new().apply_shot(match_state, shot)
	_assert_true(result["game_over"], "early eight ends the rack")
	_assert_true(match_state.winner == 1, "opponent wins after early eight")


func _test_legal_called_eight_wins_after_group_is_cleared() -> void:
	var match_state = _normal_match()
	match_state.player_groups = PackedInt32Array([EightBallMatch.Group.SOLIDS, EightBallMatch.Group.STRIPES])
	match_state.remaining_balls = PackedInt32Array([8])
	var shot = EightBallShotEvent.new(0)
	shot.first_contact_number = 8
	shot.called_ball_number = 8
	shot.called_pocket_id = 2
	shot.pocketed_numbers = PackedInt32Array([8])
	shot.pocket_ids[8] = 2
	var result = EightBallRules.new().apply_shot(match_state, shot)
	_assert_true(result["game_over"], "legal called eight completes the rack")
	_assert_true(match_state.winner == 0, "shooter wins after clearing their group")


func _test_called_safety_passes_turn_after_legal_pot() -> void:
	var match_state = _normal_match()
	match_state.player_groups = PackedInt32Array([EightBallMatch.Group.SOLIDS, EightBallMatch.Group.STRIPES])
	var shot = EightBallShotEvent.new(0)
	shot.first_contact_number = 1
	shot.is_safety = true
	shot.pocketed_numbers = PackedInt32Array([1])
	shot.pocket_ids[1] = 0
	var result = EightBallRules.new().apply_shot(match_state, shot)
	_assert_true(not result["foul"], "called safety can be a legal shot")
	_assert_true(match_state.current_player == 1, "safety passes play to the opponent")
	_assert_true(not match_state.remaining_balls.has(1), "ball pocketed on safety stays down")


func _test_legal_break_pot_keeps_table_open_and_shooter_at_table() -> void:
	var match_state = EightBallMatch.new(0)
	var shot = EightBallShotEvent.new(0)
	shot.pocketed_numbers = PackedInt32Array([3])
	shot.pocket_ids[3] = 1
	var result = EightBallRules.new().apply_shot(match_state, shot)
	_assert_true(not result["foul"], "potted object ball makes this a legal break")
	_assert_true(not match_state.break_pending, "regular play follows a legal break")
	_assert_true(match_state.player_groups[0] == EightBallMatch.Group.OPEN,
		"pocket on the break leaves the table open")
	_assert_true(match_state.current_player == 0, "legal break pot keeps breaker at the table")


func _test_legal_break_without_a_pot_passes_turn() -> void:
	var match_state = EightBallMatch.new(0)
	var shot = EightBallShotEvent.new(0)
	shot.break_balls_to_rail = 4
	var result = EightBallRules.new().apply_shot(match_state, shot)
	_assert_true(not result["foul"], "four object balls to rails makes a no-pot break legal")
	_assert_true(match_state.current_player == 1, "legal no-pot break passes play")
	_assert_true(not match_state.break_pending, "legal break closes the break phase")


func _test_eight_on_legal_break_requires_a_choice() -> void:
	var match_state = EightBallMatch.new(0)
	var shot = EightBallShotEvent.new(0)
	shot.pocketed_numbers = PackedInt32Array([8])
	shot.pocket_ids[8] = 2
	var rules = EightBallRules.new()
	var result = rules.apply_shot(match_state, shot)
	_assert_true(result["decision_required"] == EightBallMatch.Decision.EIGHT_ON_LEGAL_BREAK,
		"eight on a legal break presents the WPA choice")
	var resolved = rules.resolve_break_choice(match_state, EightBallMatch.BreakChoice.SPOT_EIGHT_AND_CONTINUE)
	_assert_true(resolved["valid"], "spot-eight option resolves")
	_assert_true(not match_state.break_pending and match_state.current_player == 0,
		"spot-eight option continues with breaker on an open table")
	_assert_true(match_state.remaining_balls.has(8), "spotted eight remains in play")


func _test_scratch_on_break_requires_ball_in_hand_choice() -> void:
	var match_state = EightBallMatch.new(0)
	var shot = EightBallShotEvent.new(0)
	shot.cue_ball_scratched = true
	shot.break_balls_to_rail = 4
	var rules = EightBallRules.new()
	var result = rules.apply_shot(match_state, shot)
	_assert_true(result["decision_required"] == EightBallMatch.Decision.FOUL_BREAK,
		"break scratch records the opponent choice")
	var resolved = rules.resolve_break_choice(match_state, EightBallMatch.BreakChoice.TAKE_BALL_IN_HAND)
	_assert_true(resolved["valid"], "ball-in-hand option resolves")
	_assert_true(match_state.current_player == 1 and match_state.cue_ball_in_hand,
		"incoming player receives ball in hand after break scratch")


func _test_illegal_break_can_rerack_for_opponent() -> void:
	var match_state = EightBallMatch.new(0)
	var shot = EightBallShotEvent.new(0)
	var rules = EightBallRules.new()
	var result = rules.apply_shot(match_state, shot)
	_assert_true(result["decision_required"] == EightBallMatch.Decision.ILLEGAL_BREAK,
		"no-pot break with fewer than four rail contacts needs a decision")
	var resolved = rules.resolve_break_choice(match_state, EightBallMatch.BreakChoice.RERACK_AND_OPPONENT_BREAKS)
	_assert_true(resolved["valid"], "opponent-breaks option resolves")
	_assert_true(match_state.break_pending and match_state.current_player == 1,
		"re-racked match assigns the next break to the opponent")
	_assert_true(match_state.remaining_balls.size() == 15,
		"re-rack restores the complete object-ball set")


func _test_out_of_turn_eight_is_a_losing_foul() -> void:
	var match_state = _normal_match()
	match_state.player_groups = PackedInt32Array([EightBallMatch.Group.SOLIDS, EightBallMatch.Group.STRIPES])
	match_state.remaining_balls = PackedInt32Array([8])
	var shot = EightBallShotEvent.new(1)
	shot.first_contact_number = 8
	shot.called_ball_number = 8
	shot.called_pocket_id = 3
	shot.pocketed_numbers = PackedInt32Array([8])
	shot.pocket_ids[8] = 3
	var result = EightBallRules.new().apply_shot(match_state, shot)
	_assert_true(result["game_over"], "out-of-turn eight pocket is still an eight-ball foul loss")
	_assert_true(match_state.winner == 0, "the rightful player wins after an out-of-turn eight")


func _test_invalid_shooter_does_not_mutate_match() -> void:
	var match_state = _normal_match()
	var shot = EightBallShotEvent.new(2)
	shot.first_contact_number = 1
	var result = EightBallRules.new().apply_shot(match_state, shot)
	_assert_true(not result["valid"], "invalid player index is rejected")
	_assert_true(match_state.current_player == 0 and not match_state.cue_ball_in_hand,
		"invalid player index leaves the match untouched")


func _test_invalid_call_does_not_hide_a_physical_foul() -> void:
	var match_state = _normal_match()
	match_state.player_groups = PackedInt32Array([EightBallMatch.Group.SOLIDS, EightBallMatch.Group.STRIPES])
	var shot = EightBallShotEvent.new(0)
	shot.first_contact_number = 9
	shot.called_ball_number = 9
	shot.called_pocket_id = 0
	shot.cue_ball_scratched = true
	var result = EightBallRules.new().apply_shot(match_state, shot)
	_assert_true(result["foul"], "physical scratch is processed even when shot call is invalid")
	_assert_true(match_state.current_player == 1 and match_state.cue_ball_in_hand,
		"invalid call cannot suppress foul turn consequences")


func _test_no_rail_after_contact_is_a_standard_foul() -> void:
	var match_state = _normal_match()
	match_state.player_groups = PackedInt32Array([EightBallMatch.Group.SOLIDS, EightBallMatch.Group.STRIPES])
	var shot = EightBallShotEvent.new(0)
	shot.first_contact_number = 1
	shot.called_ball_number = 2
	shot.called_pocket_id = 0
	var result = EightBallRules.new().apply_shot(match_state, shot)
	_assert_true(result["foul"] and result["foul_reason"] == "no_rail_after_contact",
		"no rail after a non-pocketed contact is a foul")
	_assert_true(match_state.cue_ball_in_hand and match_state.current_player == 1,
		"no-rail foul passes the turn with ball in hand")


func _test_wrong_pocket_on_eight_loses_the_rack() -> void:
	var match_state = _eligible_eight_match()
	var shot = EightBallShotEvent.new(0)
	shot.first_contact_number = 8
	shot.called_ball_number = 8
	shot.called_pocket_id = 2
	shot.pocketed_numbers = PackedInt32Array([8])
	shot.pocket_ids[8] = 3
	var result = EightBallRules.new().apply_shot(match_state, shot)
	_assert_true(result["game_over"] and match_state.winner == 1,
		"eight pocketed in an uncalled pocket loses the rack")


func _test_scratch_while_pocketing_eight_loses_the_rack() -> void:
	var match_state = _eligible_eight_match()
	var shot = EightBallShotEvent.new(0)
	shot.first_contact_number = 8
	shot.called_ball_number = 8
	shot.called_pocket_id = 2
	shot.pocketed_numbers = PackedInt32Array([8])
	shot.pocket_ids[8] = 2
	shot.cue_ball_scratched = true
	var result = EightBallRules.new().apply_shot(match_state, shot)
	_assert_true(result["game_over"] and result["winner"] == 1,
		"cue-ball scratch while pocketing the eight loses the rack")
	_assert_true(result["foul"], "eight-ball loss also reports the foul")


func _normal_match():
	var match_state = EightBallMatch.new(0)
	match_state.break_pending = false
	return match_state


func _eligible_eight_match():
	var match_state = _normal_match()
	match_state.player_groups = PackedInt32Array([EightBallMatch.Group.SOLIDS, EightBallMatch.Group.STRIPES])
	match_state.remaining_balls = PackedInt32Array([8])
	return match_state


func _quiet_config():
	var config = PhysicsConfig.new()
	config.fixed_step = 1.0 / 480.0
	config.sliding_friction = 0.0
	config.rolling_resistance = 0.0
	config.spin_decay_rate = 0.0
	config.ball_restitution = 0.98
	config.ball_friction = 0.04
	config.cushion_restitution = 0.86
	config.cushion_friction = 0.08
	return config


func _assert_true(condition: bool, label: String) -> void:
	assertions += 1
	if not condition:
		failures += 1
		printerr("FAIL: " + label)


func _assert_near(actual: float, expected: float, tolerance: float, label: String) -> void:
	_assert_true(absf(actual - expected) <= tolerance,
		"%s (actual %.9f, expected %.9f ± %.9f)" % [label, actual, expected, tolerance])
