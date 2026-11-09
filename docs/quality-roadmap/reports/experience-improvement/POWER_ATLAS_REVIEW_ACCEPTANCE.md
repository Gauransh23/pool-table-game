# Task C scoped fix re-review

Reviewed commit `bec74bf` (`Validate atlas provenance and audit cue angular impulse`), the supplied task-c-fix-review.diff, updated implementation report, reader/audit/tests, and durable round-1 evidence. Scope is the two original P2 findings and newly introduced breakage. No source edits, subagents, tests, routine regressions or physical sweep reruns were performed. This file is the only review output.

**Original finding 1 — missing boundary/controller evidence: ADDRESSED.**

`tools/power_response_atlas.py` now enforces exact record-kind counts; unique identities for all seven unsupported and thirteen controller-boundary records; required runtime engine/build/precision/geometry identity; explicit unsupported finite/nonfinite outcomes; controller rejection/clamp/no-op behavior; and modality-specific result fields. `RESULT_FIELDS` requires all four originally deleted fields. Linked launch results require actual tip readback and correct committed power; declared controller equivalence must be true. Rail jaw fields are mandatory booleans, and first-event references/classifications must agree with their event streams. Missing/malformed evidence is converted to a validation error.

The preserved `review-counterexamples-round1.json` records both exact original mutations as accepted by the original reader and rejected by the corrected reader. `test_review_missing_rows_fields_and_consistency` directly covers those mutations and missing/duplicate probe identities, runtime metadata, commitment, equivalence and rail classifications. The code and retained seven-test output support the correction without reacquiring physical data. No new counterexample requiring a rerun was identified.

**Original finding 2 — missing contact-arm/torque audit: ADDRESSED.**

`tools/power_atlas_torque_audit.py` independently reconstructs the level sphere contact arm from heading and actual tip ratios, computes cue impulse from measured linear velocity change, verifies the existing impulse field, and compares `I*delta_omega` with `r cross J`. This closes the separate geometric/angular impulse invariant; it does not reuse the launch-speed equation or present energy checks as torque checks. The per-row ledger records the arm, measured impulse, both angular-momentum quantities, residual norm, reference scale, bound and status.

The fixed bound `max(1e-11 kg m²/s, 2e-6 * max(norm(I*delta_omega), norm(r cross J), R*norm(J)))` has an explicit float-vector arithmetic rationale and is identified as consistency precision rather than physical calibration. Coverage is 410 retained direct level/resting launches, including 41 zero no-ops; the separate tests include spin-sign, axis, impulse and moving-start counterexamples. The retained ledger reports zero failures, maximum residual 2.2763419344e-9 kg m²/s and maximum bound fraction approximately .03582. CUE-001 remains INCONCLUSIVE overall.

The audit verifies original launch artifact hashes against the COMPLETE acquisition manifest. The unchanged original acquisition manifest/archive are retained; `postprocess-identity-round1.json` binds the updated reader/audit/test hashes and retained chunks separately. The README accurately says the original `--resume --strict` evidence belongs to the original wrapper and that a changed source identity cannot resume it under the updated wrapper.

**Spec verdict for this correction: PASS. Code-quality / evidence-integrity verdict for this correction: PASS.** No actionable newly introduced breakage was found. This closes the original review findings within bounded C0 scope; it does not change the retained red PWR-003/ideal-reference findings or establish catalog-wide, physical, native-device or human acceptance.
