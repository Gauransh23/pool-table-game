extends RefCounted
class_name RackBuilder

const RACK_PATTERN: Array = [
	[1],
	[9, 2],
	[3, 8, 10],
	[11, 4, 12, 5],
	[6, 13, 7, 14, 15],
]


static func create_eight_ball_rack(table: TableSpec) -> Array[BallState]:
	var balls: Array[BallState] = []
	balls.append(BallState.new(0, 0, Vector2(-0.82, 0.0)))
	var diameter := BallState.RADIUS * 2.0 + 0.00015
	var row_step := diameter * sqrt(3.0) * 0.5
	var foot_x := table.half_size.x * 0.5
	var next_id := 1
	for row in range(RACK_PATTERN.size()):
		var numbers: Array = RACK_PATTERN[row]
		for slot in range(numbers.size()):
			var z_offset := (float(slot) - float(row) * 0.5) * diameter
			var position := Vector2(foot_x + float(row) * row_step, z_offset)
			balls.append(BallState.new(next_id, int(numbers[slot]), position))
			next_id += 1
	return balls
