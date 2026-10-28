# QA status

Last updated: 2026-10-27

## Verified on this host

- Godot 4.7.2 stable imported the project.
- Main scene completed a 3-frame headless startup without runtime script errors.
- Headless test harness passed 82 assertions across physics, table geometry, rack
  setup, and hand-authored 8-ball rules scenarios.
- A desktop debug run visibly rendered the table, rack, cue, aim guide, and HUD on
  the current Apple Silicon macOS host.

## Not yet verified

- Full match from rack to win/loss.
- End-to-end mapping of physics events into the rules engine.
- Input interaction under varied window sizes, Retina scaling, and trackpad use.
- Save/load, suspend/resume, accessibility, audio, or replay.
- Signed/exported macOS package, offline first launch, or long-duration stability.
- Android, Linux, or iOS runtime or builds.
- Reference physics accuracy, large break stress batch, performance, and thermal
  behavior.
- Physical jump-shot initiation and landing behavior.

## Current defects and risks

- Pointer aiming can target beyond the playing surface for rail shots; the guide
  ends at the first object ball or cushion boundary.
- The practice build cannot recover cue-ball-in-hand after a scratch; re-rack is the
  current recovery action.
- Ball numbers currently use one small top-facing marking; WPA markings need two
  opposite decals and the 6/9 underline.
- Cue elevation is deliberately conservative and does not produce jump shots yet.
- No production audio or final icon is present.
