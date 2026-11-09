# C0 power-response atlas implementation

Completed source-run measurement against baseline `08199fe096d8814223102cc85d3f856056eb04a5`. Production mapping, coefficients, active `PhysicsStepper`, controller, saved sessions and historical reports are unchanged. The source commit is the scoped commit containing this report; `manifest.json` records the exact loaded source hashes, baseline HEAD and dirty inventory. Lead research/status documents are outside this commit.

**Product findings remain red:** PWR-003 has 21 adjacent-gap violations and three nearest-target misses. Ideal rolling comparisons also fail the original bounds. **Exact slide-transition root accuracy is INCONCLUSIVE:** all six analytic roots lie inside the measured crossing intervals. The runner's six sampled-right-endpoint FAIL rows and CLT-002 FAIL label are preserved, but `qualification.json` is the authoritative interpretation and does not present these as established model/physical timing failures.

## Execution and identity

Final command, exit **0** (valid measurement, not acceptance):

```sh
python3 tools/power_response_atlas.py --output test-results/power-atlas-c0-20261107-final-v2
```

Godot `4.7.2-stable (official)`, build `ed1daf0bf001b61586d9930840f2f1394092c079`, macOS arm64 / Apple M4. GDScript scalar floats are 64-bit; engine vector precision is 32-bit. Frozen mapping: `floor-quadratic-v1`. All PhysicsConfig values, their SHA256 identity, runtime table values, fixture geometry and loaded source path/hash map are retained. Physics is seedless; cosmetic randomness is excluded from physical inputs.

Completed **1,511 fixtures**, **7,673,177 ticks**, **154.495 s** end-to-end. Families: 1,005 free shots (201 powers × five tips), 410 direct cue-speed launches, eight just-outside-tip rejections, 36 rail scouts, 45 object scouts and seven ideal pure-rolling cases. Each family ran in its own process with a 120 s watchdog; no cap/overflow/nonfinite qualified result occurred. Simulation time is accumulated from actual dt; substep counts/root times/contact impulses are unavailable, explicitly null with reasons.

All 201 center inputs use actual HUD assignment/readback, HUD shooting signal, controller and the actual presentation contact closure, with automatic gameplay processing disabled. The committed state is then stepped on the diagnostic table. The tween is manually advanced: this is not display/audio latency evidence. Four signed-spin families have **32 exact controller-linked launch-equivalence probes** at the eight anchors. All supported requested/actual tip offsets and available HUD tip readbacks are retained. Launch-only cue-speed fixtures label their separate domain and leave unused result power fields null.

Rail fixture revision, authorized by lead: x=0 at 90° points into the side pocket. The 90° starts therefore use **x=-0.30 m**, y=.30 m. Every nominal ray was checked against a non-jaw straight segment; heading/incidence conventions and revision rationale are in fixtures. Actual results: **19 straight first-rail events**, **17 no-rail-event scouts**. Low-power misses remain misses. Object scouts have **26 ball contacts** and **19 no-event outcomes**. Across both contact families, 36 have no event and 45 remain horizon-limited. Ball and rail contacts have separate schema fields/classification; event positions are numeric planar arrays. Net follow/draw/stun labels describe the two-second cue displacement after first ball contact and can include later contacts; they do not certify a calibrated repertoire.

## Machine resolution

Center minimum: **21.070394665 mm** at .5%; zero-to-first-step jump is explicit. Full-power unobstructed distance: 238.321853638 m, an oversized diagnostic fixture rather than practical table travel. Center launch speeds and endpoints strictly increase. There are 28 states / 27 adjacent pairs with both endpoints in 20–200 mm; **21 gaps exceed 2 mm**.

| Target mm | Selected % | Actual mm | Signed error mm | Bound mm | Result |
|---:|---:|---:|---:|---:|---|
|50|7|48.142798|-1.857202|2|PASS|
|100|10.5|98.160669|-1.839331|2|PASS|
|200|14|197.363764|-2.636236|2|FAIL|
|500|19|485.033333|-14.966667|5|FAIL|
|1000|23.5|977.789104|-22.210896|10|FAIL|

These are **24 PWR-003 failed comparisons**, not human-selection evidence. PWR-002 remains INCONCLUSIVE for the whole obligation because zero sound was not independently acquired, despite passing minimum/motion/commit observations. PWR-005 human trials remain NOT_RUN.

## Independent expectations and qualification

The analytic oracle derives contact slip `u`, sliding time `2|u|/(7 mu_s g)`, rolling velocity `v-2u/7`, vector sliding displacement, then constant-resistance rolling displacement/time. Assumptions: level homogeneous solid sphere, Coulomb sliding, exactly split transition, constant rolling resistance, no sleep truncation. The active integrator's switch, sampled transition, compound sleep and float-vector accumulation differ. Product comparison thresholds stay at **0.1%**, with declared 1 µm / 1 µs near-zero absolute floors; metadata serialization tolerance does not alter these bounds.

Thirteen worked comparisons (six selected struck shots, seven rolling speeds) retain **six endpoint FAIL**, **ten readiness-versus-ideal-stop-time FAIL**, and **six sampled-transition-right-endpoint FAIL** rows. Of the rolling cases alone, four endpoints (.01/.05/.2/14 m/s) and five stopping-time comparisons (.01/.05/.2/1/14 m/s) fail. These are ideal-reference discrepancies, not proof of miscalibration to real cloth. High-speed long travel also accumulates float32 error. CLT-001 remains FAIL in that scoped comparison.

For all six slide cases, the analytic time lies within the retained 1/480 s crossing interval. A right-endpoint discrepancy cannot establish an exact-root error; **CLT-002 root accuracy is INCONCLUSIVE**, requiring finer acquisition/reference. Intended pure-rolling fixtures have no qualified slide crossing; tiny float-vector residuals are not interpreted as an exact transition. The original raw labels are retained rather than rewritten. There are 22 raw analytic metric failures, not 22 independent physical defects.

Independent energy accounting recomputed translation plus rotation directly from all 410 measured launch states, without copying the strike-speed formula: **410 checks, zero energy-bound failures**. Maximum difference from the instrument's own energy arithmetic is 5.177e-7 J. This does not observe outgoing cue/recoil, validate moving-ball strikes or establish calibrated launch behavior. Direct moving/nonfinite probes are explicitly unsupported behavior; production rejection semantics were not changed. Ordinary 2/5/10° stances, physical calibration, native presentation, real-time frame performance and human repeatability remain unestablished.

## Integrity, regressions and negative evidence

```sh
python3 tests/measurement/check_power_atlas.py
# 6 tests, OK; actual engine fixture rejection, artifact failure, raw mutations,
# retained red product rows, exact source capture and corrected rail schema.

python3 tools/power_response_atlas.py --output test-results/power-atlas-c0-20261107-final-v2-strict-copy --resume --strict
# Exit 2, expected: completed measurements retain product FAIL rows.
# This reused a separate copied archive; no second physical sweep.

python3 docs/quality-roadmap/reports/experience-improvement/power-atlas-c0/energy_audit.py test-results/power-atlas-c0-20261107-final-v2
# Exit 0, 410 independent energy checks.

bash tools/godot.sh --headless --path . --script tests/run.gd
# Exit 0; 950 simulation/rules assertions.
bash tools/godot.sh --headless --path . --script tests/stroke_contact.gd
# Exit 0; 24 checks, zero failures.
bash tools/godot.sh --headless --path . --script tests/spin_precision.gd
# Exit 0; 5 checks, zero failures.
bash tools/godot.sh --headless --path . --script tests/save_recovery.gd
# Exit 0; 39 checks, zero failures.
git diff --check
# Exit 0.
```

Six integrity tests include empty/duplicate/wrong-profile/nonfinite fixture/output rejection; actual GDScript rejects zero direction, moving/overlapping starts and invalid caps before execution; an unwritable missing output directory returns nonzero; missing/duplicate/clock/terminal/trace corruption is rejected. Existing regression outputs use isolated session paths. Historical `stroke_power.gd` CSV output was not rerun/overwritten.

Eight small same-build replays compare captured launch/terminal states, events, regimes, path lengths, rest/readiness metrics exactly, without tolerance. Full traces are streamed for named low-end/transition/contact counterexamples; other sweeps retain compact per-case measurements, every regime change and all drained events. Three matched center-10% trace overhead pairs are 2.083×/2.040×/2.082× (median 2.082×); they measure local observer work, not native frame cost. Some integrity probes ran concurrently with the first completed sweep; throughput is descriptive only. Unsupported direct NaN probes produce expected engine normalization warnings; no qualified nonfinite state or script error was accepted.

Initial invalid run: metadata validation rejected 1–3 ulp Godot JSON double roundtrip differences. It was retained and never qualified. Final fixture metadata comparison permits **2e-15 relative or 1e-15 absolute** serialization error; the GDScript frozen-profile validator uses a 1e-15 absolute serialization allowance. Exact replay and all physical/product bounds are unchanged. A real interrupted run retains an INCOMPLETE manifest, a completed center chunk and partial flushed follow rows, without a summary. Driver/observed child were terminated explicitly; restart guidance preserves incomplete chunks. Neither interruption nor timeout is called settlement.

Lead review found ambiguous rail/contact naming in an earlier complete schema. The failure was reproduced, fields corrected, numeric event positions validated, and final-v2 rerun once with that frozen corrected source. `review-finding-red.txt` preserves the finding. No additional feature work was added after schema freeze. Independent review of this committed packet remains a lead-owned next step.

## Durable packet and changed paths

`raw-evidence.tar.gz` (3,333,426 bytes) retains final-v2 fixtures, JSONL measurements/full named traces, per-chunk completion hashes, engine logs, exact replay, overhead pairs, original summary/manifest and plots. `SHA256SUMS.json` covers distributed files; manifest hashes were verified against every original artifact and loaded source before packaging. `qualification.json` supplies the authoritative scope interpretation without deleting historical labels. Initial-invalid/interruption records, regression logs, integrity output, independent energy audit and red review evidence are retained alongside seven SVG plots. `integrity-smoke-evidence.tar.gz` retains the historical smoke input used for parser-negative tests; README gives extraction/reproduction commands.

Owned implementation paths: `tools/power_response_atlas.py`, `tests/power_response_atlas.gd`, `tests/measurement/power_atlas_fixture.gd`, `tests/measurement/check_power_atlas.py`; all durable artifacts are under this report directory. The separate atlas schema does not broaden package A's 16-ball fixture validator or load its per-tick trace subclass. Only its canonical state serializer/instantiator is reused. No production sources, save/export files or coefficients changed. Cross-platform reproducibility, exact contact impulses/roots, convergence qualification, real equipment and human studies remain open.

## Review correction round 1

Both P2 review findings were addressed without changing the instrument, production physics or original acquisition bytes. The reader now requires exact runtime/result/completion/7-unsupported/13-controller-boundary record counts, unique declared probe identities, runtime engine/precision/geometry fields, modality/domain/readback/commitment fields, declared controller equivalence, and consistent first-rail/jaw classifications. Both exact review deletions were reproduced as accepted by the original reader and rejected by the corrected reader (`review-counterexamples-round1.json`). All retained chunks pass the corrected reader. Seven covering integrity/audit tests pass in 5.305 s, including 52 parser-negative mutations and torque sign/axis/impulse/moving-start counterexamples; no physical sweep or routine regressions were rerun.

The new `tools/power_atlas_torque_audit.py` independently reconstructs the sphere contact arm in world `(x,y,z)` from level heading and recorded actual tip ratios, records measured `J=m*dv`, and compares `I*domega` to `r cross J`. The angular-momentum norm bound was declared before evaluation: max(1e-11 kg m²/s, 2e-6 times max(norm(I*domega), norm(r cross J), R*norm(J))). The relative allowance is approximately 34 float32 unit roundoffs for the short vector/frame/arm/impulse arithmetic chain; the absolute floor handles zero/cancelling torque. It is an arithmetic precision budget, not a calibration tolerance. The complete 410-row matrix (369 positive launches, 41 zero no-ops) has zero torque failures; maximum residual is 2.2763419344e-9 kg m²/s, at most 0.03582 of the fixed bound. The arm/impulse/residual ledger is `torque-audit-round1.json`. Physical calibration remains unproven and CUE-001 overall remains INCONCLUSIVE.

Commands: `python3 tools/power_atlas_torque_audit.py --run test-results/power-atlas-c0-20261107-final-v2 --output docs/quality-roadmap/reports/experience-improvement/power-atlas-c0/torque-audit-round1.json` (exit 0); the exact seven-test command/output is in `round1-covering-tests.json`. `postprocess-identity-round1.json` separately binds the updated reader/audit/test hashes to the original acquisition manifest and every retained chunk. The original manifest still identifies the original acquisition wrapper; its source hash is not relabelled as the updated reader. Original raw archives, product failures, qualification of transition-root uncertainty and all physical/human/native limitations remain unchanged.
