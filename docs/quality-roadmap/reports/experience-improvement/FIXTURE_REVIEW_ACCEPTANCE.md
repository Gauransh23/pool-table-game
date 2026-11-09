# Package A scoped fix re-review

Reviewed range: `4d9143a..08199fe`.

Spec compliance verdict: **PASS for the scoped corrections**.
Code quality verdict: **APPROVE for the scoped corrections**.

All three original findings are **ADDRESSED**. No newly introduced actionable breakage found in the reviewed fixes.

| Original finding | Verdict | Evidence |
| --- | --- | --- |
| P1 Native timeout can certify partial acquisition | ADDRESSED | `run_acquisition.gd:113-131` defaults termination to timeout, checks the deadline before success, records horizon/settled/timeout plus terminal controller/physical state, and fails timeout. `acquire_shot.py:177-202` requires matching final termination metadata, rejects timeout/expired deadline, requires completed horizon or genuine earlier settlement, and validates settlement against the terminal inventory. The original shortened trajectory is retained in the negative suite, along with partial captures that include forged horizon/settled termination records. |
| P2 Missing clocks, impossible event times and invalid inventories pass | ADDRESSED | `acquire_shot.py:28-49,67-108,129-140,173-176` validates finite timestamps and tick/time relationships, event domains, stable unique inventory identities, phase/pocket/orientation semantics, initial/fixture equality, terminal/final-sample equality and replay event-list/trace equality. Original exact mutations are retained. Backwards wall intervals remain reportable rather than silently removed. |
| P2 Invalid overhead durations pass | ADDRESSED | `acquire_shot.py:150-160` requires exactly five pairs, finite positive numeric durations excluding booleans, and finite positive ratios. Python manifest/summary output uses `allow_nan=False`. The negative suite retains NaN/infinity/negative/zero/boolean/string values for both timing fields, extra pairs and ratio overflow. |

Read the supplied fix diff, updated report, original review and task brief, then inspected the current changed modules and relevant active-stepper stop predicate. Inspected the retained negative-suite log: 55 rejected corrupt acquisitions, plus successful preservation/reporting of backwards replay and native-frame clocks. No completed engine, regression or negative suite was rerun; source inspection exposed no new counterexample requiring execution.

Performed read-only artifact identity checks: all three recorded raw SHA256 values match the local files; the three changed code/test source hashes match `round_1_fix.source_hashes`. The retained headless result is PASS with no failures. Native horizon evidence is PASS at 1440 ticks with reason `horizon`, moving=true and settled=false. The extended fixture evidence is PASS at 2193 ticks against a 5000-tick horizon with reason `settled`, moving=false and settled=true. Both are below the 12-second deadline, with no pending stroke. This covers both valid completion branches without incorrectly demanding terminal equality across different horizons. The earlier rejected cross-phase controller-frame comparison is documented and removed; frame-process flags can precede controller processing while termination is observed after post-draw.

The fix range changes only acquisition tooling, its tests and evidence/report files. Gameplay coefficients, targets, active solver, session format and presentation/audio/power code are unchanged. Approval is limited to these original integrity corrections and their direct consequences. It does not establish release performance, display/audio latency, physical fidelity, broader quality acceptance or resolution of the existing numerical threshold misses.
