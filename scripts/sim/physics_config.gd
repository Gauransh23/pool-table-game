extends RefCounted
class_name PhysicsConfig

# Starting coefficients are calibration inputs, not universal properties of every
# ball, cloth, cushion or table. Presets and validation measurements will refine them.
var fixed_step: float = 1.0 / 480.0
var gravity: float = 9.81
var ball_mass: float = BallState.MASS
var ball_restitution: float = 0.94
var ball_friction: float = 0.055
var cushion_restitution: float = 0.84
var cushion_friction: float = 0.12
var sliding_friction: float = 0.19
var rolling_resistance: float = 0.012
var spin_decay_rate: float = 0.08
var sleep_speed_threshold: float = 0.012
var sleep_spin_threshold: float = 0.08
var max_speed: float = 14.0
var max_substep_travel_fraction: float = 0.45
var max_collision_iterations: int = 6

# A compact, measured-momentum strike model. Cue and tip details remain calibration
# work; these values are exposed so Pure Lab can record the exact inputs.
var cue_mass: float = 0.52
var cue_ball_restitution: float = 0.72
