# Frozen power-response atlas C0

This is active-model machine evidence, not calibrated real-table or human acceptance.
The mapping, coefficients, production files, active solver and save semantics are unchanged.
See `task-c-implementation-report.md` for results, limitations and exact validation commands.

Run a new complete atlas from the repository root:

```sh
python3 tools/power_response_atlas.py --output test-results/power-atlas-new
```

Use `--smoke` for a small controller/integrity subset. Exit 0 means a valid completed
measurement; it does not mean product acceptance. `--strict` returns 2 for completed
measurements with requirement FAIL rows; malformed/incomplete harness output returns 1.
A new output path is required. Each engine process has a 120-second watchdog. No old
baseline is overwritten. Completed chunks have fixture/raw/trace hashes; `--resume`
checks sources and fixtures before reusing them. To resume after interruption, retain
and move the incomplete chunk directory aside first; completed chunks can be reused.
A source/schema change requires a new run.

The compressed evidence archive contains the original `manifest.json`, all chunk
fixtures/raw JSONL/full named traces, complete markers, engine logs, small exact replay,
three matched trace overhead pairs, summary and SVG plots. Extract into an empty
folder. Hashes in the manifest cover every original artifact; `SHA256SUMS.json` covers
the distributed files. Raw records precede summary derivation. Manifest status must be
COMPLETE before interpreting threshold results.

Input domains are separate: free/contact fixtures select HUD power; launch-only fixtures
select cue speed directly, with unused result power fields null; ideal rolling fixtures
select initial ball speed. Fixture power placeholders in those latter domains are unused.
All units are explicit. Event positions are numeric `(x,z)` arrays. Event times are
fixed-tick intervals, not root timestamps. `first_ball_contact` and net-after-ball-contact
classification refer to cue-object outcomes; rail events have separate straight/jaw
classification. No-event scouts remain no-event outcomes.

The profile hash identifies every frozen `PhysicsConfig` value. Runtime table values,
ball source identity and each fixture's actual geometry are also recorded; the fixture
hash binds the intentionally oversized no-contact table versus normal contact table.
Sources cover all scripts/scenes/assets and the loaded atlas/serialization helpers.
GDScript scalar floats are 64-bit; this engine's Vector2/Vector3 are 32-bit. Metadata
roundtrip comparison alone permits 2e-15 relative or 1e-15 absolute serialization error.
Product/oracle tolerances are unchanged, and same-build replay compares captured
numeric states/events/regimes exactly without that tolerance.

The independent analytic oracle assumes a level homogeneous solid sphere, Coulomb
sliding with an exactly split transition and constant rolling resistance, without the
active switch/sleep approximation. It reports discrepancies at the original 0.1% bound
(with explicit near-zero absolute floors); these are failures against that ideal, not
proof of real-cloth calibration error. Pure rolling does not need a slide transition;
tiny float-vector residuals and the absence of a crossing are retained as unqualified
transition entries rather than invented exact roots.

To reproduce the original evidence without a new sweep, extract the archives
from the repository root, then run the checker:

```sh
mkdir -p test-results
tar -xzf docs/quality-roadmap/reports/experience-improvement/power-atlas-c0/raw-evidence.tar.gz -C test-results
tar -xzf docs/quality-roadmap/reports/experience-improvement/power-atlas-c0/integrity-smoke-evidence.tar.gz -C test-results
python3 tests/measurement/check_power_atlas.py
```

Extract only into absent/empty named run directories. The smoke archive is the
earlier completed smoke acquisition used for parser corruption tests; it is
historical harness evidence, not the final qualified product atlas.

Round 1 adds fail-closed reader checks and the independent torque audit without
reacquiring the atlas. `postprocess-identity-round1.json` binds these updated tools
to the unchanged original manifest/chunks. The current parser-negative tests use
final-v2 rather than the historical smoke. The exact seven covering tests are
recorded in `round1-covering-tests.json`. The older `--resume --strict` evidence
was produced by the original wrapper; the updated wrapper correctly rejects
resuming it under a changed source identity. Physical calibration remains unproven.
