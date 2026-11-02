# Quality-bar-1 applies

Read [QUALITY_TARGETS](QUALITY_TARGETS.md), [numerical targets](targets/01-physics.md#num--numerical-precision-and-determinism) and [test protocols](TEST_PROTOCOLS.md#f-numeric) before this checkpoint. The historical 0.5 mm / 0.1 degree experiment result below remains evidence against its original threshold. It does not pass the new final numerical bar of 0.10 mm / 0.02 degrees or the production-to-reference budget. Map the promotion to the NUM/BAL/RAI IDs, retain all old failures and add missing coverage. No thresholds were changed in the executable harness by this documentation turn.

# Next checkpoint: S7b — qualify the impact-time prototype

TASK_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/TASK.md
TARGET_WORKTREE=/Users/codex/Documents/My Public Repos/pool-table-game
STATUS=conditional

Read reports/continuation-progress.md, reports/physics-precision.md, tests/experiments/impact_stepper.gd and the original owner request. Preserve the playable0.3.0 candidate and all source changes. Do not switch only GameController to a different engine while leaving tests on the old one.

First verify all current source suites and source hashes. The experimental source passes 950 regression assertions and the90-case/20-short-break matrix. Its full-resolution convergence checker still exits1 on7 coarse comparisons; at 960→1920 the named cases pass. Inspect JSON rows rather than treating exit1 as either a universal failure or a reason to loosen tolerances.

Resolve before any promotion:

- Replace the prototype's0.1nm positional nudge (below Vector2 float32 resolution at ordinary coordinates) with explicit, justified distance/contact tolerance. Use approach velocity to reject separating pairs. Provide exact-touch, grazing and micrometer-gap counterexamples.
- Preserve post-integration rail/slate ordering until a separately supported coupled model replaces it. The first prototype incorrectly solved rails before integration and failed the existing downward rail-reaction fixture; a corrected ball-only pre-solve passes it. Do not erase that distinction.
- Record event-budget exhaustion for dense racks/frozen chains; bounded fallback must not become silent quality loss. Test time-shifted impacts, reversed ball storage, energy including rotation and repeatability across render chunks.
- Measure the same local CPU scenarios and exported frame pacing. Do not promote a higher-quality solver whose stalls violate the frozen target without a deliberate architecture decision.
- Obtain fresh independent review when workers are available. If unavailable, record the independence limit and keep promotion conditional.

Use the single PhysicsStepper runtime as the eventual source of truth. If accepted, move the proven implementation into it and rerun all tests against that active implementation, including1000 seeded breaks before milestone signoff. Preserve original/experimental measurements and a rollback snapshot. Leave coefficients unchanged during the numerical change.

Report PASS/CONDITIONAL/BLOCKED with exact files, command outputs, worst errors, unsupported regimes and the next discriminating probe. Do not self-certify real-table or commercial quality from this checkpoint.
