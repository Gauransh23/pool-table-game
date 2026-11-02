# Target specification adjudication — 2026-11-01

**Specification: ready to guide bounded implementation and evidence acquisition. Gameplay acceptance: UNVERIFIED.** The catalog contains 140 requirements across 17 domains. This is a target definition package; no new gameplay tests or runtime changes were implemented by this task.

Two focused reviewers examined the physics and experience criteria. Their original conditional reports are preserved. The final peer recheck was interrupted by workspace-credit exhaustion. The parent applied and checked the concrete corrections below; this does not relabel the peer reports as an independent final PASS.

## Definition fixes

| Concern | Final disposition and location |
|---|---|
| Relative/absolute tolerances, cue energy and recoil | QUALITY_TARGETS comparison rule; F-STRIKE specifies ball energy gain versus `0.5*m_cue*v_cue²` and declared work, recoil/loss accounting and moving-ball domain. F-BALL includes orbital plus intrinsic angular momentum about one fixed origin. |
| Near-zero speed/spin, grazing and finite precision | F-NUMERIC/F-BALL use absolute-vector errors below 0.05 m/s, a normal-speed gate of 0.01 m/s, a <=2 micrometer contact band and explicit tolerance-limited cases. CAL-002/F-CALIBRATE give absolute low-spin uncertainty/residual and sign-indeterminate handling. BAL-004 no longer claims arbitrarily small distinguishable contacts. |
| Convergence and orientation phase | Rational common horizons/integer tick schedules, identical physical initial states, two successive refined differences, fixed-time versus settled outcomes and unwrapped rotation are explicit. |
| Multi-contact truth and penetration | A declared contact law/oracle defines simultaneous outcomes; arbitrary unique impulse decompositions are not universal truth. Pre-resolution penetration, post-resolution residual and settled overlap have separate records including slop. |
| Pocket/metrology ambiguity | Actual 3D solid/free-volume entry path defines legal capture. XZ support alone is diagnostic. World-space transform agreement and image-space continuity use separate methods. |
| Cushion-source extrapolation | RAI-005/F-RAIL preserve the Mathavan normal-velocity/material/domain limitation and require independent evidence outside it. |
| Audio timing and dense contacts | F-AUDIO requires calibrated optical/acoustic/electrical paths for uncertainty <=5 ms. The 100-contact stress audits identity/scheduling; perceptual listening uses plausible breaks. Timbre dimensions, expected loudness/intensity, variants per class, true-peak and mute ramp are operationally distinct. |
| Recognition and cue motion | F-VISUAL/prospective procedure freezes exposures, response timeout, counts, strata and descriptive accuracy versus confidence-bound claims. F-STRIKE audits continuous contact velocity and integrated frame samples separately. |
| Refresh-rate boundary rounding | PER-002/003 and F-PERFORMANCE use exact T formulas; timestamp uncertainty and optional 90/120 Hz profiles are explicit. Rounded table values are illustrative only. |
| Human learning and comparative inference | HUM-005 and the prospective procedure specify matched blocks, success/error/variance estimands, margins, near-zero variance rule and participant-level uncertainty. HUM-004 retains all-axis noninferiority bounds and a fixed recruitment/precision plan. |
| Ordinary domain loophole | CUE-006 requires valid everyday elevated/rail-adjacent coverage for final acceptance. A development-time rejection prevents a false shot but does not itself complete that physical repertoire. |

## Validation performed

- The generator validates unique IDs, complete row fields, gate/level/status values, category/test-family consistency and all 17 protocol-family references.
- `--check` verifies all three readable target pages match the authoritative JSON.
- A temporary all-NOT_RUN ledger was generated with all 140 IDs; evidence overwriting is refused.
- Local Markdown links/anchors, mathematical worked examples, JSON parsing, whitespace and the canonical workflow structure/semantics were checked.
- Runtime source/asset hashes remain unchanged from the verified 0.3.0 candidate. No game tests were run to claim these new targets passed.

## Remaining execution dependencies

Physical reference acquisition, calibrated timing equipment, participants, audible competitor footage, a current playable comparison client and fresh independent numerical review remain requirements for the relevant future claims. Their absence blocks a particular acceptance result, not ordinary implementation or instrumentation work. Keep these as NOT_RUN/BLOCKED in the execution ledger until real evidence exists.

The proposed numbers are product requirements with stated sources/derivations; they are not measured Miniclip coefficients, an achieved-quality score or a statistical proof of superiority. Preserve failing evidence and revise an invalid target through the documented process rather than silently weakening a test.
