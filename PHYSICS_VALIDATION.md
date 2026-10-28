# Physics validation

Last updated: 2026-10-27

## Current evidence

The GDScript headless suite passes 109 assertions for equal-mass head-on momentum
transfer, analytic stun-to-roll speed and displacement, rolling deceleration and
stopping distance, constant sidespin decay, cushion direction/normal/clearance,
frame-chunk invariance, cue speed/energy/squirt/miscue bounds, off-table fall
termination, side-pocket fall state, rack composition and position, and 9-foot table
dimensions. These are regression references; they do not prove full-table realism.
Physical jump-shot initiation and landing remain unimplemented.

The standalone C++17 experiment passes 4,869 checks. A 1,601-point center-height
half-ball cut sweep advances aim in 0.0001-radian steps and compares equal-mass
object-ball departure angles with the analytic collision curve. Maximum measured
error is 2.89e-15 radians. It also checks analytic rolling and stun references,
sidespin decay, cue energy and squirt, rack placement, fixed-step chunking, and exact
ball-ball and ball-cushion contact timestamps. This validates a narrow frictionless
contact case, not GDScript parity, cluster stability, or a measured table.

The current suite also checks that airborne balls clear a cushion above its nose,
off-table balls reach a terminal falling state, and touch-pad top/bottom input maps to
the expected cue-tip side.

The separate rules tests exercise group assignment, called pockets, wrong-first
fouls, ball-in-hand, safeties, break choices, out-of-turn shots, and 8-ball outcomes.
They test the rules module directly and do not validate its integration with
physical events or UI.

## Starting parameters

| Parameter | Starting value | Evidence/status |
|---|---:|---|
| Table playing surface | 2.54 × 1.27 m | WPA recommended 9-foot size |
| Ball diameter | 0.05715 m | WPA equipment specification |
| Ball mass | 0.168 kg | Inside WPA 0.156–0.170 kg range |
| Cushion nose height | 0.03629 m | 63.5% of ball diameter, WPA recommended range |
| Corner pocket mouth | 0.116 m | Inside WPA 0.1143–0.1175 m range |
| Side pocket mouth | 0.129 m | Inside WPA 0.1270–0.130175 m range |
| Fixed simulation interval | 1/480 s | Baseline; convergence not measured |
| Ball restitution | 0.94 | Untuned starting value |
| Ball friction | 0.055 | Untuned starting value |
| Sliding friction | 0.19 | Untuned starting value |
| Rolling resistance | 0.012 | Within the reported 0.005–0.015 pool range; calibration pending |
| Spinning friction | 0.0127 m | Pooltool default scale value; calibration pending |
| Cue collision efficiency | 0.87 | Alciatore TP A.30 typical leather-tip value |
| Cue effective end mass | 0.008 kg | Inside Alciatore's typical 5–15 g range |
| Stable tip offset bound | 0.50 R | Alciatore TP A.30 cites this as a typical miscue boundary |
| Cushion restitution | 0.84 | Untuned starting value; requires rail matrix |
| Cushion friction | 0.12 | Untuned starting value |

The values for mass, geometry, and mouth widths are grounded in the WPA document.
Rolling/spinning defaults and cue parameters are reference starting points, not
calibrated properties of a specific pool table or cue.

## Missing validation before the physics milestone

- Fixed-step convergence at increasing tick/substep quality for rolling, spin,
  collision, rail, pocket, future jump-shot, and break scenarios.
- Rail response matrix across speed, incidence, and spin, compared with the
  Mathavan/Jackson/Parkin cushion model and measured table behavior.
- Ball-ball cut, throw, low-speed, high-speed, cluster, and moving-contact cases.
- Corner and side jaw near-miss, rattle, shelf, and hanging-ball matrix.
- Thousands of seeded breaks with overlap, energy, tunneling, and reproducibility
  checks.
- Long-duration create/simulate/clear and serialization stress.
- Calibration preset ranges instead of a universal coefficient claim.
- Native/GDScript state and event parity on shared named scenarios.
- GDExtension bridge behavior and target builds before any runtime migration.

## Mac practice preview 0.2.0 — 2026-10-28

The playable GDScript path now uses TOI-informed ball-ball normals and emits actual
impulse/exit events. Current suite: 949 assertions. Half-ball sweeps around a true
half-ball contact at 0.2 and 8 m/s, in 0.0001 rad aim increments, are monotonic;
maximum departure errors against the analytic clean equal-mass case are 2.02e-6 and
9e-8 rad. A 204-case cue speed/offset/elevation matrix respects the available cue
kinetic energy. Twelve ordinary center/draw/follow/side shots settle with finite
state within 35 simulated seconds. These are bounded model regressions, not full
calibration, convergence, pocket realism, or cross-platform validation.
