# Architecture

## Current decision

Use Godot 4.7.2 stable Standard as the shared runtime. GDScript remains the playable
simulation path. A standalone C++17 double-precision core now measures about 4.25 ms
for the same four-second break that takes about 290 ms in GDScript. It includes
time-of-impact estimates for ball-ball and cushion contacts, event timestamps, and a
headless test/benchmark harness. It has no Godot binding yet, and output parity has
not been established. The native route remains an experiment until parity, a thin
GDExtension, and target builds are verified.

## Boundaries

- `scripts/sim/` owns the current reference ball state, table dimensions, cue
  impulse, and fixed-step updates. It does not access the renderer or UI. The
  `native/` experiment owns a separate plain-C++ state model and must preserve that
  boundary when a binding is added.
- `scripts/game/` owns rack construction and an isolated WPA-oriented rules/match
  model. Physics will report events without deciding rule consequences.
- `scripts/presentation/` converts simulation state to 3D meshes and camera guides.
- `scripts/ui/` owns control layout and emits player intent through signals.
- `scripts/app/` connects intent to simulation and copies authoritative state to
  presentation.
- `tests/run.gd` exercises the core through Godot headless without loading the main
  scene.

## Rules contract

`EightBallRules.apply_shot()` consumes a completed `EightBallShotEvent` and updates
`EightBallMatch`. It does not modify balls or depend on the renderer. The initial
event model expects the caller to report the first object ball, rail-after-contact,
pocketed numbers and pocket IDs, scratches, off-table balls, safety calls, and the
number of distinct object balls driven to rails on the break. This contract still
needs a production event collector in the simulation/game layer.

## Simulation contract

The renderer supplies elapsed time to `PhysicsStepper.advance()`. The GDScript stepper
accumulates time and advances at a fixed 1/480 second interval. Within each fixed tick
it chooses enough collision substeps to keep estimated travel below 0.45 ball radii,
then resolves ball-ball and ball-cushion contacts after overlap. This is a reference
algorithm, not a validated release choice. The standalone native experiment estimates
time of impact inside each substep for contact normals and event timestamps, but still
uses post-step overlap correction. Neither implementation has full event-driven
advancement or calibrated convergence evidence.

Ball state keeps table-plane position and velocity in `Vector2`, plus height,
vertical velocity, full 3D angular velocity, orientation, and lifecycle phase.
Contact math converts those fields into a 3D sphere state. Randomness is not used by
the simulation core.

## Table basis and scale

The playing surface is 2.54 m by 1.27 m, with X along the long axis, Y vertical,
and Z across the short axis. Ball radius is 0.028575 m and starting mass is 0.168 kg.
Pocket mouths begin at 0.116 m corner and 0.129 m side. Those openings sit within the
WPA recommended ranges; the remaining jaw, shelf, draft, and cushion geometry still
needs empirical validation.

## Deferred implementation

The current GDScript collision resolver uses fixed ticks, adaptive substeps, and
iterative post-overlap correction. The native experiment uses TOI-informed normals
and event timestamps but also applies post-overlap correction. Compare this approach
with full event-driven analytic motion using cut-angle smoothness, break cost, and
event-count measurements. Full pocket-shelf geometry, a complete miscue response,
replay format, and cross-platform native builds remain open.
