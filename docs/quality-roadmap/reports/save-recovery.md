# Save recovery

## Change

Version 1 saves remain the on-disk format. Saving validates the state before writing it, writes to a sibling temporary file, then uses the platform rename operation to replace the destination. A write or rename failure does not delete the previous destination. If a stroke is pending or the simulation is moving, save uses the captured pre-stroke `_undo` balls and its matching stroke/pot counters. It never serializes a moving table as a settled snapshot.

Loading parses and validates the entire document into temporary `BallState` objects before changing the active game. It checks exact integer identities, phases, pocket IDs and counters; finite numeric state; supported settled/terminal phase relationships; orientation; on-table bounds and overlap; and reasonable terminal-position bounds. Invalid or truncated saves return `false` without changing table state, score, cue placement, or active stroke state. A restored scratched cue sets ball-in-hand placement.

## Compatibility boundary

- Valid version 1 snapshots with 16 ordered balls, unique numbers 0–15, settled `IN_PLAY` balls, and coherent `POCKETED` or terminal `OFF_TABLE` balls remain supported.
- `IN_PLAY` velocity, vertical velocity, and angular velocity may be at most `0.00001` in stored units to account for serialization noise. Larger values are rejected rather than frozen.
- `AIRBORNE` and `FALLING` are rejected because version 1 stores no simulation clock or resumable contact state.
- An `IN_PLAY` ball may occupy a pocket shelf region while it remains within the table outline. Other non-pocket rail intrusion is rejected. This preserves valid shelf snapshots while preventing ordinary balls from being restored inside rails.
- `POCKETED` requires a pocket ID from 0 through 5 and a terminal height; `OFF_TABLE` requires pocket ID `-1`, terminal height, zero motion and a position outside the table. Cue scratch recovery is supported through either terminal phase.
- Identity and counter values must be mathematically integral; fractional JSON numbers are rejected instead of truncated.

## Verification

`tests/save_recovery.gd` exercises a real scene with a unique `user://` save path. It covers a sixteen-ball v1 round trip, a shelf snapshot, cue scratch recovery, pending and moving stroke saves, moving-state rejection, fractional identities/phases/pockets/counters, duplicate identities, unsupported phases, invalid terminal state, out-of-bounds and overlapping balls, truncated JSON, and nonreplacement of a good save after save-time validation failure. Invalid-load cases compare the live table and counters before and after.

Commands run:

```sh
/Users/codex/Applications/Godot-4.7.2.app/Contents/MacOS/Godot --headless --path . --script tests/save_recovery.gd
```

The focused save-recovery test passed 35 checks. The practice-flow regression passed 42 checks after its in-flight timing adjustment.
