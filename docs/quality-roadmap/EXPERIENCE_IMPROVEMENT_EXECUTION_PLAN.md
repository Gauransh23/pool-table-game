# Comprehensive pool experience improvement plan

Status: READY FOR BASELINE AND RECONNAISSANCE; implementation not started by this document.
Mode: high-risk handoff, because physical accuracy, input state, frame timing and perceptual acceptance cross subsystem boundaries.
Prepared: 2026-11-06. Inspected baseline: main at 23cb30f. Resolve the actual checkout and HEAD at execution time.

## Mission and success condition

Build a pool game whose smallest actions feel deliberate: selecting a thin cut, feathering a hanging ball, controlling draw, hearing a clean collision, watching a bank, and recovering from a scratch. Treat readability, control, physical credibility, timing, sound and learning as one experience.

The first deliverable is a playable, measured vertical slice. The eventual deliverable is a complete quality practice table meeting the existing required catalog. Neither prettier screenshots nor additional regression assertions establish either milestone by themselves.

The executor must produce working candidates and evidence, not repeatedly expand plans. Finish one bounded package before opening another that depends on it. This document is the requested plan, not authorization to claim implementation has happened.

## Authority, existing documents and scope boundaries

Read AGENTS.md, QUALITY_TARGETS.md, QUALITY_REQUIREMENTS.json, TEST_PROTOCOLS.md, the relevant generated target pages, TASK.md, NEXT_CHECKPOINT.md, PRESENTATION_REBUILD_PLAN.md and reports/ROOT_CAUSE_REASSESSMENT.md.

Current user directions take priority. QUALITY_REQUIREMENTS.json and QUALITY_TARGETS.md retain the acceptance contract; TEST_PROTOCOLS.md governs measurement. This plan governs the broader execution sequence. The older presentation handoff remains useful for artwork ownership and existing observations. Its freeze on coefficients and power mapping applies to presentation-only packages, not to separately justified calibration packages. NEXT_CHECKPOINT's experimental solver gates remain binding before promotion; this plan does not promote it.

If executable tests disagree with requirements, retain the failing evidence and explain which contract is authoritative. Never edit a target to match a failing implementation. Generated target pages must be regenerated from their actual source using the repository's documented generator, not manually diverged. Discover that command before editing the catalog.

Reuse the current checkout. Preserve unrelated edits and existing app/DMG artifacts. Establish actual tooling paths rather than assuming the previous machine's Godot path. Worktree/branch decisions follow current user directions; the previous handoff records a prohibition on creating either. Do not force-push, discard changes, or overwrite released bundles.

Within scope: baseline acquisition; input and power design; cue animation; geometry; numerical qualification; physical calibration; prediction; visual assets; audio; frame timing; practice drills; accessible interaction; exported quality assessment.

Deferred unless a dependency proves necessary: multiplayer/networking, matchmaking, monetization, accounts, inventories, engine ports, arbitrary equipment damage, advanced jump/masse, and a full competitive economy. Existing rules and match modules must remain compatible, but a full match mode is a separate milestone after the practice loop is convincing.

## Evidence ledger at entry

| Finding | Evidence class | Consequence |
|---|---|---|
| Direct pointer-to-cue-ball aiming has distance-dependent angular sensitivity | Source inspection | Measure human acquisition; implement a deliberate fine-input path |
| Aim preview stops at first contact | Source inspection | Define and validate useful departure assistance |
| Power uses a quadratic curve with a nonzero floor | Source inspection | Measure outcome resolution before tuning |
| Physics coefficients are provisional | Source and existing QA | Calibration remains open |
| Solver integrates then resolves overlaps in storage order | Source inspection | Test grazing contacts, ordering and convergence |
| 25 ms backswing/75 ms delivery, independent of selected power duration | Source inspection | Develop coherent soft/medium/hard stroke response |
| One sample/category and 12 round-robin voices | Source inspection | Audio naturalness and dense-break mixing need work |
| Angular pockets, weak material contrast and near-rail occlusion | Prior live review in presentation handoff | Reproduce at actual display sizes before revising art |
| Competitor offers configurable aiming/power controls | Official documentation | Benchmark interaction ergonomics, not hidden coefficients |
| Current build visibly stutters, sounds bad, or misses grazing contacts | NOT established in fresh reassessment | Obtain recordings/probes; do not report these as reproduced bugs |

Maintain this ledger as facts, inferences, assumptions, searchable unknowns and blocked observations. Every new claim must name a source commit, fixture, measurement, recording or explicit judgment.

## Ownership and state map

| Owner | Responsibilities and dependent paths |
|---|---|
| scripts/app/game_controller.gd | Input routing, shot lifecycle, simulation advance, event delivery, save/undo, HUD/presentation synchronization |
| scripts/ui/game_hud.gd and spin_pad.gd | Power/spin state, focus, accessibility, menus, action availability |
| scripts/sim/stroke_power.gd and cue_strike_model.gd | UI power to cue speed; strike impulse, angular velocity, squirt and supported offset |
| scripts/sim/physics_config.gd | Numerical settings and physical coefficients; keep those categories distinct |
| scripts/sim/physics_stepper.gd | Active integration/contact/event engine; tests must exercise this after promotion |
| scripts/sim/table_spec.gd | Shared physical geometry, support boundaries, pocket definitions |
| scripts/sim/ball_state.gd | State units, phase, orientation and physical constants |
| scripts/presentation/table_presentation.gd | Camera, table geometry/materials, guide, cue animation, visual synchronization |
| scripts/presentation/ball_visual.gd and assets/shaders | Ball readability, materials, shadows, physical rotation |
| scripts/presentation/table_audio.gd and assets/audio | Contact samples, mixing, voice lifecycle and provenance |
| scripts/game | Rack and rules/match behavior; inspect callers before changing event semantics |
| tests and tools | Fixtures, measurement harnesses, exports, reports and generated documentation |

Before editing, trace actual callers and sibling paths. In particular inspect source and export startup, menu versus focus loss, mouse versus keyboard, aim versus placement, current versus restored state, and ordinary versus experimental solver. A test-only path is not proof of shipped behavior.

## Non-negotiable invariants

1. One committed stroke produces exactly one physical impulse and one associated strike event. Cancel, blur, menu, resize and released capture never accidentally fire.
2. Simulation state remains authoritative. Cosmetic randomness, guides and animations cannot mutate it.
3. World units, screen pixels, logical points, cue speed, ball speed, angular speed, impulse and force remain explicitly distinct.
4. A power percentage is an input parameter; do not label it force without a justified contact-time model.
5. Rendered mouths, guide collision geometry and physical table geometry agree within the catalog's budgets.
6. Save/undo preserves a valid recoverable state and does not silently reinterpret older data after changing profiles or schema.
7. Unsupported strokes are visibly identified. Hidden clamps are not support. Ordinary clearance requirements cannot be evaded by disabling all difficult strokes.
8. Regression counts retain their original scope. New numerical and perceptual targets need their own evidence.
9. Never simultaneously fit coefficients and change the solver when attributing a physical improvement.
10. Preserve failing fixtures, source/profile identity, seeds, platform and raw measurements.
11. Every fallback has an observable counter and supported-domain explanation; event-budget exhaustion cannot silently degrade fidelity.
12. No full-quality claim until the catalog's required G0–G4 obligations actually pass.

## Decision policy and architecture

Keep Godot and the current module ownership unless a measured limitation justifies a change. Prefer shared physical geometry and one active physics implementation. Introduce only the narrow interfaces needed for input intentions, prediction snapshots and timestamped feedback events.

Choose direct coarse aim plus an explicit fine-adjustment path as the initial interaction experiment. Compare relative drag/wheel alternatives with task evidence; do not assume smoothing solves precision. Keep the existing explicit shot action during the first power-control prototype. Release-to-shoot requires its own cancellation contract.

Prediction should consume an immutable state snapshot and the active strike/contact semantics. Begin with a short departure horizon. Full trajectories are conditional on a demonstrated accuracy and CPU budget; do not imply certainty beyond validated scope.

Retain the active solver until qualification gates pass. First test whether existing shortcomings arise from numerical error, provisional parameters, or perception. Replace algorithms only when the relevant counterexamples and performance evidence support that decision.

Difficulty allocation: numerical promotion, calibration interpretation, prediction semantics, input lifecycle and final visual/audio judgment require lead decisions and independent review. A smaller worker can implement a frozen fixture, asset integration, explicit widget behavior or a local rendering change. Do not assign a smaller worker “make physics realistic” or “make it polished.”

## Phase 0 — Identity and baseline

Inputs: actual checkout, current HEAD, existing reports and available app artifacts.

Actions: record git state and upstream; identify Godot version, renderer, hardware, display scale and export settings; read instructions; inventory tests and tool entrypoints. Preserve a named baseline artifact and screenshots before any edits. Use a disposable user-data location for test sessions so player saves are not overwritten.

Run relevant baseline checks once and record pre-existing failures separately. Discover the executable and use the existing command form, typically `"$GODOT_BIN" --headless --path "$REPO_DIR" --script res://tests/<suite>.gd`; confirm script arguments before use. Do not fabricate installed paths or assume a nonzero exit is an application failure without reading its report.

Outputs: baseline manifest, initial acceptance matrix, known failures, environment and reproducible commands in a checkpoint report under reports/experience-improvement/.

Exit: another agent can reproduce the baseline and distinguish new regressions. If the export cannot launch, diagnose that independently before making experience claims. Rollback: preserve the baseline, no gameplay change in this phase.

## Phase 1 — Reconnaissance and observation

Create frozen shot fixtures for: feather pot; hanging ball; long straight pot; thin cut; stun; draw; follow; running/reverse side bank; shallow rail shot; jaw rejection; rattle; frozen cluster; dense break; scratch placement; shot near a rail; stripes with hidden caps.

Record layout, shot direction, power, tip offset, profile, seed, source identity and expected observation. Include mirror and ball-array permutation variants where meaningful. Record intended target and cue-ball leave zone, not merely whether any ball was pocketed.

Acquire actual app recordings and timestamped simulation events. Capture native minimum/default/large windows, overhead/lounge cameras, mouse and keyboard. Use real-time capture for pacing; fixed-FPS movie capture does not establish latency. Check exported behavior separately from source behavior.

Competitor observation protocol: record platform, game version if visible, cue/equipment, assistance settings, frame rate and clip timestamps. Observe controls, power, impact sequencing, motion, pockets, guide and audiovisual design separately. Record unavailable sessions as blocked. Video estimates need perspective/time uncertainty; never infer exact hidden friction from an uncalibrated clip. Use official documentation for stated behavior and actual recordings for visible behavior.

Output: a matched observation ledger with evidence links and the smallest experiment that could disprove each suspected root cause.

Exit: each proposed change has a player problem and falsifiable measurement. Rollback: observational only. Pivot if source suspicion is not reproducible; do not implement speculative fixes merely to fill the plan.

## Phase 2 — Contract and risk

Map each package below to exact existing catalog IDs before coding. Do not guess ID suffixes: look them up in QUALITY_REQUIREMENTS.json. Record applicable numerical, control, visual, audio, recovery and performance obligations.

Define the state transition table: ready, aiming, fine adjustment, power adjustment, spin adjustment, committed delivery, motion, settling, placement, menu and recovery. Specify allowed inputs, ownership of pointer capture/focus, cancellation, retained state, and next state. Distinguish cancellation before contact from an already applied shot.

Establish budgets from the existing contract. Where no threshold exists, write a proposed measurable criterion and rationale before taking acceptance data; label it proposed until reviewed. Do not select a threshold after seeing results. Preserve independent physical/numerical/perceptual budgets.

Exit: lead reviews state contract, package dependencies, exact target IDs and unresolved questions. Routine implementation proceeds without repeated user permission. A blocked measurement blocks only its dependent acceptance claim.

## Phase 3 — Bounded execution packages

### A. Measurement fixtures and event timing

Owners: tests, tools, minimal simulation/controller instrumentation.

Deliver deterministic fixture load/replay, input and event timestamps, frame interval capture, and machine-readable result summaries. Include snapshot identity and cosmetic RNG separation. Check that instrumentation does not materially alter timing; measure its overhead. Store raw data separately from derived summaries.

Acceptance: identical replay from identical state is explainable/reproducible under the declared platform contract; invalid fixtures fail loudly; reports preserve missing events and time discontinuities. Counterexample: an empty run or malformed result must not appear green.

### B. Coarse and fine aiming

Owners: controller and HUD, input fixtures.

Implement the chosen fine-aim path, adjustable sensitivity if supported by the design, clear mode feedback and retained direction when moving to controls. Specify pointer-distance behavior, dead zone, angle wrap, button release, focus loss and keyboard coexistence. Avoid accidental jumps on entering fine mode.

Acceptance: acquisition error/time on long and thin shots at multiple resolutions meets catalog tasks; replayed identical input has stable meaning; one-pixel adjustments near the ball do not force uncontrollable coarse jumps in fine mode. Negative cases: drag outside cloth, outside window, over controls, resize mid-gesture, menu, second button, and blur.

### C. Power and strike response atlas

Owners: power/strike model and measurement fixtures; no artwork dependency.

Sweep every selectable power setting where practical, with denser analysis near zero and important shot transitions. Record cue speed, initial ball speed/spin, slide/roll distance, time to rest and contact outcomes for center, draw, follow and side offsets. Separate free motion from rail/contact cases.

Determine whether the nonzero floor and quadratic curve allocate useful control. Compare alternatives on the same fixtures and user tasks. Freeze one proposed mapping with rationale and regression expectations. Version physical/profile changes as needed; inspect save/replay compatibility before changing semantics.

Acceptance: monotonic intended response where physically appropriate, bounded resolution of useful outcomes, no unexplained discontinuity, controllable soft shots and adequate break range. Counterexample: a mathematical monotonicity pass does not prove player repeatability.

### D. Power gesture and cue animation

Owners: HUD/custom power control, controller lifecycle and presentation cue methods.

Build a compact pullback interaction linked visibly to selected power. Preserve exact numeric access and keyboard operation. Specify adjustment, confirmation, cancellation and release behavior before implementation. Keep spin reminder visible while setting power.

Tune soft/medium/hard pullback, delivery acceleration, exact tip contact, follow-through and withdrawal as a coherent sequence. Avoid delays that unnecessarily postpone readiness. The selected physical impulse must occur at contact exactly once.

Acceptance: zero power cannot fire; cancel/blur cannot fire; contact-to-motion and sound alignment meet contract; cue tip does not penetrate before impulse; weak and strong shots communicate distinct effort. Capture actual motion, not just final keyframes.

### E. Numerical solver qualification

Owners: active stepper, existing experimental harness and numerical fixtures. Lead-owned decision.

Execute the unresolved NEXT_CHECKPOINT work: meaningful contact tolerance, separating-pair rejection, time-shifted impacts, exact touch, micrometer gaps, grazing, frozen chains, event exhaustion, storage permutations, energy including rotation, and render-chunk independence. Compare timestep refinements and qualified analytic/reference solutions. Report worst cases, not only averages.

Preserve existing rail/slate ordering until a justified coupled model replaces it. A ball-only improvement does not certify cushions or pockets. Profile the same scenarios in current and candidate engines. Promotion must update the active engine and all acceptance paths consistently, preserve a rollback revision and obtain independent review.

Exit: required numerical/promotion gates pass with valid reference uncertainty and exported performance. If blocked, retain current production engine and continue independent experience work. Never relabel a coarse comparison as acceptable by dropping the fixture.

### F. Physical calibration and supported repertoire

Owners: config, strike, cloth/contact response and calibration fixtures. Depend on adequate numerical qualification for the mechanism being fitted.

Fit in order: free rolling; sliding-to-rolling; spin decay; center strike; offset strike; direct ball collision; cut throw; clean rail rebound; side-spin rail response; jaw/shelf/liner behavior. Use held-out conditions and report acquisition uncertainty. Keep speed, incidence angle and spin as independent variables.

Evaluate whether constant restitution/friction suffices within the supported range. Introduce dependencies only when data and improved held-out behavior justify complexity. Document material/equipment assumptions. Avoid fitting one visual clip or one attractive break.

Acceptance: catalog physical residuals and supported-domain requirements pass; no arbitrary force injection, pocket attraction or coefficient manipulation to compensate for numerical errors. Counterexamples: very slow approach, near-grazing rail, extreme supported tip offset, draw that becomes rolling before contact, and spin reversal after a bank.

### G. Pocket geometry and acceptance

Owners: table_spec, stepper pocket contacts, presentation geometry.

Map acceptance by entry angle, lateral offset, speed and spin for all six pockets. Include jaw impacts, shelf support, hanging balls, rattle/rejection, double-ball entry, already falling balls and re-entry. Verify rendered opening, support edge and collision boundaries together.

Any model extension must preserve the explicit irreversible scoring event. Distinguish mouth crossing, loss of support, committed capture and terminal disappearance. Design visual occlusion and audio timing around those events.

Acceptance: shared geometry agreement and pocket matrix requirements pass; mirror cases agree within declared tolerances; no unsupported teleport or scoring at reversible mouth entry. Do not change acceptance dimensions merely to make new art look better.

### H. Trustworthy shot assistance

Owners: a narrow prediction component, controller and guide rendering.

Use an immutable snapshot, chosen input and active strike/contact semantics. Show hollow contact marker and short departures only over a validated horizon. Define when the preview is absent, truncated or uncertain. Cover squirt, throw, cushion proximity, overlapping initial state, obstructed rays and spin changes.

Cache by actual inputs/state/profile; invalidate after undo, load, placement and config changes. Bound prediction CPU work and expose unsupported cases. Do not draw guides over UI or confuse a preview ball with a physical ball.

Acceptance: compare predicted contact/departure against actual trajectories by speed/cut/spin family. Test snapshot purity, stale-cache invalidation and rapid adjustment. An ideal geometric line alone is insufficient for a guide advertised as physical.

### I. Table, balls, camera and visual language

Owners: presentation, ball visuals, shaders and original/licensed assets.

First finish one pocket plus three balls at actual gameplay pixel size. Establish silhouette, bevels, cushion/cloth/wood/lining separation, resin highlights, contact shadows and restrained texture scale. Compare three focused art alternatives, then select one through lead review. Do not repeatedly generate complete unrelated table styles.

Solve dark-ball and stripe recognition, hidden caps, clusters under guides, near-rail visibility and pocket depth cues. Keep actual physical orientation; optional identification overlays must be visibly separate aids. Overhead is the primary playable camera. Lounge must meet visibility requirements or be clearly a presentation view.

Acceptance captures: rack, spread, each pocket, dark balls at rails, stripes facing away, cue/guide overlap, falling balls, moving cluster and both cameras at specified sizes. Use recognition/material tasks from the contract. Verify that apparent ball size and guide thickness remain useful across display scale. Artwork provenance is required.

### J. Contact audio and mixing

Owners: audio component, event adapter, assets and bus configuration.

Acquire or author credible cue, ball, cushion and pocket material sounds with soft/medium/hard coverage and natural variants. Record license/provenance and processing. Choose variants from cosmetic RNG. Preserve valid event positions for camera-consistent spatial cues.

Replace unconditional round-robin interruption with a bounded salience/voice policy. Protect cue and pocket events, fade interrupted tails, avoid duplicate contact chatter and retain physically distinct simultaneous impacts. Muting stops active tails. Do not compress separate tick events silently after a frame stall; define an explicit scheduling policy with latency bounds.

Acceptance: listening to isolated contacts and dense breaks, audibility/material/intensity discrimination, clipping/true-peak evidence where required, no repeated identical machine-gun timbre, mute/menu/focus lifecycle checks. Scheduling tests do not establish naturalness. Missing calibrated output measurement remains explicitly unverified.

### K. Motion presentation and performance

Owners: controller/presentation timing and profiling tools.

Measure frame intervals, simulation catch-up cost, guide-update cost, draw load and event delivery under slow roll, break and maximum supported load. Compare source and exported app. Test supported refresh rates and realistic window sizes on available hardware; mark unavailable hardware honestly.

Only add interpolation after establishing its benefit. Define render time, collision discontinuities, orientation interpolation, falling/pocketed transitions and input latency. Never interpolate through a wall or resurrect a pocketed ball. If catch-up budgets are needed, define how time and replay correctness are preserved and expose overrun counters.

Acceptance: catalog pacing and latency budgets, stable slow movement, bounded workload, no accumulating audio/visual drift, and no visible collision smear. Movie capture cannot replace real-time profiling.

### L. Learnable practice and accessible flow

Owners: controller/HUD and a focused drill/fixture layer.

Deliver saved repeatable setups, retry identical shot, target leave zones, and a short progression covering power control, straight pot, cut, stun/draw/follow and bank. Explain result with minimal relevant feedback: target hit, miss direction, leave distance, or why assistance was limited. Avoid generic praise on every outcome.

Preserve undo, session recovery, menus, keyboard focus, scratch placement and discoverable controls. Provide contrast/identification options and reduced distracting motion where applicable. A drill must not mutate normal play profiles or corrupt the session save.

Acceptance: first-time users can aim, set power/spin, cancel, shoot, retry and recover from scratch; keyboard paths are complete; save/load handles profile/schema changes explicitly. Compare learning across repeated attempts, not only immediate completion.

## Dependency order and first implementation checkpoint

Baseline and observation precede acceptance claims. A supports all packages. B and C can proceed independently after their contracts; D consumes their decisions. E and F must remain separate attribution stages. G consumes qualified geometry/contact behavior. H depends on explicit active-physics semantics. I can begin as an isolated visual slice; J begins with actual sound acquisition and event requirements. K profiles continuously and hardens the integrated result. L follows stable interaction semantics.

First checkpoint: A plus the bounded B fine-aim implementation, with baseline captures of the three-ball/one-pocket scene. Deliver useful precise aiming and evidence without changing physical coefficients, power mapping or solver. Exit with routed input tests, acquisition-task data where available, and a playable export. This isolates one player improvement and creates the evidence infrastructure for the rest.

Second checkpoint: C decision plus D prototype on the same scene. Third: I and J integrated with the stroke. Numerical and calibration investigations may run independently, but shared runtime files require serialization and lead integration. Never delegate competing edits to game_controller.gd simultaneously.

## Verification matrix and commands

Discover current scripts before running them. Existing relevant suites include tests/run.gd, aim_controls.gd, practice_input_flow.gd, practice_flow.gd, save_recovery.gd, stroke_contact.gd, stroke_power.gd, spin_precision.gd, audio_contacts.gd, table_geometry.gd, pocket_support.gd and visual_geometry.gd. Inspect each suite's actual scope and output; do not assume its name proves coverage.

| Change | Minimum evidence |
|---|---|
| Input/HUD | Routed viewport input, boundary cancellation, keyboard, native interaction |
| Power/strike | Full selectable-domain atlas, spin variants, zero/bounds, contact timing |
| Solver | Analytic/reference comparison, convergence, permutation/mirror, dense stress, runtime profile |
| Calibration | Instrument uncertainty, fitted versus held-out data, supported domain |
| Geometry | Physical/render/guide agreement, all pockets and boundary cases |
| Prediction | Actual versus predicted trajectories, purity/cache, CPU cost |
| Visuals | Native stills plus motion; recognition and material assessment |
| Audio | Event lifecycle plus actual listening; timing/output measurement |
| Save/drills | Old/new schema policy, retry identity, corrupt-state and cancellation recovery |
| Release | Export/signature/build identity, installed GUI flow, source/artifact manifest |

Run affected tests after each meaningful change, then integrated suites once at the checkpoint. Investigate failures; do not repeatedly run all suites without a changed hypothesis. Add behavioral tests for real risks, not tests duplicating implementation arithmetic. After the first green result, perform a counterexample review covering alternate inputs, lifecycle interruption and a deliberately invalid fixture/report.

The existing quality catalog's thresholds govern final acceptance. Record PASS, FAIL, NOT_RUN, BLOCKED or INCONCLUSIVE per requirement and scope. Passing a narrow fixture never upgrades an entire domain. Report uncertainty separately from measured residuals and avoid averaging away worst-case violations.

## Review, rollback and escalation

Every package ends with a small reviewable diff, a checkpoint report and a reproducible artifact where relevant. Commit only scoped changes after inspecting the diff. Rollback means a named prior candidate and a focused revert of the package; never destructive checkout cleanup. Preserve save compatibility or provide an explicit migration/backout procedure before changing persisted semantics.

Independent review must check intent, active runtime wiring, counterexamples, measurement validity and misleading claims. Numerical promotion and the integrated release need independent review. If no reviewer is available, report that limitation and keep dependent promotion conditional.

Escalate with evidence when: the contract conflicts with measured reality; a solver improvement violates performance; a prediction cannot meet error budgets; a proposed schema breaks recovery; a required reference/instrument is unavailable; or two physical explanations fit existing data equally well. Do not ask broad questions such as “what should I do?” State the exact competing choices, evidence, smallest distinguishing probe, recommended next step and affected obligations. Continue independent work while a dependent decision is blocked.

## Worker brief template

You own package [ID] in [actual checkout], based on [commit]. Read [specific instructions, target IDs, source owners, tests and baseline report]. Implement only [observable behavior]. Preserve [listed invariants]. Your allowed paths are [paths]; report any necessary expansion before editing shared owners. Inputs and interfaces are [frozen decisions]. Unknowns are [bounded probes].

Before edits, return a concise readback of owner/callers, required behavior, acceptance checks and risks. Then implement, run the affected checks, inspect the actual runtime behavior where needed, and report changed paths, commands, evidence, failures and next action. Do not tune thresholds, change coefficients, promote a solver, or claim perceptual quality beyond this package's authority. Stop dependent work and send an escalation packet when the specified trigger occurs.

## Checkpoint and final report format

Checkpoint: package; source/base commit; requirement IDs; behavior before/after; files changed; commands and actual results; raw evidence paths; human observations and conditions; unresolved failures; compatibility/performance impact; rollback revision; next dependency-ready action.

Escalation packet: violated requirement; minimal fixture; expected/actual; evidence; competing explanations; attempted probes; recommendation; work that can safely continue.

Final milestone report: playable artifact and source identity; completed package/requirement matrix; comparative captures; physical/numerical/calibration results with uncertainty; native/exported performance; reviewer findings and disposition; user evaluation; remaining unsupported regimes; precise claim permitted by evidence.

The vertical-slice milestone is complete when its scoped behaviors work together and its evidence supports a better shot loop. The complete practice-quality milestone remains open until all required catalog gates pass. A future agent must not interpret the existence of this plan as evidence that any of those improvements or acceptance tasks are already complete.
