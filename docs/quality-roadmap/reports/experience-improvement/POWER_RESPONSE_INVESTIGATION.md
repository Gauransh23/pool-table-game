# Package C investigation and bounded atlas brief

2026-11-06. Read-only investigation of baseline `98287008b8d5286d78a4e0e6bb68d56b3f5b7d5e`. No production source, coefficients, thresholds, save semantics, export, or solver selection changed. No branch, worktree, commit or subagent created. Read AGENTS.md, QUALITY_TARGETS.md, relevant generated PWR/CUE/CLT targets, TEST_PROTOCOLS.md, NEXT_CHECKPOINT.md and active source. Concurrent package A changes are outside this report; they were not measured as a completed dependency.

**Recommendation:** implement and review an atlas against the frozen current mapping first. Preserve the measured resolution failures. Do not choose or install a replacement curve before matched interaction/repeatability data supports it. Nonlinearity itself is not a defect, and strictly increasing mathematical response does not establish useful machine resolution or human control.

## Current path and supported inputs

`scripts/ui/game_hud.gd` creates an HSlider with min 0, max 1, step .005: exactly 201 authored states including zero. Default .42 is reachable. The readout displays one decimal percent. HUD shooting emits only when power >0, but the controller is the finite/boundary authority. Programmatic controller calls can supply continuous powers; do not confuse this superset with reachable slider quanta.

`SpinPad` accepts a continuous pointer domain within radius .5. Keys move by .025 or .005 with Shift, then radially clamp. Shift pointer motion uses relative deltas scaled by .2/radius. Positive x selects screen right, positive y screen up. Cardinal and diagonal settings can be reached; enumerating all pointer-selected spins is impossible. The physical maximum uses `.5 + 1e-6` tolerance, whereas UI radial clamping uses .5. Capture requested and actual clamped offsets separately.

`GameController._on_shoot_requested` rejects motion/pending/placement/menu requests; derives cue speed; rejects nonpositive output, nonfinite spin and excessive radius; freezes shot direction, cue speed and spin in the contact closure. The actual visible stroke callback calls `CueStrikeModel.apply` once, increments stroke count, marks motion and plays cue sound. Preview uses a duplicate ball. Actual controller strikes always use elevation zero. Direct model support up to a clamped 65 degrees is not ordinary-elevation gameplay support or physical validation.

`StrokePower.cue_speed(p)` is zero for nonfinite or p<=0. Positive p maps to `.075 + 7.925*min(p,1)^2` m/s. Positive out-of-range controller requests therefore clamp to 8 m/s; negative/nonfinite requests do not animate. There is an intentional discontinuity at zero: the continuous right limit is .075 m/s, while the smallest slider input .005 is .075198125 m/s. Derivatives on the positive branch are 15.85p and 15.85, in cue-speed units. The declared maximum is cue speed, not launch speed, impulse, force or ball energy.

`CueStrikeModel` uses mass .52 kg, ball mass .168 kg, efficiency .87 and effective end mass .008 kg. For offset radius rho, D=1+m_ball/m_cue+2.5*rho²; launch scalar is v_cue*(1+sqrt(1-D*(1-efficiency)/(m_ball/m_cue)))/D. A negative discriminant is rejected as a miscue. Contact arm is built from lateral/up offsets on the sphere and impulse is deflected by a signed end-mass squirt angle. Rotation is contact_arm cross impulse divided by I=.4*m*R². Side offset therefore changes both launch direction and spin. Equal power does not promise equal launch speed across offsets. In a rightward level shot, positive top generates negative wz (follow), negative top positive wz (draw), positive side positive wy plus a negative planar deflection.

Direct-model caveats for an atlas: apply() does not fully reject nonfinite cue speed/direction/offset/elevation, clamps elevation silently, and adds an impulse to an already moving ball without a qualified relative-motion strike model. Controller checks cover some, not all, direct-call cases. These are explicit unsupported/invalid boundary probes, not permission to change model behavior in an instrumentation slice. Restrict qualified strike fixtures to resting balls, finite values and declared elevation. A direct-model malformed-input outcome must not be relabelled a controller failure.

## Cloth, contact, readiness and visual delivery

Active gameplay and current tests preload `scripts/sim/physics_stepper.gd`, not the impact experiment. Default fixed step is 1/480 s; sliding friction .19, rolling resistance .012, spinning friction .0127, gravity 9.81. The stepper uses speed-dependent substeps and up to six overlap-contact passes per substep. This is a measured active model, not calibrated physical truth.

Contact slip is `(vx+R*wz, vz-R*wx)` in planar coordinates. Above .0005 m/s slip, capped Coulomb impulse reduces slip, without splitting position integration exactly at the rolling transition. Below it, rolling resistance reduces speed and sets the horizontal spin to exact rolling. Position integration uses the updated velocity. Vertical-axis spin decays by constant angular deceleration `5*mu_spin*g/(2R)` in either regime. Sleep zeros velocity/spin only when both speed<.012 and angular speed<.08 and phase is IN_PLAY. Readiness uses > thresholds, so equality deserves a boundary probe. For pure rolling the spin cutoff implies speed about .002286 m/s, with an ideal remaining tail about .0222 mm. Do not claim the velocity-only .612 mm example is the active compound cutoff. Side spin may delay readiness after translation becomes negligible.

A single transition tick is only a sampled detection with 1/480 s resolution; it is not an exact transition root. Slip can recross a threshold. Record all regime changes and first/last stable transition, rather than claiming first sampled low slip proves an analytic transition. Endpoint displacement differs from accumulated path length, especially for draw/contact/curved shots. Free draw need not reverse: cue-object contact is normally needed for the useful draw-return task.

Ball and rail events expose kind, fixed tick, speed and planar position (plus identities/jaw). They do not expose impulse, contact normal, root time or substep index. Drain every tick to bound memory. Do not invent substep timing or infer exact tangential impulse from an event speed. Atlas contact outcomes can report observed events, pre/post tick states and uncertainty. Full impulse/contact-limit diagnostics need a separately reviewed observer seam; an instrumentation-only atlas must explicitly mark them unavailable.

The visible cue stroke has displacement `.008+.075*p`, then another .008 m backswing and a .075 s quadratic ease-in delivery. Its authored endpoint speed is `2*(.016+.075*p)/.075` m/s: approximately .437 m/s at .5% and 2.427 m/s at 100%, versus commanded .0752 and 8 m/s. This source-derived mismatch is relevant to CUE-004 and requires later delivery work. It is not measured high-speed screen evidence or a reason to silently tune the power curve. Callback/visible contact synchronization has existing tests.

## Completed exploratory measurement

Command: `bash tools/godot.sh --headless --path . --script /tmp/pool-task-c-probe.gd` from the repository root. Executed once, before interruption; no measurements repeated on resume. Godot `4.7.2.stable.official.ed1daf0bf`. The harness and unchanged raw JSON are now preserved in `task-c-evidence/probe.gd` and `task-c-evidence/results.json` beside this report. Original `/tmp` files remain. This is exploratory active-model evidence, not final controller-routed or independently qualified acceptance evidence.

249 shots: every center input tick 0..200 times .005, plus ticks 1/10/20/40/80/120/160/200 at offsets `(0,+.45),(0,-.45),(+.45,0),(-.45,0),(+.318198,+.318198),(-.318198,-.318198)`. Every start is a resting ball at origin, direction RIGHT, elevation zero; default profile; table half-size 10000 m to avoid all rails/pockets. Direct strike and stepper calls bypass controller/visual delivery. At most 40000 fixed ticks per shot; every shot actually settled before the cap. No event/trajectory capture, path integration or energy audit was performed by this probe. Transition distance is first sampled slip<=.0005, not independent roll distance.

Measured engine-loop wall time 19519.448 ms (printed completion 19520.96 ms includes the output write); 2346967 fixed ticks, including 2078244 for the 201 center cases. This is local headless throughput, not native frame performance. About .00832 ms/tick for this one-ball workload; larger contact cases have different cost.

| Center input | Cue m/s | Ball launch m/s | Endpoint distance m | Settle s | Next .5% distance gap |
|---|---:|---:|---:|---:|---:|
|0.5%|.075198125|.095701620|.021070395|.579167|.325721 mm|
|1%|.0757925|.096458070|.021396115|.583333|.551205 mm|
|5%|.0948125|.120664053|.033344980|.733333|3.109921 mm|
|10%|.15425|.196307763|.088515289|1.204167|9.645380 mm|
|15%|.2533125|.322380632|.238657698|1.987500|23.262456 mm|
|20%|.392|.498882622|.571731269|3.085417|48.171401 mm|
|25%|.5703125|.725813746|1.210707068|4.497917|86.588025 mm|
|40%|1.343|1.709182024|6.713212967|10.614583|.322796 m|
|50%|2.05625|2.616906643|15.740303993|16.262500|.616715 m|
|75%|4.5328125|5.768728256|76.470268250|35.864583|2.026169 m|
|99.5%|7.920948125|10.080672264|233.632583618|62.704167|4.689270 m|
|100%|8|10.181278229|238.321853638|63.331250|n/a|

All 201 center endpoints are strictly increasing; all launch speeds increase. Minimum useful center distance is 21.070395 mm, inside current PWR-002's 10–30 mm bound. The zero-to-first-step 21 mm jump is explicit. Large free-flight endpoints describe an oversized diagnostic fixture, not practical table travel or break quality. High-range step gaps are useful atlas data but are not themselves a failed short-landing requirement. Contacts and multi-rail outcomes can vary categorically with power.

| Target mm | Nearest percent | Actual mm | Signed error mm | PWR-003 bound mm | Exploratory result |
|---:|---:|---:|---:|---:|---|
|50|7|48.142798|-1.857202|2|within bound|
|100|10.5|98.160669|-1.839331|2|within bound|
|200|14|197.363764|-2.636236|2|outside bound|
|500|19|485.033333|-14.966667|5|outside bound|
|1000|23.5|977.789104|-22.210896|10|outside bound|

Of 27 adjacent center pairs with both endpoints within 20–200 mm, 21 exceed the <=2 mm gap target. Worst is 13.5→14%, 179.134101→197.363764 mm, gap 18.229663 mm. These are concrete current-model PWR-003 counterexamples. They are not proof that a different mapping improves human performance or real-table accuracy.

At minimum power, +.45 follow travels 17.690707 mm and -.45 draw 3.349255 mm; signed .45 side travels 8.855051 mm with mirrored endpoints `(8.847299,∓.370451)` mm. Launch speed for all cardinal .45 offsets is .062224694 m/s versus center .095701620. At full power, cardinal .45 launch speed is 6.619813442 m/s; free follow endpoint 200.578613 m, draw 38.657593 m, side 100.729698 m. These differences are expected consequences of the declared off-center model; the center minimum target must not be misapplied to every spin family. Signed side outputs mirrored in this scout. Combined offsets are present in raw data, but the probe is not a full eight-azimuth/radius/elevation grid.

### Existing test gaps quantified

`tests/stroke_power.gd` samples 39 distinct settings: zero, all 20 nonzero states through 10%, then 5-percentage-point anchors through 100%. It omits 162 of the 201 reachable states (80.6%). In 10.5–100%, it tests only 18 of 180 states, omitting 90%; the 200/500/1000mm nearest settings above are absent. It does not test <=2mm adjacent gaps or nearest target landing. Its monotonicity requirement merely checks positive endpoint differences, so it cannot fail on the measured 18mm local gap. Its old minimum acceptance is 20–100mm; the authoritative target is now 10–30mm. Preserve the historical measurement/report and its original bounds; add a new independently mapped atlas rather than rewriting history as higher-bar acceptance. The suite's automatic CSV destination is a shared historical path, so do not rerun it casually during an evidence-only task.

`tests/run.gd` covers strike signs, one off-center effective-mass expression, squirt, 204 energy-grid cases at speeds .5/3/8, elevations 0/15/40/65 and center/16 rim azimuths, spin decay and 12 ordinary-shot settling cases. These are useful regressions, but copied strike expressions are not independent physical validation, and 15/40/65 does not cover ordinary 2/5/10-degree stance. `tests/spin_precision.gd` has six UI adjustment assertions, not physical spin/cloth calibration. `tests/stroke_contact.gd` already provides a real scene, isolated session file, process suspension and actual cue callback checks; reuse that pattern for controller-routed launch snapshots. None was rerun by this investigation.

## Independent expectations and scope of claims

1. Freeze a reference profile and explicitly separate ideal analytical fixtures from active profile outcomes. Never tune cloth to improve input resolution.
2. For level uniform solid sphere sliding, independently derive u0 from the initial contact velocity, t_slide=2*|u0|/(7*mu_s*g), v_roll=v0-(2/7)*u0, and vector x_slide=v0*t_slide-.5*mu_s*g*unit(u0)*t_slide². Follow with constant rolling resistance: stop time |v_roll|/(mu_r*g), distance |v_roll|²/(2*mu_r*g) along v_roll. Degenerate zero slip bypasses sliding; zero speed makes direction undefined. Reversed/composed slip requires vector equations. This oracle has assumptions and does not certify real cloth.
3. Separately test ideal pure rolling at speeds .01/.05/.2/1/3/8/14 with appropriate no-contact space, exact no-slip initial spin and analytic trajectories. Keep physical ball-speed sampling distinct from selectable cue-speed sampling. Use absolute errors near zero, as specified in TEST_PROTOCOLS.
4. Audit strike energy independently: translational plus rotational gain <=.5*m_cue*v_cue² plus prescribed max(1e-9 J,1e-6*input energy). Record impulse as m*(v_after-v_before) for the cue event only, and torque consistency with recorded contact arm; do not assert all incoming cue momentum transfers to the ball. A symbolic reimplementation of the same launch formula is regression evidence, not an independent experiment.
5. Compare mirrors using axial spin transformation, not a naive identical-sign angular vector. Side spin does not imply steady lateral drift on an ideal level isotropic cloth. Squirt is initial deflection; later curvature is a separate effect. No calibrated launch/spin/cloth measurements were acquired here, so CUE-003, CLT-004/007 and ordinary stance fidelity remain unestablished.
6. Qualification remains separate from measurement: the current slide integrator and .0005 switch can miss 0.1% analytic goals. Preserve such failures rather than substituting its own output as oracle. Full-power long travel also accumulates float32 Vector2 position error; precision metadata and convergence checks matter.

## Exact next bounded implementation: C0 atlas, no mapping change

**Prerequisite:** reviewed package A fixture/identity/error-handling infrastructure. Keep the active physics implementation, coefficients, controller semantics, save/export files, old reports and thresholds untouched. Owners: new `tests/power_response_atlas.gd`, a narrowly scoped `tests/measurement/power_atlas_*.gd` helper if needed, atlas fixtures, and a new report directory. Reuse A's identity/serialization primitives only after review. Its current `shot_fixture.gd` schema is a settled 16-ball normal-table start, power>0, <=9600 ticks and required nonempty contact expectation; it cannot honestly represent zero shots, 63s free settling or an oversized no-contact table. Add a separate versioned atlas schema with explicit geometry/termination, rather than silently broadening A's validator or pretending all cases expect contacts. Current A trace stepper uses default-config clock multiplication and a 30000-row cap; full center maximum is 30399 ticks, so allocate/stream correctly and record actual elapsed time. Avoid copying these limitations.

**C0 inputs and fixed counts:**

- Free motion: all 201 UI powers × five tips `{center,(0,+.45),(0,-.45),(+.45,0),(-.45,0)}` =1005 cases, level stationary ball, wide no-contact fixture. Power zero is an explicit no-op case for each tip. Record actual HUD assignment/readback for every power. Route all 201 center launches through the actual HUD/controller/contact callback in an isolated scene with automatic processing disabled, capture their committed launch state, then run that state headlessly to settle on the diagnostic table. Signed-spin direct-model runs must have controller-linked launch equivalence probes at eight power anchors; label provenance for each row. If routing all center callbacks is too expensive, retain the missing controller scope explicitly rather than claim PWR-002 controller coverage.
- Cheap launch-only strike matrix: cue speeds `{0,.05,.1,.2,.5,1,2,4,6,8}`, center plus radii `.1,.25,.45,.49,.50` at eight azimuths =41 tips, level elevation: 410 launches. Add just-outside radius .50001 at eight azimuths and nonfinite/negative/out-of-range power/controller cases as distinct expected-rejection probes. Ordinary elevations 2/5/10 are a declared future extension, not gameplay coverage. Test direct model versus controller handling separately.
- Rail response: normal table, launch toward top straight rail from cue center `(0,.30)`, headings `{30,60,90}` degrees measured from +x (incidence 60/30/0 from inward normal), powers `{.10,.25,1}`, tips `{center,+.45 side,-.45 side,(0,-.45)}`: 36 cases. Simulate to fixed 2s horizon or earlier terminal capture, retain no-contact results honestly. For each fixture store actual geometry and first-event classification; no forced eventual rail at low power.
- Cue-object response: cue `(-.25,.20)`, object `(.25,.20)`, rightward aim, powers `{.10,.25,1}`, tips `{center,(0,+.45),(0,-.45),+.45 side,-.45 side}`, plus center object distances `.10/.50/1.00m` (cue position adjusted, normal table): 45 cases. The .50m case is not duplicated under a second identity. Default restitution/friction; record contact presence, first-contact speed/time, object launch/postcontact speed, cue signed travel after contact, follow/draw/stun classification and final phases. Two-second fixed windows suffice for the initial atlas; endpoint-to-rest is qualified only for cases that actually settle, otherwise explicitly horizon-limited. Full settling contact repertoire can follow.
- Launch-only boundary/invalid fixture tests include zero direction, moving ball and nonfinite direct-model arguments as recorded unsupported behavior. Harness validation rejects malformed fixtures before runtime. Do not add production rejection logic in C0.

The contact lists are scouts, not full cut/rail/pocket-domain acceptance. Exact normal-rail and contact geometry must be validated before execution; a slow or deflected shot missing its object/rail is a useful outcome, not a harness pass for contact response. Store required/not-required event policies separately.

**Schema:** manifest `schema="long-rail-power-atlas/1"`, run_id, fixture schema/hash, requirement IDs, baseline HEAD and dirty summary, loaded source path+SHA256 map (including transitive ball/config/table/strike/power/UI/controller and observer scripts), mapping identity `floor-quadratic-v1`, complete runtime profile values/hash, engine version/build, OS/architecture, single/double engine scalar and Vector2/Vector3 precision, units, RNG policy (active seedless; cosmetic excluded), oracle identity/assumptions, CLI/options, instrument clock, time budgets and started/completed status. Do not call a constant `active-default` string a physical profile hash.

Per fixture: stable id/family/domain, power tick plus requested/readback/committed floats, modality/provenance, direction/offset/elevation, geometry/profile overrides, full canonical initial states, termination policy and cap, oracle bounds and event expectations. Per result: status/reason, full launch/terminal states, cue/ball velocity vectors, spin/energy/impulse units, path length and signed net displacement, sampled slip/phase regimes, first/stable roll timing intervals and distance intervals, translation-rest/spin-rest/controller-readiness times separately, event stream with declared tick-time uncertainty, actual tick/substep availability, elapsed simulation/wall work, cap/observer overflow/finite diagnostics, repeat hashes and raw artifact hashes. Null+reason for unsupported impulse/contact-root fields; never zero-fill missing measurements.

Stream raw JSONL (or bounded chunk files) before summaries; preserve full per-tick trajectory for named transition/contact/low-end counterexamples and decimate other plots only after retaining raw evidence. Artifact writes must fail loudly, including flush/close errors. Use a unique output directory and manifest incomplete marker; interruption cannot overwrite a baseline. Reject empty/duplicate/malformed/nonfinite fixture sets and wrong profile identity. A threshold FAIL is a valid completed measurement and must remain in raw data; a harness error invalidates the affected run.

**Derived outputs:** full-range cue/ball-speed/spin plots; zoomed 0–200mm power-distance plot; nearest-machine target table at 50/100/200/500/1000mm; adjacent outcome gaps and finite-difference local slopes per .5%; soft-band useful-state count; travel/time/slide-versus-roll breakdown; signed-spin comparisons; rail/contact categorical maps; no-contact and horizon-limit counts; PWR/CUE/CLT scope ledger. Every result distinguishes model measurement, analytic comparison and human evidence. No global green label from pure monotonicity.

**Independent checks and exit evidence:**

- Freeze the default mapping/profile values above as reference identity, not a copied formula as outcome oracle. Check zero/no commit, min/full launch, monotone center launch, finite values and deterministic exact same-build repeat snapshots/events for center ticks 1/20/40/200 and representative signed spin/contact cases.
- Retain the current 200/500/1000mm misses and 21 gap violations as expected red product findings unless source identity changed. A test of report correctness should assert their correct classification; it must not redefine PWR-003 to pass. Supply separate exit codes or strict mode so a complete atlas with product FAIL rows is distinguishable from malformed/incomplete harness output.
- Include the independent cloth worked examples and energy ledger with source assumptions. Report any analytic/model discrepancy at original thresholds. Do not require high-power contact endpoints to be monotone through changing physical outcomes.
- Run the new atlas twice only if a determinism check needs it; otherwise replay a small named subset. Validate malformed-output/empty-run/write-failure behavior and source hash capture. Run relevant existing controller/spin/save regressions with isolated outputs; do not overwrite old measurement reports. Complete `git diff --check` and independent review. Numerical/physical/human obligations remain scoped, not catalog-wide PASS.

**Runtime budget:** completed center sweep took 2.078M ticks; full five-family free atlas should be a few million more ticks, plausibly tens of seconds to ~2 minutes locally without full JSON state output, but that is an estimate. At 1005×40000 hard cap, worst declared work is 40.2M ticks; stream output and report actual work. Use a 120s per-process watchdog with retained incomplete artifacts and resumable chunks if needed. A wall timeout is never settled. Measure trace overhead separately on matched fixture sets; per-tick serialization can dominate one-ball physics. Contact stress and export p95 frame budgets cannot be inferred from these throughput numbers.

## Mapping alternatives and compatibility decision boundary

C0 freezes `floor-quadratic-v1` unchanged. C1 may compare, offline and explicitly labelled, the current mapping, another exponent with the same endpoints, a monotone distance-calibrated table, and a finer-input interaction prototype. Use identical physics fixtures, 201 input states and held-out tasks; compute target errors, local slopes/gaps, min/break coverage and correction/acquisition costs. Do not tune friction or compress the hard range secretly. A distance-calibrated table is profile-specific; changing cloth invalidates its identity. Freeze candidate parameters before scored human tasks. Keep every candidate's raw data; no proposed winner is supported by this scout alone.

Human requirements remain NOT_RUN: after fixed familiarization, at least 20 attempts per target/user, record requested/selected input, endpoint, errors, corrections, acquisition time and accidental commitments. Compare interaction alternatives with the same mapping before attributing improvement to physical semantics. Machine reachability does not establish PWR-005 repeatability.

Current session save v1 contains only settled canonical ball states, strokes and pots. Pending/moving saves restore the pre-shot undo checkpoint, not a partial stroke. It stores no power, cue/cloth/profile identity, simulation clock or action log. No durable production replay format was found. A curve-only change would leave settled v1 snapshots structurally loadable but would alter future selected-shot meaning; a physical-profile change would likewise change continuation behavior without version provenance. Existing in-memory undo restores ball states/counters, with no mapping identity. C0 must change none of this. Before semantic adoption, version fixture/replay mapping+profile identities, document legacy v1 continuation semantics, test fresh-process restore/repeat and keep old evidence reproducible. Do not claim save-format compatibility is replay equivalence.

## Preserved evidence identity and limits

SHA256:

- `stroke_power.gd`: `5db09d9cfb0b34d8480277480c658f249f986939b6ac141cb0d63c9060652cc7`
- `cue_strike_model.gd`: `eb1e66144f4f6ea6d188b32858c70da231c8a92a8658db2c4d8c4baa5cdd473f`
- `physics_stepper.gd`: `f16b01423140524a9330daaac39011cca6757fc532ea4fce7dd6cf3fa230669b`
- `physics_config.gd`: `2399412b4328859fc1e317405e479dd64c2009de176f99c6644dfe1088082ee2`
- `game_hud.gd`: `2c740297e10d5de8a0f1c22178d6ce3d8431981d6086052bd1c774a49021909c`
- `spin_pad.gd`: `a69a068b78ed138ec6661ba9d3d3784e820a65368954677a8d85f60741b58dec`
- `game_controller.gd`: `67d03831a85264cc7838dd238968dc8bd47dfebaaed5e2c5638f9745b6afab75`
- `ball_state.gd`: `5b0ab4a9d58f98e46bae1352141d7de563764491d4e5f8cce46799ca1284a8c1`
- `table_spec.gd`: `73b6b76c711104084e6cd94d95dbe2887da494a608e55c415c33293c5df505ff`
- preserved `probe.gd`: `08d3d35f54b1fea57137bc2c384b4d7fb79a437209f53431e87621955ca3b27d`
- preserved `results.json`: `9c7dc76e95f5e5b1c1d6821a924fa8e6921c7dbcea5f0e5ea38e18ee88d7aacc`

The scout does not log all runtime metadata, hardware details, full trajectory, independent energies, exact contacts, controller events or write-error handling. Raw JSON/schema correctness and all-settled/monotonic derivations were checked with Python; this does not upgrade the scout into the proposed acceptance runner. Retained source script and baseline permit reproduction. Contact, calibration, native-device and human evidence remain open. Source-derived visual mismatch and direct-model malformed-input caveats are findings, not implemented fixes.

## Durable scout artifacts

The original probe and 249-shot results are retained in [power-scout-evidence](power-scout-evidence/). They retain the exploratory scope and source hashes above.
