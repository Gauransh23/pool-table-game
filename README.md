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
- No network requirement, external asset, third-party code library, or analytics
  dependency.

## Run

Install the Godot 4.7.2 stable Standard editor from the [official release
page](https://godotengine.org/download/archive/4.7.2-stable/), then open this folder
or run:

```sh
godot --editor --path .
```

The main scene is `res://scenes/main.tscn`. Move the pointer over the table to aim,
set shot speed and tip position in the HUD, then select **Take Shot** or press
Space. Select **Re-rack** or press R to reset the practice table.

## Headless physics checks

```sh
godot --headless --path . --script res://tests/run.gd
```

The suite covers analytic head-on impact, sliding-to-rolling transition, cushion
rebound, fixed-step frame-chunk determinism, cue spin, pocket fall, jump trajectory,
rack composition, WPA starting dimensions, and hand-authored 8-ball rules scenarios.
These tests do not establish that the current coefficients or pocket model match a
measured table.

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
