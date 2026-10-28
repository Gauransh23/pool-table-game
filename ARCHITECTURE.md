# Architecture

## Current decision

Use Godot 4.7.2 stable Standard as the shared runtime, with a GDScript simulation
module that does not depend on scene nodes. The macOS, Android, Linux, and iOS
presentation layers can share the same game state and simulation API. Keep the
Standard build dependency-free; introduce native code only if profiling demonstrates
that the GDScript core misses a measured budget.

## Boundaries

- `scripts/sim/` owns serializable ball state, table dimensions, cue impulse, and
  fixed-step collision and motion updates. It does not access the renderer or UI.
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

The renderer supplies elapsed time to `PhysicsStepper.advance()`. The stepper
accumulates that time and advances at a fixed 1/480 second interval. Within each
fixed tick it chooses enough collision substeps to keep estimated travel below
0.45 ball radii, then resolves ball-ball and ball-cushion contacts. This is an
initial algorithm and quality setting; convergence measurements must justify any
release choice.

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

The current collision resolver uses fixed ticks plus adaptive substeps and iterative
contact resolution. Continuous collision detection, a more complete cushion impulse
model, full pocket-shelf geometry, cue-tip miscues/squirt calibration, replay format,
and native acceleration remain open decisions. Measure relevant output differences
before replacing the baseline.
