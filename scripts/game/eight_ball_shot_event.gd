extends RefCounted
class_name EightBallShotEvent

var shooter: int = 0
var first_contact_number: int = -1
var pocketed_numbers: PackedInt32Array = PackedInt32Array()
var pocket_ids: Dictionary = {}
var object_balls_off_table: PackedInt32Array = PackedInt32Array()
var cue_ball_scratched: bool = false
var cue_ball_off_table: bool = false
var rail_after_contact: bool = false
var break_balls_to_rail: int = 0
var called_ball_number: int = -1
var called_pocket_id: int = -1
var is_safety: bool = false


func _init(p_shooter: int = 0) -> void:
	shooter = p_shooter


func record_pocket(number: int, pocket_id: int) -> void:
	if not pocketed_numbers.has(number):
		pocketed_numbers.append(number)
	pocket_ids[number] = pocket_id
