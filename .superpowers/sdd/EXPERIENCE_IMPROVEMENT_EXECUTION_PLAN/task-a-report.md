# Package A measurement foundation checkpoint

Status: implemented and verified for the bounded acquisition/replay scope. Baseline source `98287008b8d5286d78a4e0e6bb68d56b3f5b7d5e`. No gameplay source, coefficients, power model, presentation/audio models, save format, exports or targets changed. No solver promotion. No push.

## Changed paths and design

- `tests/fixtures/three_ball_v1.json`: versioned full 16-ball canonical settled snapshot; cue and two object balls visible; 13 explicitly pocketed. Declares units, active-default profile, deterministic seedless physics, scripted stroke, horizon and required contact kind.
- `tests/measurement/shot_fixture.gd`: single fixture validator/loader; finite full states, identity, orientation, supported profile/input/units/horizon, settled/nonoverlapping starts. This first schema deliberately excludes moving starts and custom profiles.
- `tests/measurement/trace_stepper.gd`: bounded 30000-record opt-in subclass of the active `PhysicsStepper`; overrides call `super` and retain events/state without altering coefficients or advancement. No production/controller hook exists. Default gameplay never constructs/loads it.
- `tests/measurement/run_acquisition.gd`: exact fixed-tick replay, identical per-tick sampled replay and terminal/events, global cosmetic-RNG perturbation, plain-versus-observed comparison, five paired CPU overhead trials, native controller shot and post-draw screenshot/frame timestamps. Native uses a unique temporary session path and removes it.
- `tools/acquire_shot.py`: timeout and output-integrity wrapper; captures commit/dirty source hashes including loaded source/assets, fixture hash, engine/OS/device, active engine, config/table values, raw hash, separate summary and log; new output directories prevent overwriting qualified baselines. Empty/malformed/failed acquisition cannot create a PASS summary.
- `tests/measurement/check_negative.py`: corrupts a real result and checks rejection.
- `tests/measurement/baseline-evidence.json`: tracked compact manifest, full affected-source hashes, measured config, timings, screenshot/raw hashes, negative process results and regression totals. The complete manifest/raw records remain at the local paths it names. This report is force-added because `.superpowers` is ignored.

## Exact reproduction and results

Commands run from repository root:

```
python3 tools/acquire_shot.py --output test-results/acquisition-headless-v3
python3 tools/acquire_shot.py --native --output test-results/acquisition-native-final
python3 tests/measurement/check_negative.py test-results/acquisition-native-final/raw.json
bash tools/godot.sh --headless --path . --script tests/run.gd
bash tools/godot.sh --headless --path . --script tests/stroke_contact.gd
bash tools/godot.sh --headless --path . --script tests/save_recovery.gd
bash tools/godot.sh --headless --path . --script tests/physics_precision.gd
```

- Final native acquisition: exit 0, 1440 fixed replay ticks, two ball contacts. Identical full sampled trajectories on two observed replays; terminal state/events also equal uninstrumented replay and a replay after 1000 global random draws. No simulation RNG currently exists; seed zero documents that fact, without introducing a gameplay RNG or relying on global cosmetic state.
- Native: real source window/controller/cue animation/active solver; 1600x900 framebuffer, forward_plus, Apple M4/macOS, screen scale 2, reported display refresh 120 Hz while controller caps at 60 FPS. Screenshot manually inspected: three visible balls, 36% power, 13/15 pocketed counter, complete table/HUD. Source-run evidence is not an exported release or human-perception acceptance.
- Native trace advanced **1443 ticks** because the controller advances complete render-frame delta. Fixed replay is 1440 ticks. Native terminal state is therefore explicitly **not compared** to the fixed replay terminal state; different horizons are not replay drift. Raw native states retain every tick, so equal horizons can be selected later.
- 182 native process-frame samples: wall interval median 16.662 ms, p95 17.234 ms, worst 17.639 ms. Post-draw median 16.701 ms, p95 17.633 ms, worst 18.979 ms. Zero nonpositive or >50 ms intervals in this short capture. No exclusions, smoothing or outlier deletion. These are CPU observer timestamps, not OS present/display timestamps.
- Five paired full replay timings: median plain 66453 us, traced 82821 us; median paired ratio 1.244934 (~24.5% extra CPU acquisition work). Acquisition overhead is material and is reported, not claimed negligible. It does not exist in normal gameplay. These short sequential CPU timings are descriptive, not calibrated performance acceptance; no rendered on/off performance-equivalence claim.
- Fixture runner rejects 10 malformed fixture mutations including nonfinite horizon. Corrupt-result checker rejects **19** real-result mutations including empty acquisition, missing/wrong nested types, nonfinite/string ticks, missing events, malformed/nonfinite terminal/sample inventories, empty native data and missing frame stamps.
- Existing regressions: 950 simulation/rules assertions pass; stroke contact 24 checks/0 failures; save recovery 39 checks/0 failures. Raw regression logs are in `test-results/measurement-regressions/`.
- Existing precision probe: 48 runs, six pocket probes, **20 measured threshold misses**; exit 0 is the existing probe behavior, not numerical acceptance. Generated tracked `runs.csv/json` were copied into `test-results/measurement-regressions/physics-runs.csv/json`, then restored byte-for-byte from HEAD. No baseline result was retained overwritten.

Negative executable probes (exact commands/environment recorded in tracked baseline evidence and local `test-results/measurement-regressions/negative-process.json`):

```
python3 tools/acquire_shot.py --fixture <repo>/test-results/measurement-regressions/invalid.json --output test-results/acquisition-invalid-v2
bash tools/godot.sh --headless --path . --script tests/measurement/run_acquisition.gd -- --output=/dev/null/raw.json
GODOT=<repo>/test-results/measurement-regressions/broken-godot.sh python3 tools/acquire_shot.py --output test-results/acquisition-broken-v1
```

All three exit 1. `invalid.json` contains `[]`. The temporary broken-engine shim invokes the real fetched engine with `--headless --path <repo> --script tests/measurement/nonexistent.gd`. Godot itself exits **0** for this missing script, a retained counterexample; the wrapper detects absent raw acquisition and writes explicit FAIL/exit 1. The shim and logs are local evidence, not product dependencies.

## Evidence ledger and limits

| Requirement | Scope and result |
| --- | --- |
| EVD-001 | PASS for this source acquisition's commit/dirty-source/config/fixture/runtime identity. Full shipped compiler/device/render baseline remains unestablished. Engine build identifies standard Godot 4.7.2; its compiler configuration is not independently inspected. |
| EVD-005 | PASS for bounded fixture/result integrity, timeout/output checks and exercised invalid/empty/broken-script/unwritable counterexamples. |
| EVD-007 | PASS for this single fixture: raw events/states, counts, overhead pairs, native wall interval distribution/worst cases retained. No broader corpus claim. |
| LIF-003 | NOT_RUN as a new undo equivalence acceptance test; replay foundation can support it. Existing save/stroke regressions only retain their documented scope. |
| PER-001/002/003 | INCONCLUSIVE for release performance: short source capture, uncontrolled thermal/power/cache state, no OS present timestamps/uncertainty, no 60-second/repeat release run. |
| AIM-010 / AUD timing / physical calibration / human gates | NOT_RUN: scripted request and cue-contact observation do not establish OS input, actual display or audible latency. |

Simulation event times use `event.tick * fixed_step`: 2.083333 ms tick resolution, **not exact impact roots**. Delivery wall time is when drained events reach the acquisition observer. Cue contact is first observed frame after the actual controller commitment, not an exact physical/device timestamp. Frame process and frame post-draw clocks are separate records. Missing expected event kinds fail; discontinuous frame intervals remain in raw data and summary arrays. No clock calibration/U95 claim exists.

The fixture's physical oracle is deliberately only acquisition invariants/event existence, not independent real-pool fidelity. Native time-varying frame scheduling is not compared against the exact fixed replay horizon. Event payloads preserve what the active stepper emits; missing contact positions/impulses/substep root timing remain absent. No baseline numerical misses or thresholds were changed.

Final raw identity: SHA256 `22e126f718216c7b7dcd50220610f812b84d495d00c2486d5856eb2b04f7164a` at `test-results/acquisition-native-final/raw.json`. Raw and full manifest/image are local ignored artifacts; tracked `tests/measurement/baseline-evidence.json` preserves summary/identity across checkouts. Reproduce with a fresh output directory to regenerate raw evidence.
