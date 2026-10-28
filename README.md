# Long Rail

Long Rail is an offline-first pool game in development, with macOS as the first
platform. The first checkpoint establishes a headless billiards core, an isolated
WPA-oriented 8-ball rules model, and a 3D practice table. Match UI, AI, audio, and
release systems are still being built.

The current build is an engineering alpha. It is not a complete 8-ball match or a
release candidate. Jump shots, rules-to-physics event integration, AI, and audio are
not yet implemented.

## Current build

- Godot 4.7.2 stable, Standard build, using GDScript and Forward+ rendering.
- A procedural 9-foot table, numbered balls, pointer aim, shot-speed control,
  tip-position spin, and a physical cue-strike model.
- A headless simulation module with a fixed 480 Hz step, adaptive collision
  substeps, sliding friction, rolling transition, 3D ball contact, cushion contact,
  airborne motion, and pocket drops.
- A separate WPA-oriented 8-ball rules module for called shots, groups, fouls,
  ball-in-hand, break choices, and win/loss outcomes. It is tested but not yet
  connected to the practice-table UI or physics event stream.
- A standalone C++17 double-precision simulation experiment with ball-ball and
  cushion time-of-impact estimates, timestamped events, and a dense cut-angle sweep.
  It is not connected to the Godot runtime; GDScript remains the playable path.
- No runtime network requirement, external asset, third-party code library, or
  analytics dependency.

## Run

Run the pinned macOS bootstrap to download and verify Godot 4.7.2 Standard into
`~/Applications/Godot-4.7.2.app`, then open the project:

```sh
bash tools/godot.sh --editor --path .
```

The script verifies the official archive's SHA-256 before installing. Set `GODOT` to
an existing editor executable to skip the download.

The main scene is `res://scenes/main.tscn`. Move the pointer over the table to aim,
set shot speed and tip position in the HUD, then select **Take Shot** or press
Space. Select **Re-rack** or press R to reset the practice table.

## Headless physics checks

```sh
bash tools/godot.sh --headless --path . --script res://tests/run.gd
```

The separate 16-ball break microbenchmark runs with:

```sh
bash tools/godot.sh --headless --path . --script res://tests/benchmark_breaks.gd
```

The suite covers analytic head-on impact, stun-to-roll transition, rolling and spin
friction, cushion normals/rebound, fixed-step frame-chunk determinism, cue speed,
energy and squirt, miscue bounds, pocket fall, airborne clearance, rack and WPA
geometry, and hand-authored 8-ball rules scenarios.
These tests do not establish that the current coefficients or pocket model match a
measured table.

The native core has its own checks and 16-ball benchmark:

```sh
bash tools/run_native_tests.sh
bash tools/run_native_tests.sh --benchmark
```

Its 1,601-sample cut-angle sweep checks a center-height equal-mass collision against
an analytic reference at 0.0001-radian aim increments. This is a narrow solver
regression, not evidence that the complete table model is calibrated or that the
standalone core matches the GDScript runtime.

## Project notes

- [Project state](PROJECT_STATE.md)
- [Architecture](ARCHITECTURE.md)
- [Engineering decisions](DECISIONS.md)
- [Physics validation](PHYSICS_VALIDATION.md)
- [Performance record](PERFORMANCE.md)
- [QA status](QA_STATUS.md)
- [Physics and rules research](RESEARCH_NOTES.md)
- [Third-party notices](THIRD_PARTY_NOTICES.md)

No source license has been selected. Public visibility allows people to view the
repository; it does not grant reuse rights.
