extends RefCounted
class_name EightBallRules

const OPEN := EightBallMatch.Group.OPEN
const SOLIDS := EightBallMatch.Group.SOLIDS
const STRIPES := EightBallMatch.Group.STRIPES


func apply_shot(match_state: EightBallMatch, shot: EightBallShotEvent) -> Dictionary:
	var outcome := _outcome()
	if match_state.game_over:
		return _invalid(outcome, "The rack is already over.")
	if match_state.pending_break_decision != EightBallMatch.Decision.NONE:
		return _invalid(outcome, "Resolve the break decision before taking another shot.")
	if shot.shooter < 0 or shot.shooter > 1:
		return _invalid(outcome, "Shooter index must be player 0 or 1.")
	if shot.shooter != match_state.current_player:
		if match_state.break_pending:
			_remove_break_balls(match_state, shot)
			match_state.pending_break_decision = EightBallMatch.Decision.EIGHT_ON_FOUL_BREAK if shot.pocketed_numbers.has(8) or shot.object_balls_off_table.has(8) else EightBallMatch.Decision.FOUL_BREAK
			outcome["foul"] = true
			outcome["foul_reason"] = "played_out_of_turn"
			outcome["decision_required"] = match_state.pending_break_decision
			return outcome
		if shot.pocketed_numbers.has(8) or shot.object_balls_off_table.has(8):
			_remove_pocketed(match_state, shot)
			match_state.game_over = true
			match_state.winner = match_state.current_player
			outcome["foul"] = true
			outcome["foul_reason"] = "loss_of_rack_on_eight_ball"
			outcome["game_over"] = true
			outcome["winner"] = match_state.current_player
			outcome["message"] = "Out-of-turn eight-ball loss."
			return outcome
		return _apply_foul(match_state, shot, outcome, "played_out_of_turn")
	if match_state.break_pending:
		return _apply_break(match_state, shot, outcome)
	return _apply_normal_shot(match_state, shot, outcome)


func resolve_break_choice(match_state: EightBallMatch, choice: EightBallMatch.BreakChoice) -> Dictionary:
	var outcome := _outcome()
	var decision := match_state.pending_break_decision
	if decision == EightBallMatch.Decision.NONE:
		return _invalid(outcome, "There is no pending break decision.")
	match_state.pending_break_decision = EightBallMatch.Decision.NONE
	match_state.cue_ball_in_hand = false
	match_state.game_over = false
	match_state.winner = -1
	match_state.player_groups = PackedInt32Array([OPEN, OPEN])
	if decision == EightBallMatch.Decision.ILLEGAL_BREAK:
		if choice == EightBallMatch.BreakChoice.ACCEPT_TABLE:
			match_state.break_pending = false
			match_state.current_player = 1 - match_state.breaker
		elif choice == EightBallMatch.BreakChoice.RERACK_AND_BREAKER_BREAKS:
			match_state.reset_rack(match_state.breaker)
		elif choice == EightBallMatch.BreakChoice.RERACK_AND_OPPONENT_BREAKS:
			match_state.reset_rack(1 - match_state.breaker)
		else:
			return _invalid_after_restore(match_state, outcome, decision)
	elif decision == EightBallMatch.Decision.FOUL_BREAK:
		if choice == EightBallMatch.BreakChoice.ACCEPT_TABLE:
			match_state.break_pending = false
			match_state.current_player = 1 - match_state.breaker
		elif choice == EightBallMatch.BreakChoice.TAKE_BALL_IN_HAND:
			match_state.break_pending = false
			match_state.current_player = 1 - match_state.breaker
			match_state.cue_ball_in_hand = true
		else:
			return _invalid_after_restore(match_state, outcome, decision)
	elif decision == EightBallMatch.Decision.EIGHT_ON_LEGAL_BREAK:
		if choice == EightBallMatch.BreakChoice.SPOT_EIGHT_AND_CONTINUE:
			match_state.break_pending = false
			match_state.current_player = match_state.breaker
		elif choice == EightBallMatch.BreakChoice.RERACK_AND_BREAKER_BREAKS:
			match_state.reset_rack(match_state.breaker)
		else:
			return _invalid_after_restore(match_state, outcome, decision)
	elif decision == EightBallMatch.Decision.EIGHT_ON_FOUL_BREAK:
		if choice == EightBallMatch.BreakChoice.SPOT_EIGHT_WITH_BALL_IN_HAND:
			match_state.break_pending = false
			match_state.current_player = 1 - match_state.breaker
			match_state.cue_ball_in_hand = true
		elif choice == EightBallMatch.BreakChoice.RERACK_AND_OPPONENT_BREAKS:
			match_state.reset_rack(1 - match_state.breaker)
		else:
			return _invalid_after_restore(match_state, outcome, decision)
	outcome["valid"] = true
	outcome["decision_required"] = EightBallMatch.Decision.NONE
	outcome["turn_changed"] = match_state.current_player != match_state.breaker
	return outcome


func _apply_break(match_state: EightBallMatch, shot: EightBallShotEvent, outcome: Dictionary) -> Dictionary:
	var has_potted_object := _has_object_ball(shot.pocketed_numbers)
	var eight_on_break := shot.pocketed_numbers.has(8) or shot.object_balls_off_table.has(8)
	var foul_reason := _break_foul_reason(shot)
	_remove_break_balls(match_state, shot)
	if eight_on_break:
		match_state.pending_break_decision = EightBallMatch.Decision.EIGHT_ON_FOUL_BREAK if not foul_reason.is_empty() else EightBallMatch.Decision.EIGHT_ON_LEGAL_BREAK
		outcome["foul"] = not foul_reason.is_empty()
		outcome["foul_reason"] = foul_reason
		outcome["decision_required"] = match_state.pending_break_decision
		return outcome
	if not foul_reason.is_empty():
		match_state.pending_break_decision = EightBallMatch.Decision.FOUL_BREAK
		outcome["foul"] = true
		outcome["foul_reason"] = foul_reason
		outcome["decision_required"] = match_state.pending_break_decision
		return outcome
	if not has_potted_object and shot.break_balls_to_rail < 4:
		match_state.pending_break_decision = EightBallMatch.Decision.ILLEGAL_BREAK
		outcome["decision_required"] = match_state.pending_break_decision
		return outcome
	match_state.break_pending = false
	if not has_potted_object:
		match_state.current_player = 1 - match_state.breaker
		outcome["turn_changed"] = true
	else:
		match_state.current_player = match_state.breaker
	return outcome


func _apply_normal_shot(match_state: EightBallMatch, shot: EightBallShotEvent, outcome: Dictionary) -> Dictionary:
	var eight_potted := shot.pocketed_numbers.has(8) or shot.object_balls_off_table.has(8)
	var called_valid := shot.is_safety or _called_ball_is_valid(match_state, shot)
	var foul_reason := _normal_foul_reason(match_state, shot)
	if eight_potted:
		var group_cleared := match_state.player_groups[shot.shooter] != OPEN and match_state.remaining_group_count(shot.shooter) == 0
		var called_eight := shot.called_ball_number == 8 and shot.pocket_ids.has(8) and int(shot.pocket_ids[8]) == shot.called_pocket_id
		if foul_reason.is_empty() and group_cleared and called_eight and not shot.is_safety:
			match_state.remove_ball(8)
			_remove_pocketed(match_state, shot)
			match_state.game_over = true
			match_state.winner = shot.shooter
			outcome["game_over"] = true
			outcome["winner"] = shot.shooter
			outcome["message"] = "Legal eight-ball win."
			return outcome
		match_state.remove_ball(8)
		_remove_pocketed(match_state, shot)
		match_state.game_over = true
		match_state.winner = 1 - shot.shooter
		outcome["foul"] = true
		outcome["foul_reason"] = "loss_of_rack_on_eight_ball"
		outcome["game_over"] = true
		outcome["winner"] = 1 - shot.shooter
		outcome["message"] = "Eight-ball loss condition."
		return outcome
	if not foul_reason.is_empty():
		return _apply_foul(match_state, shot, outcome, foul_reason)
	var called_ball_pocketed := called_valid and _called_ball_was_pocketed(shot)
	_remove_pocketed(match_state, shot)
	if match_state.player_groups[shot.shooter] == OPEN and called_ball_pocketed:
		var assigned_group := match_state.group_for_ball(shot.called_ball_number)
		match_state.player_groups[shot.shooter] = assigned_group
		match_state.player_groups[1 - shot.shooter] = STRIPES if assigned_group == SOLIDS else SOLIDS
		outcome["group_assigned"] = assigned_group
	var continue_turn := called_ball_pocketed and not shot.is_safety
	if not continue_turn:
		match_state.current_player = 1 - shot.shooter
		outcome["turn_changed"] = true
	match_state.cue_ball_in_hand = false
	return outcome


func _normal_foul_reason(match_state: EightBallMatch, shot: EightBallShotEvent) -> String:
	if shot.cue_ball_scratched:
		return "cue_ball_scratch"
	if shot.cue_ball_off_table:
		return "cue_ball_off_table"
	if not shot.object_balls_off_table.is_empty():
		return "object_ball_off_table"
	if shot.first_contact_number < 1 or not match_state.remaining_balls.has(shot.first_contact_number):
		return "no_legal_first_contact"
	var shooter_group: int = match_state.player_groups[shot.shooter]
	var own_remaining := match_state.remaining_group_count(shot.shooter)
	if shot.first_contact_number == 8:
		if shooter_group == OPEN or own_remaining > 0:
			return "wrong_ball_first"
	elif shooter_group != OPEN and own_remaining > 0 and match_state.group_for_ball(shot.first_contact_number) != shooter_group:
		return "wrong_ball_first"
	if shot.pocketed_numbers.is_empty() and not shot.rail_after_contact:
		return "no_rail_after_contact"
	return ""


func _break_foul_reason(shot: EightBallShotEvent) -> String:
	if shot.cue_ball_scratched:
		return "cue_ball_scratch_on_break"
	if shot.cue_ball_off_table:
		return "cue_ball_off_table_on_break"
	if not shot.object_balls_off_table.is_empty():
		return "object_ball_off_table_on_break"
	return ""


func _called_ball_is_valid(match_state: EightBallMatch, shot: EightBallShotEvent) -> bool:
	var number := shot.called_ball_number
	if number < 1 or number > 15 or not match_state.remaining_balls.has(number):
		return false
	if shot.called_pocket_id < 0 or shot.called_pocket_id > 5:
		return false
	var group: int = match_state.player_groups[shot.shooter]
	if group == OPEN:
		return number != 8
	if match_state.remaining_group_count(shot.shooter) == 0:
		return number == 8
	return match_state.group_for_ball(number) == group


func _called_ball_was_pocketed(shot: EightBallShotEvent) -> bool:
	return shot.pocketed_numbers.has(shot.called_ball_number) and shot.pocket_ids.has(shot.called_ball_number) and int(shot.pocket_ids[shot.called_ball_number]) == shot.called_pocket_id


func _apply_foul(match_state: EightBallMatch, shot: EightBallShotEvent, outcome: Dictionary, reason: String) -> Dictionary:
	_remove_pocketed(match_state, shot)
	match_state.current_player = 1 - shot.shooter
	match_state.cue_ball_in_hand = true
	outcome["foul"] = true
	outcome["foul_reason"] = reason
	outcome["turn_changed"] = true
	return outcome


func _remove_break_balls(match_state: EightBallMatch, shot: EightBallShotEvent) -> void:
	for number in shot.pocketed_numbers:
		if number != 8:
			match_state.remove_ball(number)
	for number in shot.object_balls_off_table:
		if number != 8:
			match_state.remove_ball(number)


func _remove_pocketed(match_state: EightBallMatch, shot: EightBallShotEvent) -> void:
	for number in shot.pocketed_numbers:
		if number >= 1 and number <= 15:
			match_state.remove_ball(number)
	for number in shot.object_balls_off_table:
		if number >= 1 and number <= 15:
			match_state.remove_ball(number)


func _has_object_ball(numbers: PackedInt32Array) -> bool:
	for number in numbers:
		if number >= 1 and number <= 15:
			return true
	return false


func _outcome() -> Dictionary:
	return {
		"valid": true,
		"foul": false,
		"foul_reason": "",
		"turn_changed": false,
		"game_over": false,
		"winner": -1,
		"decision_required": EightBallMatch.Decision.NONE,
		"group_assigned": OPEN,
		"message": "",
	}


func _invalid(outcome: Dictionary, message: String) -> Dictionary:
	outcome["valid"] = false
	outcome["message"] = message
	return outcome


func _invalid_after_restore(match_state: EightBallMatch, outcome: Dictionary, decision: EightBallMatch.Decision) -> Dictionary:
	match_state.pending_break_decision = decision
	return _invalid(outcome, "That option is not available for this break decision.")
