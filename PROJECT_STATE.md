# Project state

Last updated: 2026-10-27

## Current checkpoint

**M0 — simulation foundation and 3D practice table: in progress.** Godot imports the
project and the main scene runs on the current Apple Silicon macOS host. The practice
table is visible in the desktop build. The headless GDScript suite passes 109
simulation, geometry, rack, and rules assertions; a separate C++17 experiment passes
4,869 native checks.

## Working now

- Deterministic state objects and canonical ball snapshots.
- Fixed-step simulation with adaptive substeps based on travel distance.
- Sliding friction, rolling transition, ball-ball friction/restitution, cushion
  contact with spin, airborne motion, and geometric pocket openings with jaws and
  falling-ball state.
- Isolated WPA-oriented 8-ball match/rules model with called-shot checks, group
  assignment, standard fouls, safety turns, break-choice states, and 8-ball outcomes.
- Momentum-transfer cue strike with center, top/back, side, and conservative elevated
  contact parameters. The model does not initiate a jump shot yet.
- Regulation-style 9-foot table scale, a 16-ball rack, procedural 3D materials,
  pointer aiming, shot speed, tip-position control, and re-rack.
- Offline physics and rules tests that run without the rendered game.
- A pinned, SHA-256-verified Godot 4.7.2 macOS bootstrap installed under the user's
  Applications folder; the repository contains only the bootstrap scripts.
- A standalone, double-precision C++17 core with ball-ball and cushion time-of-impact
  estimates, timestamped events, and a native regression harness. It is not used by
  the playable Godot scene yet.
- A 1,601-sample native cut-angle sweep at 0.0001-radian aim spacing; maximum
  departure-angle error against the analytic equal-mass reference is
  2.89e-15 radians for this clean, center-height case.

## Important gaps

- The current build is a practice table, not a complete 8-ball game. The tested rules
  model is not connected to shot event generation, table UI, or ball-in-hand controls.
- The rules model covers core 8-ball flow and common break choices, but not every WPA
  officiating foul, shot-call correction, stalemate, or match set.
- There is no AI, audio, replay UI, save migration, tutorial, accessibility settings,
  macOS packaging, or mobile input path yet.
- Contact coefficients, table pocket depth/facings, and numerical convergence still
  need source-grounded calibration and empirical validation.
- Native state and event output have not been compared directly with the GDScript
  path; the extension is not integrated or built for any target yet.
- Physical jump-shot initiation and landing interaction have not been implemented.
- No thousands-of-break stress batch, long-run simulation, full performance profile,
  or hardware thermal measurement has been completed. Three GDScript and seven
  native 16-ball break microbenchmark runs are recorded in `PERFORMANCE.md`.
- Android, Linux, and iOS have not been built or tested.

## Next highest-value work

1. Compare native and GDScript canonical states and contact events over named shots,
   then close parity defects before switching runtime paths.
2. Build a thin GDExtension prototype for macOS and check Android, Linux, and iOS
   build feasibility; keep the current GDScript path until verified.
3. Build source-grounded pocket shelf/jaw geometry and validate fall-edge behavior.
4. Connect physical contact, rail, and pocket events to the tested rules model.
5. Add cue-ball-in-hand placement, called-shot selection, score/turn presentation,
   and break-option UI.
6. Validate rail, ball-ball, jaw, pocket, and airborne behavior against published
   reference cases; add convergence and stress harnesses before tuning coefficients.
7. Develop a source-grounded cue/table impact model before exposing jump shots.
8. Add a legal offline opponent and practice/replay tooling after rules events are
   stable.
9. Add restrained, varied contact audio and inspect the visual identity at full-size
   macOS window and Retina scales.

## Evidence ledger

- **Confirmed by this host:** Godot 4.7.2 scene startup; 109 headless assertions;
  desktop practice-table rendering and one simulated shot.
- **Native experiment:** 4,869 standalone C++ checks; a 1,601-point cut-angle sweep
  and ball/cushion time-of-impact event checks pass. Native/GDScript parity is open.
- **Confirmed from Opus's review by permanent tests:** rolling-resistance cancellation,
  slow exponential sidespin decay, narrow derived corner-mouth geometry, and cue
  strike energy above the cue's available energy. Each has a regression test and fix.
- **Current performance observation:** three 4-second GDScript break runs took
  288.4–291.6 ms each in headless editor/debug mode; seven standalone optimized C++
  runs took 3.76–6.19 ms (median 4.25 ms) on the same Apple M4. This is not an
  apples-to-apples runtime or output-parity result. AI cost projections are estimates.
- **Still uncertain:** whether TOI-informed fixed substeps are sufficient, or whether
  event-driven analytic motion is needed for AI throughput and shot accuracy.

## Release blockers

Every item listed in “Important gaps” is still open for the corresponding milestone.
No platform is considered supported merely because Godot can theoretically export
to it.
