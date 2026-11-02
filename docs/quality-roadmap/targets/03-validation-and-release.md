# Validation and release targets

Generated from `../QUALITY_REQUIREMENTS.json`, revision **quality-bar-1**. Edit that catalog and run `python3 docs/quality-roadmap/tools/render_targets.py` from the repository root.

Read [contract and definitions](../QUALITY_TARGETS.md) before interpreting thresholds. All rows start **UNVERIFIED**. A separate evidence ledger establishes execution status; this page makes no gameplay acceptance claim.

## EVD — Evidence and truthful completion

Owner surface: Lead / verification owner. Test family: [F-EVIDENCE](../TEST_PROTOCOLS.md#f-evidence). Primary gate: **G0**.

### EVD-001 — Reproducible identity

**Target (required; product):** Every result names commit plus dirty-source hashes, active engine, profile, seed, units, engine/OS/device, render and input settings. A result for an experimental or native engine cannot certify gameplay.

**Test/evidence:** Attach a manifest and demonstrate which stepper GameController instantiates in the tested artifact.

**Counterexample to catch:** Green native tests while the exported app runs different GDScript.

### EVD-002 — Requirement evidence ledger

**Target (required; product):** Every required ID has PASS, FAIL, NOT_RUN, BLOCKED or INCONCLUSIVE in the execution ledger. Attempted claims link raw artifacts; blocked rows name the missing prerequisite. Passing requires expected/actual results, oracle identity and uncertainty. Catalog UNVERIFIED is not a passed execution status.

**Test/evidence:** Check the complete catalog against the final ledger; no missing IDs.

**Counterexample to catch:** A report contains only a total assertion count.

### EVD-003 — Independent oracle

**Target (required; product):** Each numerical claim uses an independently derived analytic result, sourced experiment or separately validated implementation with documented assumptions. Differential agreement alone is insufficient.

**Test/evidence:** For each family name a plausible wrong implementation and show a discriminator.

**Counterexample to catch:** Two engines share the same erroneous formula and agree.

### EVD-004 — Reference provenance

**Target (required; product):** Competitor claims name build/platform/mode/cue/table and timecodes; unknown fields remain unknown. Edited GIF timing supplies no latency, friction or speed coefficient.

**Test/evidence:** Audit each statement against the actual clip/interaction and source ledger.

**Counterexample to catch:** Treat a HUD timer reset as continuous physical time.

### EVD-005 — Executable evidence integrity

**Target (required; product):** Acceptance checks exit nonzero for failed assertions, script/parse errors, capture failure and invalid output. Harness timeout is a failure to establish the target.

**Test/evidence:** Inject one bad result, broken dependency and unwritable output path.

**Counterexample to catch:** Godot exits zero after a script parse error.

### EVD-006 — Threshold integrity

**Target (required; product):** Use this revision unchanged for a run. A revision records old/new value, reason, source, impact, reviewer and retained failing evidence before a new acceptance run.

**Test/evidence:** Review contract revisions and compare old/new fixtures.

**Counterexample to catch:** Delete an outlier seed or increase tolerance until green.

### EVD-007 — Worst-case reporting

**Target (required; product):** Publish each family and profile separately, sample counts, worst case, median and p95 where defined; distributions never replace exact safety invariants.

**Test/evidence:** Recompute summaries from raw records.

**Counterexample to catch:** Average easy rolls with failing grazing contacts.

### EVD-008 — No hidden assistance

**Target (required; product):** Any aim/shot assistance is an explicit selectable mode and recorded in fixtures; deterministic physical results do not change to favor a pot.

**Test/evidence:** Replay identical physical inputs with guide/UI toggles and compare states.

**Counterexample to catch:** Secretly steer the cue ball to the drawn guide.

## CAL — Calibration and source discipline

Owner surface: Physics research / data acquisition / validation reviewer. Test family: [F-CALIBRATE](../TEST_PROTOCOLS.md#f-calibrate). Primary gate: **G2**.

### CAL-001 — Measured reference set

**Target (required; product):** Acquire identifiable table/ball/cue shots with full initial state estimates, scale/time calibration, repeated trials and 95% measurement uncertainty. Preserve raw footage and tracking data.

**Test/evidence:** Acquisition protocol and independently retracked subset; source/license/access recorded.

**Counterexample to catch:** Fit an unknown YouTube highlight with hidden cue stats.

### CAL-002 — Instrument adequacy

**Target (required; product):** For fine measured-trajectory gates, expanded uncertainty U95<=1 mm position,0.1 degrees direction, 1% speed and 1 ms time. Spin U95<=5% when |omega|>=1 rad/s and<=0.02 rad/s below it. Use suitable instrument/oracle per gate; inadequate uncertainty leaves the claim unestablished.

**Test/evidence:** Calibration target, clock/rolling-shutter checks, occlusion error and uncertainty propagation.

**Counterexample to catch:** Set test tolerance equal to an imprecise tracker error without labeling it.

### CAL-003 — Held-out trajectories

**Target (required; product):** Per named smooth/isolated family: trajectory RMS error<=2 mm,95 th point error<=5 mm; endpoint median<=3 mm and p95<=8 mm on the measured reference profile. Report time-aligned and path-shape errors separately.

**Test/evidence:** Fit only training families; compare held-out speeds/angles/offset combinations and repeated natural variability.

**Counterexample to catch:** Optimize endpoint while trajectory timing or intermediate path remains wrong.

### CAL-004 — Velocity, spin and direction

**Target (required; product):** Launch and isolated post-impact speed error median<=2%, p95<=5%; angular-speed error median<=5%, p95<=10%; direction median<=0.15 degrees, p95<=0.5 degrees, outside near-zero ambiguity.

**Test/evidence:** Track marked balls with uncertainty; use absolute low-speed bounds in TEST_PROTOCOLS.

**Counterexample to catch:** Infer angular velocity solely from the number patch in a blurry GIF.

### CAL-005 — Training and holdout separation

**Target (required; product):** Hold out >=30% of shot families, including entire speed/angle cells, before fitting. No parameter retuning on holdout; retain residuals by regime and profile.

**Test/evidence:** Version split manifest and evaluate untouched holdout once per candidate fit.

**Counterexample to catch:** Randomly split near-identical frames of one shot and call it generalization.

### CAL-006 — Identifiability and sensitivity

**Target (required; product):** Fit cloth/strike/ball/rail/pocket stages separately where identifiable. Report confidence/covariance, parameter sensitivity and plausible alternatives.

**Test/evidence:** Perturb coefficients and initial-state uncertainty; test alternative model predictions.

**Counterexample to catch:** One spectacular break determines all friction and restitution values.

### CAL-007 — Operating domain

**Target (required; product):** Published validity limits accompany each model and profile. Everyday strokes are validated; unsupported advanced shots are explicitly unavailable until their conditional requirements pass.

**Test/evidence:** Domain map across speed/elevation/spin/material, with boundary and beyond-boundary tests.

**Counterexample to catch:** Clamp unsupported elevation to another value and present it as the selected stroke.

### CAL-008 — Independent reproduction

**Target (required; product):** A second reviewer reproduces the key fits/plots from raw data and verifies units, source assumptions and held-out statistics before calibration signoff.

**Test/evidence:** Fresh analysis packet with original requirement, data, code and outputs.

**Counterexample to catch:** A reviewer only reads the implementer’s summary.

## LIF — Recovery and sustained play

Owner surface: GameController / session model / lifecycle verification. Test family: [F-LIFECYCLE](../TEST_PROTOCOLS.md#f-lifecycle). Primary gate: **G0**.

### LIF-001 — Atomic settled recovery

**Target (required; product):** Valid versioned settled snapshots restore all physical fields, identities, profile and relevant counters. Unsupported/moving/malformed states are rejected without changing the live game or replacing the last good save.

**Test/evidence:** Round-trip, truncated writes, rename failure, wrong versions/types and moving/spinning snapshots.

**Counterexample to catch:** A moving IN_PLAY save loads with simulation disabled.

### LIF-002 — Pending snapshot coherence

**Target (required; product):** A save during delivery/motion uses one coherent restorable checkpoint and its matching counters/profile. Cancellation and restart cannot combine pre-shot balls with post-shot scoring.

**Test/evidence:** Save at each delivery/contact/pot phase; restore in a fresh process.

**Counterexample to catch:** Undo state is saved with current stroke count.

### LIF-003 — Undo physical equivalence

**Target (required; product):** Undo restores the entire pre-shot physical state and semantic counters exactly on one build, including orientation, pocket lifecycle and future deterministic replay.

**Test/evidence:** Repeat identical shot after undo and compare all ticks/events; include scratch and simultaneous captures.

**Counterexample to catch:** Restore positions but retain velocity or capture-suppression state.

### LIF-004 — Lifecycle resource stability

**Target (required; product):** After warmup,10000 headless lifecycle cycles and a 2-hour interactive soak show no monotonically growing live object count; retained memory growth<=5% after a reproducible idle plateau. No unexplained engine/resource errors.

**Test/evidence:** Time-series RSS/object/resource counts, with allocator/cache behavior separated from leaks.

**Counterexample to catch:** An aim-test teardown warning is dismissed solely because assertions passed.

### LIF-005 — Interruption safety

**Target (required; product):** Focus, pause, close, crash-restart and reset around any event leave one valid checkpoint, no late impulse and no duplicate sounds/scores.

**Test/evidence:** Boundary-timed interruption corpus and packaged restart tests.

**Counterexample to catch:** A generation counter cancels physics but a tween/audio callback remains live.

### LIF-006 — Inventory and progress

**Target (required; product):** All 16 balls retain unique stable identity; progress and pocketed state agree after every shot/undo/restore. Scratch and off-table recovery remain usable without a menu dead end.

**Test/evidence:** Full clear, repeated scratches, multiple pots and save/reload cycles.

**Counterexample to catch:** A hidden lost ball prevents the table from ever settling.

## PER — Performance and shipped artifact

Owner surface: Performance / renderer / export owner. Test family: [F-PERFORMANCE](../TEST_PROTOCOLS.md#f-performance). Primary gate: **G4**.

### PER-001 — Declared baseline

**Target (required; product):** Record hardware/OS, renderer, release build, actual framebuffer, OS scaling, refresh, power/thermal state and startup cache state. Required baseline: Apple M4/macOS Metal,1600 x 900 and 1920 x 1080 framebuffer at 60 Hz; supported Retina modes must be profiled separately.

**Test/evidence:** Manifest plus actual exported process capture; no inference from window size alone.

**Counterexample to catch:** A1100 x 618 texture inside a 1100 x 700 window is reported as full 700 px native UI.

### PER-002 — Frame-work headroom

**Target (required; product):** For a supported refresh period T=1000/refresh_hz ms, critical-path work p95<=min(12 ms,0.72*T), p99<=T over 60s each idle/play/break after declared warmup, with 3 repeats including sustained warmth. Record stages without double-counting CPU/GPU overlap.

**Test/evidence:** Release frame traces and stage attribution; repeat on a thermally warm session.

**Counterexample to catch:** Headless average simulation throughput is presented as rendered p99.

### PER-003 — Presentation cadence

**Target (required; product):** At supported nominal period T=1000/refresh_hz ms, presentation interval p95<=T+0.5 ms, p99<=1.5*T; intervals>2*T are<0.1% outside frozen loading exclusions. Timestamp U95<=0.1 ms; use exact formulas and conservative uncertainty treatment, not rounded display decimals. Higher-refresh support requires its own measured profile.

**Test/evidence:** OS/present timestamps; report distribution, worst hitch and exclusions.

**Counterexample to catch:** Fixed-FPS movie export is used as proof of real-time smoothness.

### PER-004 — Overload semantics

**Target (required; product):** Event/catch-up work is bounded and measured; overload does not silently drop physical time or change a shot. Unsupported sustained load has an explicit visible/recoverable policy.

**Test/evidence:** Injected 50/100/500 ms stalls and stress scenes; compare equal simulation ticks.

**Counterexample to catch:** Clamp delta and discard elapsed time while claiming deterministic real time.

### PER-005 — Resource budgets

**Target (required; product):** Freeze per-profile CPU/GPU memory, mesh/texture/audio/voice budgets after a measured vertical slice; no unexplained >5% regression per checkpoint. Lifecycle stability still applies.

**Test/evidence:** Before/after traces with identical corpus and reported absolute values.

**Counterexample to catch:** Claim optimization from a different scene, device or cache state.

### PER-006 — Packaged interaction

**Target (required; product):** Exported installed artifact must complete delicate touch, straight pot, thin cut, rail response, break, scratch, undo, pause and save-resume without script/resource errors. Signature/build success alone is insufficient.

**Test/evidence:** Run those tasks from installed/packaged app, retain video/logs and artifact hash.

**Counterexample to catch:** Source tests pass but the release cannot load fonts, or an external-script probe hangs.

### PER-007 — Artifact provenance

**Target (required; product):** Every reviewed build identifies source/profile/test hashes and exclusion rules. Experimental engines, raw research media and temporary reports cannot silently become gameplay dependencies.

**Test/evidence:** Inspect package contents and confirm active engine in the installed candidate.

**Counterexample to catch:** A research prototype is shipped accidentally because all resources are exported.

## HUM — Experienced quality and comparison

Owner surface: Owner / pool players / independent perception reviewer. Test family: [F-PERCEPTION](../TEST_PROTOCOLS.md#f-perception). Primary gate: **G4**.

### HUM-001 — Formative pilot

**Target (required; product):** Use at least 8 people with novice/experienced representation, randomized task order and declared familiarization. Record mistakes and disagreements per axis before selecting control/art alternatives.

**Test/evidence:** Aim,50–1000 mm placement, draw/follow, bank, pocket edge and break tasks.

**Counterexample to catch:** One implementer approves their own screenshot.

### HUM-002 — Final panel

**Target (required; product):** Final comparative study has at least 20 independent participants, at least 10 experienced and 10 novices, repeated tasks and counterbalanced order. This is a sampling floor, not power proof; pre-register participant-level paired estimator/CI, exclusions and recruitment/precision plan.

**Test/evidence:** Pre-register protocol/margins, collect consented anonymous task data and paired ratings.

**Counterexample to catch:** Treat an 8-person exploratory preference as population-wide superiority.

### HUM-003 — Independent axis bar

**Target (required; product):** For clarity, precision, physical plausibility, responsiveness, visual finish and sound naturalness: median>=4/5 and >=80% ratings 4–5 in EACH axis; no unresolved reproducible severe defect. Owner accepts the concrete candidate.

**Test/evidence:** Anchored scale and issue review per axis; expertise strata reported separately.

**Counterexample to catch:** A high visual score averages away unreliable cushions.

### HUM-004 — Reference comparison

**Target (required; product):** Compare an identified current Miniclip build and another legitimate reference on matched tasks. Proposed noninferiority margin 0.5/5 per axis: participant-level paired 95% lower bound for candidate-minus-reference must exceed -0.5 on EVERY required axis; inconclusive evidence remains inconclusive.

**Test/evidence:** Legitimate continuous recordings and actual tasks; preserve version/cue stats/mode and reference access limits.

**Counterexample to catch:** Use edited promotional GIFs as a full comparative benchmark.

### HUM-005 — Predictability and learning

**Target (required; product):** For preregistered matched learning blocks B1/B2, participant-level success change has paired95% lower bound>=-5 percentage points; normalized landing-error median degradation has upper bound<=0.01, and variance-ratio B2/B1 upper bound<=1.25 for nondegenerate B1. Report strata/families; unexplained spin/rail sign mismatches independently block.

**Test/evidence:** Use the fixed task, success windows, familiarization, timing, retry/timeout and degenerate-variance rules in F-PERCEPTION. Compare participants as independent units; use frozen recruitment and CI methods.

**Counterexample to catch:** Players learn around inconsistent physics without understanding it.

### HUM-006 — Motion and listening signoff

**Target (required; product):** Review full-speed and slow-motion clips, built-in speakers and wired headphones, normal/minimum/Retina views. Every unresolved material/perception finding has a named disposition and evidence.

**Test/evidence:** Separate fresh visual and listening reviews, plus owner playtest of the actual artifact.

**Counterexample to catch:** A waveform, still frame or build success substitutes for experienced quality.
