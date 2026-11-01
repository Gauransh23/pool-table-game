# Continuation checkpoint — 2026-10-31

Status: gameplay candidate, full excellence acceptance remains open. This is a continuation of Astra's roadmap, not a replacement for it.

## Implemented in the playable engine

- Soft-touch mapping: zero is selectable/non-firing; minimum .5% gives 0.021070395m on the unchanged cloth model. Full cue speed remains8m/s. Thirty-nine measured settings are strictly increasing; readout retains half-percent precision.
- Cue delivery: frozen aim/power/tip inputs feed an animated contact callback. The visible tip touches the selected ball surface; impulse and cue sound are triggered there. Contact remains visible across a render. Menu, reset and focus loss cancel pending delivery; camera changes cannot move a pending stroke.
- Guide honesty: preview uses the strike model's launch deflection and finite rail/slate boundaries. The unsupported outgoing-object ray was removed; the UI names the limited initial-path promise.
- Tip control: Shift-drag uses one-fifth pointer gain without jumping to the pointer on press; double-click centers the tip. A reachable-region ring explains the .5R bound. Gain remains a product default pending user trials.
- Recovery: settled-only v1 snapshots, physical/identity/counter validation, failure nonmutation and consistent pre-shot state/counters while pending. No frozen moving saves. Valid settled saves and scratches round-trip.
- Shared pocket geometry: finite jaws, sourced-range shelf presets and one supported slate outline generate both contact boundaries and visible cutouts. Gravity begins on support loss; partial descent retains contact response. Scoring follows descent below the slate inside the actual unsupported pocket volume.
- Fast rejection: a real matrix counterexample showed balls returning beneath the bed and scoring. A slate edge/top-face reaction and capture-domain check repair that path. A damped lining response contains descending balls; its .2 restitution is provisional, not calibrated.
- Presentation: actual pocket wells and cushion cross-sections, readable rendered number artwork that starts facing overhead, mipmaps, filtered cloth weave and a static reflection environment. These improve the foundation; the table still needs a full art and perception pass.

## Evidence and its limits

The main regression suite passes 950 assertions. Focused source suites cover aiming,39-setting power sweep,24 cue-contact checks,39 save checks,154 geometry assertions,49 pocket support checks and157 render-geometry assertions. The original four quality targets now pass. Focused spin adjustment adds5 checks.

The final 90-entry matrix across six pockets and five speeds, plus20 short seeded breaks and 3 exact replays, passes with no scoring-under-supported-slate, duplicate pocket events or nonfinite states. Worst measured break overlap is0.334mm and max translational+rotational energy ratio1.0. This is a bounded scout, not the1000/10000-break or complete calibrated rattle gate.

Graphical Metal contact measurement: latest contact pose rendered at frame 6, first visible ball movement frame 7, gap 1 frame. It does not measure display scan-out, native input or audio-device latency. Captures are local/Git-ignored; capture scripts and reports are retained. A 30-second fixed-FPS source movie is visual evidence, not a pacing benchmark.

Local physics timing, three four-second simulations: before broad-phase/cache improvement1335.533/1328.380/1329.964ms; after717.902/719.490/715.922ms,1920 ticks each. This is a local CPU probe, not exported p95/p99 frame-time evidence.

## Precision experiment, not active gameplay

`tests/experiments/impact_stepper.gd` stages ball-ball impact-limited time slices. The main engine remains on the previously accepted adaptive stepping path. The experimental solver passes the same950-assertion suite and90-entry/20-break matrix. Highest resolution comparisons now meet0.5mm/0.1degree in the named corpus; all-resolution misses fall from20 to7. Coarse rail/cloth comparisons still miss, and the current contact helper uses a sub-float32 positional nudge that should be replaced by explicit contact tolerance before promotion. Event-budget exhaustion and active frame cost also need evidence. Do not describe this prototype as a completed solver migration.

Baseline, current and experimental measurements are separately named under reports/physics-precision with hashes. The --enforce option intentionally exits1 on any threshold miss, preserving failed rows.

## Review and process

Luna workers implemented power, save recovery and shared geometry, and supplied independent stroke, render and pocket probes. The last worker review was interrupted by workspace-credit exhaustion. The parent completed the pocket repair/rerun and the experimental solver study; final integration is not fully independently reviewed. No commit, push or publication occurred.

An aim-controls test still emits known ObjectDB/resource warnings on teardown while assertions pass; this is explicitly retained as a lifecycle investigation. Other final test outputs must be read from continuation-checks/results.json rather than inferred from this prose.

## Still required for the owner's high bar

1. Finish S7 solver review, contact tolerance, event-budget diagnostics and rail/slate coupling; then promote through parity/regression/stress gates.
2. Acquire measured trajectories with uncertainty; calibrate friction, spin, throw, cushion and pocket response against held-out families.
3. Complete original art-direction comparison, motion/readability review at native/high-DPI/minimum window and an exported frame-pacing trace.
4. Replace/validate sound timbres and dense-contact voice handling through real listening comparisons. Lowering a soft-contact cutoff does not make samples natural.
5. Execute current competitor tasks and expert/novice repeated play. Owner review and the per-axis bar remain mandatory; no commercial parity claim is made.

## Local artifact closeout

The local 0.3.0 macOS app and DMG were rebuilt after final source edits; bundle signature verification passes. Packaged startup exits 0 with 43 resources loaded and no script errors. An attempt to execute the external source stroke test through the release binary timed out and is not counted as packaged interaction coverage. Source/headless interaction tests and the graphical source render test pass; installed-app interaction still needs review.

The retained motion clip is 30.5 seconds at 1600×900/60fps with audio. It was rendered through movie-maker fixed FPS, not recorded as a real-time performance trace. The current minimum-window probe records a 1100×700 window,1600×900 design viewport and1100×618 render texture: the difference is letterboxing, not evidence of a700px-tall native layout. Readability at that size remains open.

No solver prototype was promoted. The next qualified action is NEXT_CHECKPOINT.md. Workspace credits prevented the final worker review; parent verification is documented without presenting it as independent.
