# Baseline evidence — 2026-10-28

Reviewed source: 688dda1, plus previously captured 0.2.0 rendered views and the owner's
explicit rejection of visuals, physics, sound, feel and controls. No fresh commercial
reference session or new listening comparison was performed in this review. Those
remain mandatory tasks in SOL_HANDOFF.md; do not claim measured comparative parity.

Fresh executable probe:

    bash tools/godot.sh --headless --path . --script tests/quality_contract.gd

Exit status 1, intentionally separate from the established regression suite:

| Contract | Current measurement | Required outcome |
|---|---|---|
| PHY-SHELF-01 | Stationary center 27.58mm inside side mouth becomes FALLING | Remain supported |
| CTL-SOFT-01 | Minimum UI center stroke travels 0.3990m | Useful lowest touch <=0.10m |
| CTL-LOCK-01 | Unpressed motion changes RIGHT aim to (-.474816,-.880085) | Retain aim until deliberate gesture |
| LIFE-SAVE-01 | Moving IN_PLAY save loads with simulation disabled | Reject invalid settled save or resume simulation |

The soft-touch and aiming cases are proposed product contracts, deliberately stricter
than current behavior. Shelf support and frozen moving saves are correctness defects.
The test contains no xfails or loosened tolerances. Sol must change behavior and keep
these cases, or document a justified, reviewed replacement contract.

The earlier 949 physics/rules assertions and 41 practice-flow checks cover useful
regressions but missed these failures. Assertion counts do not measure physical
realism, content quality, latency, mix quality, or commercial polish.
