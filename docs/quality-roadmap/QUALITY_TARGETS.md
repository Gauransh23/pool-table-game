# Long Rail quality contract

Revision **quality-bar-1**, authored 2026-10-31 and finalized 2026-11-01 against commit `5d63a3a2d1cdc83e5d1c72ecba8a2c3744efc274`.

**Mission:** one exceptionally convincing practice table. Players can express delicate intent, predict and reproduce positional play, trust every contact and opening, recognize the balls throughout motion, and receive coherent visual/audio feedback. This contract covers everyday pool mechanics and their fine detail. Match breadth, AI, online play and progression have separate milestones.

**State: specified, not achieved.** Every catalog obligation begins UNVERIFIED. Existing passing regression tests and the four original quality targets are useful floor evidence; they do not imply this higher contract passes. This turn authors specifications and test designs, not new implemented runtime tests.

## Read the relevant branch

- [Physics and geometry targets](targets/01-physics.md): equipment, strike, cloth, impacts, cushions, pockets, numerical precision.
- [Controls and presentation targets](targets/02-controls-and-presentation.md): aim, useful power levels, stroke feel, visuals and sound.
- [Validation and release targets](targets/03-validation-and-release.md): evidence, calibration, recovery, performance and human comparison.
- [Test protocols](TEST_PROTOCOLS.md): fixtures, sampling matrices, independent oracles, capture procedures and evidence formats.
- [Machine-readable requirements](QUALITY_REQUIREMENTS.json): authoritative IDs, thresholds, test-family mapping, basis and initial status. Generated target pages are read-only views; regenerate with `python3 docs/quality-roadmap/tools/render_targets.py`.
- [Implementation sequence](TASK.md) and [next numerical checkpoint](NEXT_CHECKPOINT.md): order of work and current state.

This contract supersedes earlier **proposed final quality thresholds** where stricter or better-defined here. Older reports remain historical measurements; retain their original targets/results. Record future revisions in `CONTRACT_REVISIONS.jsonl`. A test implementation cannot lower its own requirement to become green. New evidence can justify a reviewed contract revision, with old failures retained.

## What the numbers mean

Except source equipment ranges and independently derived identities, thresholds are **proposed product acceptance requirements**, selected to operationalize the owner's high bar. They are not claimed Miniclip measurements, universal billiards constants or proof of human perceptual limits. They are demanding engineering goals whose feasibility must be established by evidence.

Three kinds of fidelity have separate oracles:

1. **Numerical fidelity:** accurately solve the declared mathematical model. Use analytic fixtures, refinement, invariants, event timing and metamorphic tests.
2. **Physical fidelity:** the model reproduces identified real equipment within measured uncertainty. Use calibrated trajectories and held-out shot families. An equation can be solved perfectly and model the wrong behavior.
3. **Experienced quality:** people can intentionally select shots, understand outcomes and prefer the coherent result in actual play. Use native-device trials, visual/listening review and matched references. Screenshots and assertion totals cannot establish this.

No weighted total compensates for a failing axis. An attractive table with unreliable rails, or a precise solver with coarse input, remains below the bar.

## Supported physical domain

The required reference domain is level 9-foot pool with the declared equipment profile, ordinary soft-to-hard strokes, full cut range, signed/composed spin, rail-adjacent everyday stances, moving targets, frozen balls, clusters, six distinct pockets and ordinary small vertical responses. Test planar ball speeds through the declared 14 m/s solver envelope even though the current authored 8 m/s cue-speed cap usually produces a different maximum ball speed. Cue speed, ball speed and spin are separate quantities.

Ordinary elevation/clearance must be physically validated for final required coverage. During development, unavailable strokes are visibly blocked; declaring all everyday rail-adjacent/elevated strokes unavailable does not satisfy G2. Geometrically impossible strokes remain blocked. Full intentional jump/masse, arbitrary damaged equipment, random skids and tilted cloth are conditional extensions. Before exposing one, add its model/source, fixture families, acceptance bounds and recovery behavior to the contract. A hidden clamp is not a supported operating domain.

Reference values currently include 57.15 mm ball diameter, 0.168 kg ball mass and a 2.54×1.27 m playing area. Source equipment ranges constrain profile authorship; they are not numerical tolerances for virtual geometry and do not certify a real table. Current friction/restitution values are calibration inputs. Keep numerical algorithm experiments separate from coefficient fitting.

## Error budgets and decision rules

The catalog distinguishes:

- Quiet final refinement: <=0.10 mm endpoint and <=0.02° direction between successive high-quality solutions.
- Shipped numerical error versus a qualified reference: <=0.25 mm and <=0.05° on quiet families.
- Real measured behavior: trajectory RMS <=2 mm; held-out endpoint median <=3 mm and p95 <=8 mm, with adequate measurement uncertainty.
- Guide/render/contact agreement: world-space geometric bounds. Their subpixel size cannot be established from a screenshot alone.
- User precision: actual acquisition/selection tasks. Tiny machine increments do not establish human precision.

For a small heading error, lateral error is approximately `L * delta_angle` in radians. At 2.54 m, 0.005° is about **0.222 mm**; 0.05° is about **2.22 mm**. The fine-angle requirement therefore leaves room for other error sources. Do not equate the angle, numerical position and real-table calibration budgets or average them away.

For scalar numerical comparisons use `error <= max(absolute_tolerance, relative_tolerance * reference_scale)`. Each fixture names units and its nonzero reference scale; use an absolute bound near zero. Do not normalize by a nearly stopped ball, grazing normal speed or cancelling total momentum. Direction is undefined at sufficiently small speed; TEST_PROTOCOLS defines the transition to vector errors.

For measured comparisons report the instrument uncertainty and statistical uncertainty separately from model residuals. Use a conservative decision rule: a bound passes only when its applicable uncertainty-adjusted upper estimate fits the target; overlap with the target is INCONCLUSIVE, not a pass. Improve the acquisition or model before changing a threshold. Categorical recognition/strength accuracy gates explicitly designated descriptive in F-VISUAL/F-PERCEPTION use their frozen sample threshold and report uncertainty; they are not population lower-bound claims. Requirements expressly using confidence bounds, such as HUM-004/005, enforce those bounds. An independent reference itself needs an error budget.

## Measurement vocabulary

- World distances are meters in data; display summaries may use mm/micrometers. The simulation's planar `Vector2` is world `(x,z)`; height is world `y`.
- Spin is angular velocity in rad/s, angles are stored in radians and reported with an explicit degree conversion. Forces are N, impulses N·s, energies J, momentum kg·m/s, angular momentum kg·m²/s.
- A power percentage is an interface parameter. If an agent wants to display force, it must supply a contact-time/force model whose integral is the impulse. The current `StrokePower` returns **cue speed**, and `CueStrikeModel` derives ball speed/spin.
- A framebuffer pixel, design unit, OS logical coordinate point and typographic point are different. Record their transformations and physical pixel ratio. A letterboxed render texture does not describe the whole native window.
- Simulation event time, render-frame time, actual display presentation and audible onset are different clocks. Movie-maker fixed FPS supplies motion evidence, not real-time latency/performance evidence.
- A seed is reproducible only with source/profile/engine identity and a defined RNG stream. Cosmetic randomness has its own stream.

## Gates and completion

| Gate | Purpose | Required result |
|---|---|---|
| G0 | Evidence and recoverable baseline | Valid evidence, no silent harness failures, reliable state and restoration. This alone is not high quality. |
| G1 | Exact geometric and numerical foundations | Independent ideal references, meaningful contact tolerance, convergence and deterministic behavior across declared schedules. |
| G2 | Credible physical repertoire | Measured strike/cloth/ball/rail/pocket families and held-out calibration; supported domain explicit. |
| G3 | Expressive, coherent experience | Precise input, physically consistent stroke, readable stable visuals and actual sound/listening evidence. |
| G4 | Shipped and comparative acceptance | Installed/exported interaction and performance, long stress, independent reviews, experienced/novice panel and owner acceptance. |

Implementation proceeds in bounded dependency-ready slices; gates are not permission prompts before routine work. Acquisition and profiling can proceed alongside numerical implementation. Threshold changes, major model decisions and solver promotion require an evidence-backed decision record and independent review. If a model, source or instrument is unavailable, mark only the dependent obligations blocked and continue independent work.

To claim the practice-table quality milestone complete, **every required catalog ID must have current passing evidence**, all blockers/material defects must be resolved, and G4 human acceptance must exist. Conditional advanced domains can remain unavailable. A result with incomplete coverage is a candidate with an explicit coverage map.

## Execution status vocabulary

- PASS: valid current evidence satisfies the requirement in its declared scope.
- FAIL: a valid completed check violates the bound or invariant.
- NOT_RUN: the required procedure has not been attempted.
- BLOCKED: a named prerequisite prevents a valid check.
- INCONCLUSIVE: available valid evidence cannot resolve the criterion, for example because uncertainty spans the bound.

UNVERIFIED is the initial target-catalog annotation, not an execution pass. Only PASS closes an obligation. BLOCKED/INCONCLUSIVE rows preserve the data, reason and next discriminating action; they never disappear from the denominator.

## Executor contract

Before editing:

1. Read this file, the relevant target branch, TEST_PROTOCOLS and the affected source. Confirm checkout, dirty state and active runtime path.
2. Select requirement IDs for one bounded slice; state owner files, inputs, invariants, oracle, expected counterexample and exit evidence. Follow the current numerical checkpoint before promoting its experiment.
3. Record existing behavior with the smallest discriminating check. Read source facts as claims to verify, including tests and historical reports.
4. Implement and validate that slice, then run relevant integration/regression cases on the **active** engine and eventually the exported artifact. Preserve failing inputs and the best verified state.
5. Update a separate acceptance ledger; changing JSON target status alone is not evidence. Write a resumable packet on contradiction or two attempts without new information: exact baseline, diff, facts, disproved hypothesis, last good state, missing fact, next probe and resume condition.

The final report maps every attempted requirement to command/procedure, raw output, expected/actual result, uncertainty, source/artifact hashes, changed paths and residual risks. Independent reviewers start from requirements and raw evidence before reading the implementer's explanation. Preserve disagreements. No production solver migration is complete while tests exercise a separate implementation.

## Source basis and current observation limits

- [WPA equipment specification](https://wpapool.com/wp-content/uploads/2024/01/RECOMMENDED-EQUIPMENT-SPECIFICATIONS.pdf), effective November 2001, retrieved 2026-10-31: geometry/profile source; see sections 5,7,9,16. Its ranges do not prescribe our numerical/perception thresholds.
- [Alciatore technical proof index](https://drdavepoolinfo.com/technical-proof/), retrieved 2026-10-31: select the actual proofs for sliding/rolling, strike, squirt, throw, spin transfer and stroke kinematics; read assumptions before making them an oracle.
- [Mathavan/Jackson/Parkin cushion paper](https://drdavepoolinfo.com/physics_articles/Mathavan_IMechE_2010.pdf), DOI 10.1243/09544062 JMES1964: a limited rigid-cushion model. Its reported validation limit concerns normal velocity around 2.5 m/s for the authors' conditions; it does not justify applying its coefficients to all fast pool contacts.
- [W3 C WCAG 2.2 reference](https://www.w3.org/WAI/WCAG22/quickref/): source for selected contrast requirements. Our font-size and interaction-target dimensions are product choices; this is not a general WCAG compliance claim.
- [Four specialist competitor reports](COMPETITOR_REVIEW.md): actual official animations and imagery with explicit limitations. They show useful design choices; edited GIFs and an unentered login/guest screen cannot establish live timing, physical coefficients or sound quality. Audible reference acquisition remains open.

All new numerical acceptance bounds are product requirements unless their catalog basis explicitly names a derived identity or source. Preserve the distinction when an agent explains or implements them.
