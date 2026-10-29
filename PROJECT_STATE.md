# Project state

**2026-10-28 quality review: owner rejected 0.2.0.** It does not meet the requested
visual, physics, sound or control bar. See `SOL_TASK.md` and `docs/quality/` for the
new acceptance contract and four reproduced failing tests. Earlier preview-readiness
claims below describe build availability, not owner quality acceptance.


Updated 2026-10-28. Mac practice preview 0.2.0 is built and ready for owner playtesting.

## This checkpoint

The owner prioritized presentation and implemented shot quality over feature count.
The preview is a focused practice room: a regulation-scale table, force and tip control,
accurate clean cut response, rolling/sliding/spin decay, pocket drops, scratch placement,
exact shot undo, auto-resume of settled sessions, contact audio, and two camera views.
It opens with a menu and exports as a universal, locally ad-hoc-signed Mac application.

The playable GDScript core now emits impulse/exit events and uses within-substep
TOI estimates for ball-ball normals. It retains overlap position correction. The
standalone native core remains an experiment and is not loaded by the game.

## Evidence

- 949 physics/rules assertions, including slow/fast half-ball sweeps, 204 cue-energy
  cases, event collection, and bounded settling across twelve representative shots.
- 41 practice-flow assertions: break, settle, exact undo, placement rejection,
  save/load, corrupt data rejection, and cancellation of a stroke during rack reset.
- 4,869 standalone native checks.
- Actual Metal-rendered views reviewed; overhead light obstruction, pocket visual
  clipping, wrong cut guide, floating labels, and protruding jaw meshes corrected.
- Exported app launched on this Apple M4 Mac. Menu, power slider + Space shot,
  ball scattering, Undo, and camera switching exercised in the actual release app.
- Universal binary export, codesign verification, release startup, and DMG creation passed.

## Material gaps

This is a practice preview, not a complete 8-ball match. Match rules remain isolated;
AI, match flow, jump/masse shots, full pocket shelf/jaw calibration, large stress batches,
mobile builds and full accessibility are open. Pocket entry still relies on regions
and gravity drop; it is not a fully validated shelf/liner contact model. Cross-platform
bitwise determinism is not established. The Mac bundle is locally ad-hoc signed, with
no Developer ID notarization. Visual/feel parity with commercial games needs owner
playtesting; it is not established by our narrow analytic tests.

## Next

Get feedback on aiming, lowest/highest stroke power, speed of roll, spin, table readability,
audio, and camera comfort. Then refine the pocket contact model and measured rail
response, establish native integration/parity, and build full match flow.
