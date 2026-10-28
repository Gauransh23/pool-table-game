extends Node3D
class_name GameController

const TableSpec = preload("res://scripts/sim/table_spec.gd")
const PhysicsConfig = preload("res://scripts/sim/physics_config.gd")
const PhysicsStepper = preload("res://scripts/sim/physics_stepper.gd")
const CueStrikeModel = preload("res://scripts/sim/cue_strike_model.gd")
const RackBuilder = preload("res://scripts/game/rack_builder.gd")

@onready var table_view: TablePresentation = $TablePresentation
@onready var hud: GameHUD = $GameHUD

var table: TableSpec = TableSpec.new()
var physics_config: PhysicsConfig = PhysicsConfig.new()
var stepper: PhysicsStepper = PhysicsStepper.new()
var strike_model: CueStrikeModel = CueStrikeModel.new()
var balls: Array[BallState] = []
var aim_direction: Vector2 = Vector2.RIGHT
var power: float = 0.42
var spin: Vector2 = Vector2.ZERO
var _shot_in_motion: bool = false


func _ready() -> void:
	table_view.build(table)
	hud.shoot_requested.connect(_on_shoot_requested)
	hud.rack_requested.connect(_new_rack)
	hud.power_changed.connect(_on_power_changed)
	hud.spin_changed.connect(_on_spin_changed)
	_new_rack()


func _process(delta: float) -> void:
	if _shot_in_motion:
		stepper.advance(balls, minf(delta, 0.12), physics_config, table)
		if not _any_ball_moving():
			_shot_in_motion = false
			hud.set_can_shoot(true)
			hud.set_status("BALLS SETTLED · TAKE THE NEXT SHOT")
		table_view.sync_balls(balls)
		var cue_ball := _cue_ball()
		table_view.set_aim(balls, aim_direction, cue_ball, power, not _shot_in_motion)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and not _shot_in_motion:
		_update_aim((event as InputEventMouseMotion).position)
	elif event is InputEventKey and event.pressed and not event.echo:
		var key_event := event as InputEventKey
		if key_event.keycode == KEY_SPACE:
			_on_shoot_requested(power, spin)
		elif key_event.keycode == KEY_R:
			_new_rack()


func _new_rack() -> void:
	balls = RackBuilder.create_eight_ball_rack(table)
	stepper = PhysicsStepper.new()
	_shot_in_motion = false
	hud.set_can_shoot(true)
	hud.set_status("MOVE TO AIM · SET SPIN · TAKE YOUR TIME")
	table_view.sync_balls(balls)
	table_view.set_aim(balls, aim_direction, _cue_ball(), power, true)


func _update_aim(mouse_position: Vector2) -> void:
	var cue_ball := _cue_ball()
	if cue_ball == null or not cue_ball.is_on_table():
		return
	var target := table_view.project_mouse_to_table(mouse_position, BallState.RADIUS)
	var difference := target - cue_ball.position
	if difference.length_squared() > 0.0004:
		aim_direction = difference.normalized()
	table_view.set_aim(balls, aim_direction, cue_ball, power, true)


func _on_shoot_requested(selected_power: float, selected_spin: Vector2) -> void:
	if _shot_in_motion:
		return
	var cue_ball := _cue_ball()
	if cue_ball == null or not cue_ball.is_on_table():
		return
	power = selected_power
	spin = selected_spin
	var cue_speed := 1.8 + power * 6.2
	var applied := strike_model.apply(cue_ball, aim_direction, cue_speed, spin, 0.0, physics_config)
	if not applied:
		return
	_shot_in_motion = true
	hud.set_can_shoot(false)
	hud.set_status("FOLLOW THE CONTACT · THE TABLE KEEPS THE SCORE")
	table_view.set_aim(balls, aim_direction, cue_ball, power, false)


func _on_power_changed(value: float) -> void:
	power = value
	if not _shot_in_motion:
		table_view.set_aim(balls, aim_direction, _cue_ball(), power, true)


func _on_spin_changed(value: Vector2) -> void:
	spin = value


func _any_ball_moving() -> bool:
	for ball in balls:
		if ball.phase == BallState.Phase.AIRBORNE or ball.phase == BallState.Phase.FALLING:
			return true
		if ball.phase == BallState.Phase.OFF_TABLE and ball.height > BallState.OFF_TABLE_TERMINAL_HEIGHT:
			return true
		if ball.phase == BallState.Phase.IN_PLAY and (ball.velocity.length() > physics_config.sleep_speed_threshold or ball.angular_velocity.length() > physics_config.sleep_spin_threshold):
			return true
	return false


func _cue_ball() -> BallState:
	for ball in balls:
		if ball.number == 0:
			return ball
	return null
