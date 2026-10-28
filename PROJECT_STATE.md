# Project state

Last updated: 2026-10-27

## Current checkpoint

**M0 — simulation foundation and 3D practice table: in progress.** Godot imports the
project and the main scene runs on the current Apple Silicon macOS host. The practice
table is visible in the desktop build. The headless suite currently passes 79
simulation, geometry, rack, and rules assertions.

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
- Offline physics tests that run without the rendered game.

## Important gaps

- The current build is a practice table, not a complete 8-ball game. The tested rules
  model is not connected to shot event generation, table UI, or ball-in-hand controls.
- The rules model covers core 8-ball flow and common break choices, but not every WPA
  officiating foul, shot-call correction, stalemate, or match set.
- There is no AI, audio, replay UI, save migration, tutorial, accessibility settings,
  macOS packaging, or mobile input path yet.
- Contact coefficients, cue parameters, table pocket geometry, and numerical
  convergence still need source-grounded calibration and empirical validation.
- Physical jump-shot initiation and landing interaction have not been implemented.
- No break stress batch, long-run simulation, performance profile, or hardware
  thermal measurement has been completed.
- Android, Linux, and iOS have not been built or tested.

## Next highest-value work

1. Connect physical contact, rail, and pocket events to the tested rules model.
2. Add cue-ball-in-hand placement, called-shot selection, score/turn presentation,
   and break-option UI.
3. Validate rail, ball-ball, jaw, pocket, and airborne behavior against published
   reference cases; add convergence and stress harnesses before tuning coefficients.
4. Add a legal offline opponent and practice/replay tooling after rules events are
   stable.
5. Add restrained, varied contact audio and inspect the visual identity at full-size
   macOS window and Retina scales.

## Release blockers

Every item listed in “Important gaps” is still open for the corresponding milestone.
No platform is considered supported merely because Godot can theoretically export
to it.
