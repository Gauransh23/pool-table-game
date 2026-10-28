extends RefCounted
class_name EightBallMatch

enum Group { OPEN, SOLIDS, STRIPES }
enum Decision { NONE, ILLEGAL_BREAK, FOUL_BREAK, EIGHT_ON_LEGAL_BREAK, EIGHT_ON_FOUL_BREAK }
enum BreakChoice {
	ACCEPT_TABLE,
	TAKE_BALL_IN_HAND,
	RERACK_AND_BREAKER_BREAKS,
	RERACK_AND_OPPONENT_BREAKS,
	SPOT_EIGHT_AND_CONTINUE,
	SPOT_EIGHT_WITH_BALL_IN_HAND,
}

const SCHEMA_VERSION := 1

var current_player: int = 0
var breaker: int = 0
var player_groups: PackedInt32Array = PackedInt32Array([Group.OPEN, Group.OPEN])
var remaining_balls: PackedInt32Array = PackedInt32Array()
var break_pending: bool = true
var cue_ball_in_hand: bool = false
var pending_break_decision: Decision = Decision.NONE
var game_over: bool = false
var winner: int = -1
var rack_number: int = 1


func _init(starting_player: int = 0) -> void:
	reset_rack(starting_player)


func reset_rack(starting_player: int) -> void:
	current_player = posmod(starting_player, 2)
	breaker = current_player
	player_groups = PackedInt32Array([Group.OPEN, Group.OPEN])
	remaining_balls = PackedInt32Array()
	for number in range(1, 16):
		remaining_balls.append(number)
	break_pending = true
	cue_ball_in_hand = false
	pending_break_decision = Decision.NONE
	game_over = false
	winner = -1


func remaining_group_count(player: int) -> int:
	if player < 0 or player > 1 or player_groups[player] == Group.OPEN:
		return 0
	var count := 0
	for number in remaining_balls:
		if group_for_ball(number) == player_groups[player]:
			count += 1
	return count


func group_for_ball(number: int) -> Group:
	if number >= 1 and number <= 7:
		return Group.SOLIDS
	if number >= 9 and number <= 15:
		return Group.STRIPES
	return Group.OPEN


func remove_ball(number: int) -> void:
	var index := remaining_balls.find(number)
	if index >= 0:
		remaining_balls.remove_at(index)


func to_dictionary() -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"current_player": current_player,
		"breaker": breaker,
		"player_groups": player_groups.duplicate(),
		"remaining_balls": remaining_balls.duplicate(),
		"break_pending": break_pending,
		"cue_ball_in_hand": cue_ball_in_hand,
		"pending_break_decision": pending_break_decision,
		"game_over": game_over,
		"winner": winner,
		"rack_number": rack_number,
	}
