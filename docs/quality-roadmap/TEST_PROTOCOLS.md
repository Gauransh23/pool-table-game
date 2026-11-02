# Test and evidence protocols for quality-bar-1

This file designs the tests required by [QUALITY_TARGETS](QUALITY_TARGETS.md). Most new coverage is **planned**, not implemented. Existing filenames below are reconnaissance starting points. A check passes only for the actual requirement, parameter domain and artifact it exercises.

## Shared fixture and result contract

Each fixture records schema/requirement IDs; source/profile/solver hashes; engine/compiler precision; seed/RNG streams; meters/seconds/kg/radians; full ball identity, phase, position/height, velocity, spin, orientation and pocket state; table/cue/cloth/material parameters; input/elevation; duration or explicit termination condition; independent oracle/source; tolerances and valid domain; expected physical outcome and event policy. Each result stores initial and terminal states, sampled trajectory and velocity/spin, event pairs/times/positions/impulses, penetration extrema, contact-limit diagnostics, CPU work, reference error, measurement uncertainty and status.

Run hashes must identify the loaded runtime, not just a repository HEAD. Store raw records before summaries; preserve failing seeds, invalid harness runs and baseline data under distinct names. A failed output write invalidates a measurement. An interrupted run cannot overwrite a qualified baseline.

### Numeric comparison rules

- Use a specified absolute floor plus relative scale: `bound=max(abs_tol,rel_tol*reference_scale)`. Energy and momentum have separate units/scales. For elastic collision energy use incoming total kinetic energy; for momentum use a noncancelling scale such as `sum(m*|v|)` plus the stated absolute floor, while still comparing the **vector** residual.
- For a closed free-space fixture, angular momentum is orbital `sum(r cross m*v)` **plus** intrinsic `sum(I*omega)`, relative to a declared common origin. A fixed table supplies external impulse, so ball-only momentum need not be conserved there.
- Energy ledgers include translational, rotational, gravitational potential, external cue work, dissipative losses and numerical projection work. Capturing/removing a ball transfers its energy to a ledger; it cannot erase a negative potential term and manufacture apparent gain. Test pair impulses at the same positions before/after, and integration over time separately.
- Compare direction only when both planar speeds are >=0.05 m/s. Below that, use vector error <=1e-4 m/s for numerical fixtures, and calibrated absolute uncertainty/bounds for measured data. Never divide by near-zero speed. Physical measured low-speed velocity bound is <=0.002 m/s with adequate tracking uncertainty.
- For timing roots, normal closing speed >=0.01 m/s uses the BAL timing formula. Near tangency use minimum separation/contact boundary and event existence rather than an ill-conditioned time quotient. Record full velocity-vector errors as well.
- For rotational traces compare quaternion geodesic error **and unwrapped rotation/phase** where an analytic spin axis exists. Quaternion equality modulo 2 pi alone can hide a missed revolution.
- Reflection matrix `M` transforms position/velocity as `M*v` and spin as `det(M)*M*omega`. For reflecting world z, spin maps to `(-wx,-wy,wz)`; reflecting world x maps to `(wx,-wy,-wz)`. Transform cue offset frames, table geometry, gravity and event labels consistently. Only actual equipment symmetries qualify.

## Coverage strategy

Full Cartesian enumeration is required for cheap ideal analytic fixtures and selected boundary domains, not for an unbounded physical laboratory matrix. All explicit extremes, signs, physical transitions, six pocket identities and previously failing cases must be present. For the large interaction domain, publish the selected pairwise/covering design plus additional high-sensitivity combinations; a named omitted interaction is a coverage gap, not a silent pass. Refine boundaries adaptively and preserve a held-out set.

Required numerical ball-speed set: `0.01,0.05,0.2,1,3,8,14 m/s`. Cue-speed set is separate: `0,0.05,0.1,0.2,0.5,1,2,4,6,8 m/s` within the declared cue profile. Probe just beyond each supported limit for explicit handling, not a silently changed shot. Tip ratios: center plus radial `0.1,0.25,0.45,0.49,0.50`, eight azimuths and just-outside offsets. Ordinary stance elevations: `0,2,5,10 degrees`; higher values belong only to an explicitly supported conditional domain.

Cut angles: `0,5,15,30,45,60,75,80,85,89,89.9 degrees`, plus adaptive tangency bracketing. Rail incidence is measured from the inward normal and spans `0,5,15,30,45,60,75,85,89 degrees`. Contact-phase shifts: at least 16 equally spaced offsets through one **coarsest** reference step; each shifted physical initial state is identical across all refinements. Compare at identical physical horizons, not one extra ceil-rounded tick. Use a rational base horizon N/240 seconds (for example N=108 for0.45s), exact integer tick multipliers for480/960/1920Hz, and record actual elapsed simulation time. For other schedules, use independently bounded dense output at an exact common time. Fixed-time trajectory convergence and naturally settled endpoint convergence are separate metrics; a plateau needs two consecutive refinement differences within the bound.

## F-EVIDENCE

**harness validity and independent review**

Map EVD IDs to the result schema and validate all required IDs before signoff. Demonstrate a negative run: break a fixture expected value, omit a dependency, introduce a nonfinite state, make the capture/output path unwritable, and interrupt a long run. Each must be clearly failed/invalid, never a misleading exit 0 pass. Validate summaries against raw rows and source hashes. Historical source reports, native experiments and current gameplay are separately named.

A reviewer reads the owner request, this contract, source/diff, fixture inputs, raw results and uncertainty. They independently reproduce selected analytic and adversarial cases before reading the implementer's conclusions. Review returns PASS/CONDITIONAL/BLOCKED with concrete defects and remaining evidence. If fresh independent review is unavailable, record it and keep the affected promotion conditional.

## F-GEOMETRY

**surfaces, support and cue volume**

Independently measure generated mouth widths, nose height, shelf distance from mouth midpoint, finite jaw length, cut/facing angles, edge rounding and solid slate thickness. Draw section diagrams to establish interior/exterior angle convention. Source ranges and virtual model coordinates are different tolerances.

For each surface sample uniform points, high curvature, all seams/endpoints and deterministic random points. Compare render/contact signed distances and normals; evaluate meshes at every supported LOD. Compare support queries with independent triangle/solid membership. Use boundary pairs at 1,10,50,100 micrometers and exact edge; include face, corner and seam approaches. World-space assertions establish subpixel geometry; captures only demonstrate visibility/composition.

Vary each geometry parameter individually and together; ensure all derived caches update. Hash shared definitions before/after rendering, picking, preview, save/reload and 10000 query cycles. Rebuild twice and verify IDs, normals and dimensions. Exercise placement with full sphere clearance, not just center membership.

Sweep the entire cue shaft/ferrule/tip through aim and delivery. Test cue-ball distances from each rail and object ball at 0,0.5,1,5,10,30 mm clearance; multiple headings and offsets. Valid ordinary elevation must clear solids and correspond to the delivered impulse; otherwise the interface must expose the obstruction before commitment.

## F-INPUT

**real aim and modality**

Use the actual scene/Viewport GUI path and separately native mouse and trackpad. Gesture corpus: cloth press/drag/release, unpressed travel, GUI-origin and right-button drag, release over GUI/outside window, focus loss, missing release, held key repeats, menus, pause, placement, reset, undo, camera/zoom/resize and DPI transition. Test both event orders around commitment and contact.

For fine resolution, use headings near each axis and diagonal, native pointer displacements and each keyboard/fine mode. Record line angle, physical launch angle, selected mode, display response and return-to-origin after 100 positive/negative steps. Dense sweeps cross cue center, targets, jaws and UI boundaries. Machine reachability and user task error are separate datasets.

Reproject a world-space table grid to screen and pick it back in both cameras; measure framebuffer-pixel error with the actual viewport transformation. Repeat after moving/resizing the native window and while/after camera transitions. An invalid projection must fail explicitly rather than silently returning world origin as a valid aim target.

For latency use 1000 native adjustments at the declared 60 Hz baseline, with hardware timestamps or calibrated high-speed capture of input activation and display output. Log OS input, app event, render submission and actual presentation separately. Synthetic method calls and encoded video timing cannot supply the end-to-end native result.

## F-POWER

**useful shot selection**

Freeze the cloth/cue profile and use a sufficiently wide no-rail fixture. Starting from the actual UI/controller, enumerate all low-end reachable settings and at least 101 across the range, including 0 and the maximum. Record cue speed, ball launch speed, spin, path length, stopping time/distance and readiness. The current formula is a baseline, not an oracle for its own test.

Test whether 50,100,200,500,1000 mm targets are machine-selectable within the catalog bounds. Report nearest input and actual endpoint, quantization gaps and local slope. Use equivalent center-ball initial states; spin/elevation changes do not promise equal launch speed at equal cue speed. Keep force, cue speed, ball speed, energy and eventual distance distinct on plots.

Then run human landing tasks with 20 attempts per target/user after a fixed familiarization period. Log requested/selected input, endpoint error, overshoot corrections, completion time and accidental commitments. A pull-back/release prototype and current slider/button use the same physical mapping for a fair interaction comparison. Freeze the selected mapping and retain both alternatives' evidence before adoption.

## F-STRIKE

**impulse, contact and ordinary stance**

Run supported cue speeds, offsets/elevations and both signs, including combined spin. Compare the strike against the selected independent effective-mass/impulse model and measured launch/spin data. Declare cue mass, effective end mass, ball inertia, loss mechanism and recoil assumptions. Do not require ball momentum to equal incoming cue momentum if the unmodelled recoiling cue retains momentum; instead use a closed-system or correctly derived transfer oracle.

For force-time claims, numerically integrate the specified contact-force curve and verify its impulse, work and resulting linear/angular states. A force percentage without contact duration is not a force measurement. In the required stationary-cue-ball domain, input energy is0.5*m_cue*v_cue²; subtract initial ball energy from outgoing ball energy before comparing its gain. Declare any additional external work. If tracking the cue too, include its outgoing/recoil energy and losses in the closed ledger. A moving-ball strike requires a separately qualified relative-motion model or explicit rejection. Measure energy before and after the actual strike including rotation. Miscue/unsupported offset/elevation handling must be explicit and reproducible.

Evaluate visual stroke position and continuous velocity at contact, selected contact arm, contact point and emitted impulse from the same committed data. A render-frame displacement estimates an **interval-average** velocity; compare it with the integral of the authored motion curve, not an instantaneous derivative. For a physical contact-speed claim use adequate high-frame-rate capture or an independently checked continuous curve. Travel, time and endpoint speed cannot all be chosen independently.

Interrupt delivery at 0/25/50/90/99/100% timeline positions. Change UI fields while pending, request duplicate shots, and lose focus. Sample visible contact and first ball motion frame by frame at 30/60/120/144 Hz where supported. Capture error/write failure invalidates that run. Hardware presentation/audio validation is still separate.

## F-CLOTH

**independent analytic worked examples**

Use an ideal uniform solid sphere with `I=2*m*R²/5`, level isotropic cloth and the stated constant-coefficient assumptions. For sliding contact slip `u`, friction reduces its magnitude at `7*mu_s*g/2` while direction/regime is unchanged. The transition time is `2*|u0|/(7*mu_s*g)`. Split integration at the transition; integrate rolling resistance afterward. These identities do not model every real cloth.

Worked fixture A: initial `v0=1 m/s`, no spin, `mu_s=.2`, `g=9.81`. Independent values are `t_roll=2/(7*.2*9.81)`, `v_roll=5/7 m/s`, and `x_roll=12/(49*.2*9.81) m`. Compare time, full trajectory, speed, slip and spin, not just endpoint.

Worked fixture B: pure rolling `v0=1 m/s`, `mu_r=.012`, `g=9.81`. Expected stopping time is `1/(.012*9.81)` seconds and distance `1/(2*.012*9.81)` meters; use a wide enough fixture to avoid a rail. For sleep, a **velocity-only** cutoff at`.012 m/s` would omit about`.612 mm` of ideal rolling travel. The current implementation also checks spin, so evaluate the actual compound condition; do not accuse it of that omitted distance without a trace. To limit tail to`.05 mm`, the rolling speed bound alone would be about`.00343 m/s` for this profile, or finish the tail analytically.

Extend to reversed slip/draw, pure sidespin, rolling with side spin, spin outlasting translation and speed near rest. Track quaternion phase and visible marking motion. All material assumptions, coefficients, errors and actual transitions must be logged; tuning friction cannot substitute for adequate input resolution.

## F-BALL

**impulses, grazing and simultaneous contact**

Worked fixture C: equal masses, no friction/external force, first ball `(vx,vz)=(1,0)`, second at rest, head-on. Expected outgoing velocities are `(0,0)` and `(1,0)`. For a contact normal 30 degrees from incoming direction, object velocity is`(0.75,0.4330127019)` and cue velocity`(0.25,-0.4330127019)` m/s. Compute independent momentum and total energy. Include total angular momentum with orbital terms about the same fixed declared origin before and after frictional free-space contacts. Translated-origin consistency is an additional check when linear momentum is conserved.

Worked fixture D: centers start`.2 m` apart, diameter`.05715 m`, one approaches at`1 m/s`. First-contact time is`.14285 s`. Shift the physical launch state across 16 coarsest-step phases; reuse each identical state at every quality. Include both balls moving, vertical offset, exact touch, separating touch, true clearance and micrometer gaps. Check event existence, normal, transferred velocity/spin, time and final position.

For throw/spin transfer, source a valid model and experimental families; sweep cut angle, speed, slip state and signed spin including gearing. Use frozen pairs,3/4-ball chains, triangles, double kisses and dense racks. Simultaneous rigid contact may not have a unique individual impulse decomposition; validate a declared contact law, conservation/complementarity where applicable, refinement and observable outcomes, not one arbitrary impulse vector as universal truth.

Measure penetration immediately before resolution, residual immediately afterward and all settled overlaps, including configured slop. Preserve worst states and separate these metrics. Permute storage independently of ball IDs. Increasing iteration/event limits must approach the same declared physical solution within its budget; body-order bias and silent exhaustion are failures.

## F-RAIL

**full response matrix**

Use every physical rail and jaw endpoint. Incidence angles are from the inward normal, not the rail tangent. Test speeds`.05,.2,1,3,8,14 m/s` and signed normalized sidespin ratios`R*omega_vertical/speed = -2,-1,-.5,0,.5,1,2`, plus draw/follow and supported ordinary elevations. Pure zero-speed spin is a separate case, avoiding division by zero.

Record incoming/outgoing 3 D velocity, angular velocity, contact location/normal, ball/slate impulses, slip, height and event time. Compare geometric clearance and a sourced/calibrated rail oracle, not an assumed perfect reflection law for all spin. Include rail-hugging, near-parallel, repeated 2/3-rail paths and cloth reattachment.

The Mathavan paper assumes limited cushion deformation and reports a normal-velocity validity limit for its conditions. Read the actual equations, parameter units, material and experimental setup before using its curves. High normal speeds require additional measured evidence; published restitution values are not universal pool constants. A discarded downward velocity is not a complete coupled cloth reaction.

## F-POCKET

**topology, outcome boundaries and visible lifecycle**

For each of six IDs, test corner/side dimensions, centerline approach, both jaw-first sides, rail-hugging entry, grazing miss, frozen hanging ball, slow roll-off, rattle/rejection, double-jaw, nearby moving ball, partial descent collision, valid re-entry and high-speed return toward the slate. Use all supported speeds and signed/composed spin for selected high-sensitivity cells. Start valid shots in supported free space; label intentionally invalid fault-injection states separately.

Scan lateral mouth position initially at 1 mm intervals and approach angle at 0.25 degrees; bracket classification changes to 0.1 mm/0.05 degrees. These scan steps locate a transition, not a claim about natural variability. Repeated physical trials define a transition band. Compare stable outcomes outside that band and the measured boundary inside it; preserve per-pocket/speed confusion matrices rather than a pooled success rate.

Sample before/at/after mouth, shelf/fall edge and capture surface. Establish the0.25mm rendered-state bound from world-space mesh/node transforms; use screenshots for projected visibility/occlusion rather than claiming subpixel millimeter metrology. Verify no capture acceleration, full collision availability during partial descent, and no pot produced by penetrating solid slate. Use the retained 8 m/s supported-bed counterexample. A 2D support projection is diagnostic; the oracle is actual 3 D solid/free-volume membership and the valid entry path. An already legitimately captured return may travel beneath the bed without creating another pot.

Record kinetic/gravitational/projection energy and liner work through rejection; compare refinement and restitution changes. Validate one irreversible capture, complete ball inventory and deterministic terminal storage. Capture all six entries/rejections in overhead/lounge unlit/collision-overlay/lit views. Track visibility, shadow, marking and retained pot identity through the entire state transition.

## F-NUMERIC

**refinement, metamorphism and long stress**

Fix physical initial states, profile and horizons; compare 240/480/960/1920 Hz or equivalent solver tolerances, then continue refinement where a result has not plateaued. Report every rung, event phase, direction and vector speed. Final high-quality and production-versus-reference requirements are separate. Coarse failures remain in the data even after a fine configuration passes. A finer run of the same flawed model is not a physical oracle.

Choose a reference whose own error is independently bounded; distinguish model error, numerical error and measurement error. Define per-contact distance/velocity/time tolerances from units and actual float precision at near/far coordinates. Counterexamples include the experimental 0.1 nm nudge disappearing under float32 rounding, accepting a separating near-contact, and reusing a squared-distance epsilon as a speed threshold.

Use mirror/rotation covariance with axial-spin transforms, quiet storage permutations and dense-contact ordering. Run render chunk schedules 30/60/120/144 Hz with equal fixed ticks, random chunk partitions and injected stalls. Compare canonical trajectories and semantic event sequences at matched times. Exact same-build replay is required; symmetric/permuted simultaneous event sequences may use declared equivalent tie groups without rewriting physical first-contact semantics.

Stress ladder: named regressions first;1000 development legal break seeds to actual settle;10000 release seeds; include adversarial frozen clusters and complete rack lifecycle. Track maximum transient/settled overlap, total energy ledger, finite states, conservation of 16 identities, termination, event-limit exhaustions and replay. Check exact repeated seeds and previously failing seeds in every candidate. Report confidence and corpus coverage; zero observed failures is not a universal proof. No forced timeout may masquerade as settling.

Run the same supported corpus on each advertised architecture/platform. Cross-platform divergence must be measured explicitly before claiming bitwise equality. Preserve source/engine/compiler precision settings and profile hashes.

## F-CALIBRATE

**acquisition, fitting and uncertainty**

Define identifiable real equipment and a reproducible launch setup. Record dimensions, masses, levelness, cloth condition, cue/tip/elevation and ambient conditions relevant to the model. Calibrate lens/perspective/distortion and spatial/time scale. Use marked-ball/high-speed acquisition sufficient for the required spin/impact resolution. Estimate occlusion/tracking/rolling-shutter error and independently retrack a subset.

Start with instrument-validation and 30-repeat pilot cells at representative conditions. A planned design selects parameter-identifying training families plus >=30% held-out entire cells/families before fitting. Increase repetitions for tail metrics: at least 100 held-out shots per reported family, and enough per critical cell to distinguish natural variation/measurement error from model residuals. Publish cell counts and confidence intervals; pooling cannot conceal a failed cell. This is a sampling floor, not an automatic precision guarantee.

Fit stagewise where identifiable: free rolling, sliding/spin, strike transfer, ball contacts, cushions, then pockets. Hold initial-state measurement errors apart from fit parameters. Report residuals over time, covariance/sensitivity and rejected model alternatives. Freeze a fitted profile before holdout evaluation; retuning restarts the evaluation with a newly preserved split.

Numeric calibration gates apply per named family with the uncertainty-adjusted decision rule. Near-zero velocities/spin use meaningful absolute bounds rather than huge relative percentages. For spin below 1 rad/s, use angular-speed absolute residual<=0.1 rad/s and report rotational phase; otherwise use catalog relative bounds. For each signed spin component, require the measured sign to match when its magnitude exceeds3 times its measurement U95; within that band report sign-indeterminate rather than asserting a reversal. Zero-spin fixtures also use the ideal numerical no-drift oracle. For draw/stun zero crossings, bracket reversal with uncertainty in speed/time instead of assigning an exact video-frame sign. If uncertainty, sample coverage or reference domain is inadequate, the gate remains not established. Competitor outcome matching and real-equipment calibration are separate datasets.

## F-FEEL

**complete interaction, placement and camera**

Publish a state-transition table for acquisition, adjustment, commitment, delivery, simulation, placement, pause and recovery. Execute each allowed and prohibited transition using real GUI/native input, including focus and zoom/resize changes around exact contact/capture times. Record the full loop rather than isolated method calls.

Prototype competing interaction designs with identical physics and frozen power mapping. For tactile-strength trials, hide numeric readouts and randomize soft/medium/hard deliveries; record recognition per class and user, not one total. For placement, compare preview/confirm against independent sphere/solid queries and require non-color cues. For camera, ensure target visibility and stable picking at every transition; verify reduced-motion mode separately.

## F-VISUAL

**fixed deck plus motion and recognition**

Render actual framebuffer profiles 1600×900,1920×1080 and the supported minimum window/Retina settings. Record logical window, design viewport, render texture, OS scaling, letterbox and pixel ratio separately. A UI design-unit value is not an OS coordinate point or a typographic point; convert using the actual transform. VIS-008 measures the rendered nominal em extent in OS logical coordinate units and records glyph cap height too. It does not equate a Godot font-size number with native typographic points or claim a universal physical-inch font size. Use the same geometry/physics in all art alternatives.

Fixed scenes: rack; all 15 balls in a spread; black 8 beside dark rail;6/7 on green cloth; stripes with caps turned away; white ball beneath a highlight; dense cluster under ghost guide; each pocket center and jaw; slow falling ball; cue near a rail/ball; placement preview; paused delivery; minimum-size long status text. Show unlit topology, collision overlay, roughness/normal views and final exposure.

Record >=60 s adversarial real-time motion: slow diagonal rolling and pure rotation, cuts, break, pocket rattle/entry, camera/zoom transition, guide on/off, undo/reset. Inspect at normal speed and slow motion, including temporal aliasing and shadow detachment. Fixed-FPS movie exports are supplementary visual evidence only.

Recognition protocol: randomized trials for each of 15 identities, both groups, ball-versus-guide identity and actual shot target across views/rotations/contexts. Report accuracy per ball/group/view and experience stratum as well as overall; each required reported stratum must meet the target, with denominator and uncertainty. An identification aid may reveal a physically hidden number but cannot change simulated orientation.

Compare three original art-direction keyframes and one vertical slice before the complete asset pass. Rate cloth, wood, rubber/facing, resin, lining and cue separately. Material richness, geometry correctness, identity and motion stability each need evidence; a bright material is not automatically realistic or useful. Perform contrast/focus/target-bounds checks after final scaling, including letterboxing and native UI behavior.

## F-AUDIO

**audible references, event integrity and instrumented timing**

Acquire a legitimate, identified continuous gameplay reference with actual effects, separate from trailer music/voiceover. Listen directly before assigning sound qualities. Our four WAVs, synthesis or waveform statistics cannot prove competitor parity. Keep source/license/provenance with any adopted asset. Capture on built-in speakers and wired headphones; wireless modes have separate declared timing budgets.

For every event material, record at least 9 log-spaced impulse/energy levels with repeated variants; compare perceived intensity ordering and objective loudness/envelope measures. Timbre has multiple dimensions, not a scalar monotonic ordering: specify spectrum/attack/decay targets and listen for natural material identity separately. Review soft-shot audibility, hard-break headroom, repetition fatigue, panning, camera changes and mute.

Dense-event test has two parts: (a) lossless contact identity/event scheduling audit under 100 distinct contacts/100 ms, with documented priority/voice/coalescing decisions; (b) actual listening to physically plausible break scenes for useful contact texture and salient cue/rail/pocket identity. Do not demand that listeners resolve 100 individual simultaneous clicks. Numerical duplicates and unrelated true impacts are different inputs.

Measure final mixed true peak using a documented true-peak/oversampled method, not only stored sample peaks. Test worst-case overlap and active voice stealing; use fades or an equivalently click-free transition. Mute may use a de-click ramp<=10 ms; after that digital output must be zero, including queued/tail voices. No late unmute burst is allowed.

Audio/display uncertainty<=5 ms cannot be inferred from a 30/60 Hz screen recording alone. Use a calibrated high-speed camera/photodiode for actual display light and a synchronized microphone for the acoustic speaker path or electrical loopback for the wired signal path. State which path was measured, microphone distance/sound propagation, capture clock alignment and instrument uncertainty. Repeated engine callbacks establish scheduling only. Test cue/ball/rail/pocket onsets,100 repeated events per condition, long-run drift and frame-rate changes. If suitable capture hardware is unavailable, audio/display synchronization remains BLOCKED rather than guessed.

## F-LIFECYCLE

**restoration and sustained use**

Round-trip valid settled v 1 data and future versioned profiles; reject wrong versions/types, fractional/duplicate IDs, impossible phases/heights, moving/spinning settled snapshots, overlap, invalid pocket IDs, extreme finite/nonfinite values and truncated JSON. Failures leave live state and the last good file unchanged. Simulate buffered write failure/flush/rename failure with a controlled test seam.

Save before/through/after delivery, impact, multiple pots, scratch, pause and close; restore in a fresh process and replay. Snapshot balls, counters, geometry/cue profile and simulation/event state must describe one checkpoint. Undo and repeat compare full state/trajectory/event hashes, not only positions.

Run 10000 headless lifecycle cycles plus a 2-hour interactive soak. Capture RSS, live nodes/resources/voices over time after cache warmup; compare idle plateaus and distinguish allocator high-water marks from growing retained objects. Resolve the existing aim-test teardown warnings with lifecycle evidence before final signoff. Device/focus/resize interruptions also belong to packaged tests.

## F-PERFORMANCE

**release process, clocks and repeatability**

Measure the real exported/installed app, fixed artifact hash, release configuration and declared OS/device/renderer/framebuffer/scaling/refresh. Baseline is Apple M4/macOS Metal at actual 1600×900 and 1920×1080 framebuffer 60 Hz; supported Retina modes are additional measured profiles. Record power/thermal state and background workload. Cold start/loading and steady play are separate conditions.

After a declared warmup, collect 60 s each idle, ordinary shots, soft spin/settle and hard breaks. Repeat at least 3 times, including a warm/thermally sustained session. Record simulation, render CPU, GPU and presentation timelines. Critical-path work accounts for overlap; adding CPU and GPU durations blindly can double-count. Conversely average simulation throughput cannot certify tail-frame performance.

At nominal refresh period `T=1000/refresh_hz` ms, record actual presentation timestamps and deadline misses. The authoritative formulas are PER-002/003: work p95<=min(12 ms,0.72*T), p99<=T; presentation interval p95<=T+0.5 ms, p99<=1.5*T; intervals>2*T occur in<0.1% of scored frames. Use timestamps with U95<=0.1 ms. Apply uncertainty to bound classification conservatively and report borderline interval counts; never use rounded display values to decide exact-boundary membership.

Illustrative budgets (use the formulas, not rounded values, in code):

| Refresh | Work p95 / p99 (ms) | Presentation p95 / p99 (ms) | Long interval threshold (ms) |
|---|---|---|---|
|60Hz|12 /16.666…|17.166… /25|>33.333…|
|90Hz|8 /11.111…|11.611… /16.666…|>22.222…|
|120Hz|6 /8.333…|8.833… /12.5|>16.666…|

Only60Hz baseline profiles are mandatory here;90/120Hz are explicit conditional profiles and cannot be advertised from a render-chunk simulation test. Report worst repeat/profile, counts, warmup/exclusions and clock uncertainty. Work deadline and visible presentation spacing are separate metrics, clarifying the older ambiguous16.7ms frame target without claiming a fixed-FPS export is a real-time trace.

Inject 50/100/500 ms stalls, large contact bursts and resize/device changes. Validate bounded catch-up policy against equal simulated ticks and log every limit fallback. Frame-work budgets cannot be met by silently skipping physical time. Track resource/performance budgets per vertical slice and investigate any unexplained >5% regression on matched runs.

Install/launch the actual packaged artifact and execute delicate tap, straight pot, thin cut, rail response, full break, scratch/placement, undo, pause and save-resume. Package startup, source tests and an external-source-script invocation are separate results. If the external-script probe hangs, preserve it as a failed/unestablished probe; use genuine packaged interaction evidence instead of re-labelling startup as coverage.

## F-PERCEPTION

**high bar without invented certainty**

Use an 8-person formative pilot with balanced novice/experienced representation to select prototypes and find defects. Final comparative study has at least 20 independent participants (at least 10 experienced and 10 novices), repeated tasks, counterbalanced order and frozen familiarization. This is a floor, not an automatic statistical power claim.

Anchor ratings:1 broken/incoherent;2 prototype/unstable;3 functional but visibly rough;4 convincing/coherent;5 polished reference-level execution. Evaluate clarity, control precision, physical plausibility, responsiveness, visual finish and sound naturalness separately. Each axis must meet its catalog threshold, each expertise stratum is reported, and reproducible severe defects remain blockers regardless of average scores. Owner acceptance is recorded separately.

Pre-register tasks, references, cue/equipment/settings, exclusion rules, participant-level paired estimator, confidence-interval method, noninferiority margin and recruitment/precision plan. Repeated shots from one person are not independent participants. For the proposed 0.5/5 margin, the paired 95% lower confidence bound for candidate-minus-reference must exceed -0.5 on **every** required axis; if inconclusive, report it or recruit under the predeclared plan. Do not keep sampling only until a favorable result appears. Do not claim population-wide parity from an underpowered pilot.

References must include an identified current Miniclip build and another legitimate accessible reference chosen for the intended fidelity/presentation axis. Match tasks/input/device where possible; otherwise report platform effects. Edited support animations are leads, not the full comparative dataset. Sound must be heard; motion must be viewed; actual interaction must be performed.

## Existing command inventory and planned coverage

Current commands run from the repository root:

```sh
bash tools/godot.sh --headless --path . --script tests/run.gd
bash tools/godot.sh --headless --path . --script tests/quality_contract.gd
bash tools/godot.sh --headless --path . --script tests/aim_controls.gd
bash tools/godot.sh --headless --path . --script tests/stroke_power.gd
bash tools/godot.sh --headless --path . --script tests/stroke_contact.gd
bash tools/godot.sh --headless --path . --script tests/spin_precision.gd
bash tools/godot.sh --headless --path . --script tests/save_recovery.gd
bash tools/godot.sh --headless --path . --script tests/table_geometry.gd
bash tools/godot.sh --headless --path . --script tests/pocket_support.gd
bash tools/godot.sh --headless --path . --script tests/pocket_matrix.gd
bash tools/godot.sh --headless --path . --script tests/visual_geometry.gd
bash tools/godot.sh --path . --script tests/render_contact.gd
```

Measurement commands preserve named output directories. The strict checker currently retains failures:

```sh
bash tools/godot.sh --headless --path . --script tests/physics_precision.gd -- --output-dir=res://docs/quality-roadmap/reports/physics-precision/new-candidate --enforce
bash tools/godot.sh --headless --path . --script tests/physics_precision.gd -- --stepper=res://tests/experiments/impact_stepper.gd --output-dir=res://docs/quality-roadmap/reports/physics-precision/new-experiment --enforce
```

These scripts cover only portions of the new families. Current pocket-matrix stress is 20 short seeds, not the required 1000/10000 settled ladder. Current render-contact evidence excludes native/display/audio latency. The impact prototype is not active gameplay. Implement missing checks as bounded slices and register exact commands when they exist; this document does not invent a complete acceptance-runner CLI.

Suggested evidence layout (not yet an implemented runner):

```text
reports/acceptance/<candidate-id>/
  manifest.json                 # source/profile/artifact/device/oracle identity
  ledger.json                   # requirement ID -> result + artifacts + uncertainty
  fixtures/                    # immutable reproducible inputs and splits
  traces/                      # physics/events/presentation/input/audio
  plots/                       # errors, power/travel, response/acceptance maps
  captures/                    # original visual/audio evidence, licensed access
  counterexamples/             # all failed seeds and discriminating cases
  reviews/                     # independent numeric, visual, listening, owner
```

Initialize a full result ledger without inventing passed coverage:

```sh
python3 docs/quality-roadmap/tools/render_targets.py --check --init-ledger reports/acceptance/candidate-id/ledger.json
```

The path is relative to the repository working directory. The utility refuses to overwrite an existing ledger; its structural validation does not judge scientific or perceptual evidence. Fill source/profile/artifact identity and each result field from the actual run.

Raw large media may live outside Git with verified hashes and durable access instructions. Ensure references remain reproducible; `/tmp` alone is not a release evidence archive. Every planned test needs a named implementer and requirement mapping before it is counted as coverage.

## Prospective participant and perceptual procedure

These parameters are proposed product study requirements, not a statement that participants, instruments or a comparator are currently available. Freeze the exact registration and immutable stimuli before scored collection. A protocol change after viewing scored outcomes creates a new retained study, not retroactive acceptance.

**Participants and task sessions.** Define experienced as at least2 years of regular cue-sport play and at least monthly play during the past6 months, with a recorded repertoire qualification; novices have fewer than10 lifetime hours and no regular play. Record intermediate/other cohorts separately. This is a sampling definition, not a ranking of people. Use anonymous participant IDs; score expertise groups separately. Provide a fixed15-minute familiarization and20 unscored target trials; then use identical preregistered scored tasks, randomized/counterbalanced within matched blocks. Sessions last<=45 minutes, with a break at least every15 minutes and additional sessions where needed. Retain fatigue, missed and canceled trials.

**Scored timing and retries.** Acquisition time starts when the stable ready stimulus and target appear and ends at committed selection; it excludes authored cue delivery.10-second acquisition timeout is a recorded failure, not a missing trial. Record all retries/cancels; only the first committed attempt is scored for endpoint success. Separate technical failures under a frozen exclusion rule, with every exclusion retained. Do not silently repeat missed shots until one succeeds.

**Learning/reproducibility blocks.** For each preregistered landing/control family, B1 and B2 contain at least20 scored attempts at identical randomized targets/settings after familiarization. Distance blocks use50/100/200/500/1000mm targets balanced equally; qualify follow/draw/rail families separately. A short landing succeeds within10mm of the50–200mm target; long landing succeeds within4% of the500–1000mm target. These trial-level windows supplement, not replace, the stricter PWR median-error requirements. Aim acquisition success uses the AIM angular bound. Error is endpoint distance divided by target travel for cross-distance normalized analysis; retain the raw mm error too.

Use each participant's B1/B2 success rate, normalized absolute-error median and normalized-error variance. Paired population intervals are participant-clustered; also show expertise strata and per-family results. HUM-005 gates apply to matched blocks: success lower bound>=-0.05, median normalized-error degradation upper bound<=0.01, variance-ratio upper bound<=1.25. A B1 error variance<=1e-6 is treated as degenerate: use an upper bound of1e-6 on B2 variance rather than dividing by nearly zero. Methods/CI estimators and the planned recruitment/precision ladder are frozen before scoring. An unexplained consistent spin/rail sign mismatch is a separate defect regardless of these aggregate results.

**Identity deck.** Final recognition studies use the final-panel minimum20 participants, including10 per expertise group. Per participant, show each of15 numbered balls10 times in each of the two supported camera views, with balanced stationary/moving, rail/cloth, stripe orientation and guide contexts. Freeze the exact randomized deck beforehand. Primary gating strata are ball identity×view×expertise (>=100 observations per stratum), and difficult context×view×expertise (>=100); report less-populated interactions descriptively and investigate severe failures. Use a separate balanced actual-ball/guide-ghost deck with>=100 observations per class×view×expertise. Include cue/group identification too. Stimulus duration2seconds, response timeout3seconds; no response counts incorrect. If a declared accessible identification aid is part of the production UI, test it as shipped and label the mode.

The >=95% identity/ghost requirements are **descriptive sample gates** on these frozen primary strata; report participant-clustered95% uncertainty and never relabel them as an established population lower bound of95%. Additional trials/recruitment follow only the predeclared precision plan. A failing stratum cannot be removed from the deck. Material/quality ratings and the stricter HUM noninferiority confidence-bound decision remain separate.

**Strength and material deck.** For FEL tactile strength, collect at least10 randomized judgments per soft/medium/hard class per participant and modality, hiding numeric readouts; gate descriptive accuracy>=90% per class and expertise group. For audio, provide9 intensity levels and at least5 independently chosen variants/repetitions per level/class, counterbalance adjacent-level comparisons and record confusion. AUD-003 monotonicity is tested on the median perceived intensity and the declared objective loudness metric across these repeated levels, with uncertainty; a higher spectral centroid is not itself higher naturalness. Naturalness/material scores use the anchored per-class rating gate. Cosmetic variants do not become independent human participants.

**Playback conditions and soft-contact detection.** Freeze output device, settings, normalization policy and listener position. For a speaker baseline, a declared500Hz–2kHz pink-noise calibration signal at-20dBFS RMS produces65±2dBA LAeq over10seconds at the listening position, with ambient<=35dBA and processing/AGC state recorded. These are product test conditions, not a universal mixing standard. For headphones use a calibrated coupler/reference level when claiming an absolute acoustic level; otherwise relative listening can proceed but absolute-level audibility remains unestablished. Per device, use at least20 randomized soft-contact/silence judgments per participant, balanced10/10; contact detection>=90% and silence false positives<=5% in each expertise group. Report actual digital levels, noise floor and uncertainty. All other mix/peak/headroom and naturalness gates still apply.
