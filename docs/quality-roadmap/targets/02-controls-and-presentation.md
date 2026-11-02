# Controls and presentation targets

Generated from `../QUALITY_REQUIREMENTS.json`, revision **quality-bar-1**. Edit that catalog and run `python3 docs/quality-roadmap/tools/render_targets.py` from the repository root.

Read [contract and definitions](../QUALITY_TARGETS.md) before interpreting thresholds. All rows start **UNVERIFIED**. A separate evidence ledger establishes execution status; this page makes no gameplay acceptance claim.

## AIM — Aim and exact input

Owner surface: GameController / GameHUD / input verification. Test family: [F-INPUT](../TEST_PROTOCOLS.md#f-input). Primary gate: **G3**.

### AIM-001 — Intent retention

**Target (required; product):** Unpressed motion, GUI use and GUI-origin drags change retained physical aim by <=1e-7 rad; deliberate acquisition, release and cancellation are explicit.

**Test/evidence:** Real Viewport routing and native mouse/trackpad sequences through HUD, outside release and focus changes.

**Counterexample to catch:** Calling only the controller input method misses GUI capture.

### AIM-002 — Reachable fine angle

**Target (required; product):** Provide a precise input path with independently selectable increments <=0.005 degrees and reversible repeatability <=0.002 degrees; coarse input remains fast.

**Test/evidence:** 100 positive/negative increments at several headings, zooms, DPI and windows; measure physical direction.

**Counterexample to catch:** Readout changes more finely than the actual shot direction.

### AIM-003 — Pointer mapping

**Target (required; product):** Picking/reprojection error <=0.5 framebuffer pixel for valid table points; stationary pointer drift <=0.25 pixel after transforms settle. Distinguish framebuffer pixels from OS logical points.

**Test/evidence:** Grid and near-rail targets in both cameras, aspect/Retina changes and window moves.

**Counterexample to catch:** An overhead-only picking test masks a lounge-camera offset.

### AIM-004 — Fine intent task

**Target (required; product):** In a pilot, trained users can repeatedly acquire a long straight shot within 0.05 degrees; median acquisition <=3 s after familiarization, accidental aim loss <=1% of attempts. Final panel also applies.

**Test/evidence:** At least 8 pilot users, 20 randomized acquisitions each; record heading error/time and mistakes, stratified by experience.

**Counterexample to catch:** Machine has tiny steps but people overshoot or cannot discover them.

### AIM-005 — Guide promise

**Target (required; product):** Default guide states its exact prediction scope. First-contact geometry and launch direction match the active solver within 0.25 mm /0.02 degrees on the named static corpus; later paths are shown only when separately validated.

**Test/evidence:** Overlay guide and simulated first-contact point over speed/spin/cut sweeps.

**Counterexample to catch:** Draw a confident outgoing ray that omits throw.

### AIM-006 — Uncertainty and identity

**Target (required; product):** A guide that cannot meet its bound is shortened, visibly qualified or omitted; real balls versus guide ghosts are correctly identified >=95% in blinded gameplay-scale trials.

**Test/evidence:** Dark/striped balls, clusters, tangencies, occlusion and guide-off comparisons.

**Counterexample to catch:** A filled ghost is mistaken for a target ball.

### AIM-007 — No hidden aim snap

**Target (required; product):** No discontinuous angular snap >0.005 degrees during continuous fine input except a separately enabled, indicated snapping mode.

**Test/evidence:** Dense pointer sweep across targets, rails, cue center and GUI boundaries.

**Counterexample to catch:** Auto-pot snapping is hidden as precision assistance.

### AIM-008 — Focus and modality

**Target (required; product):** Menu, focus loss, resize/DPI changes, camera transition, placement, undo and stroke commitment terminate incompatible gestures. Re-entry never resumes from a stale held flag.

**Test/evidence:** Transition graph tests with pressed/missed-release events and native capture.

**Counterexample to catch:** Release was consumed by a menu; later motion unexpectedly aims.

### AIM-009 — Keyboard access

**Target (required; product):** Every essential practice operation is keyboard reachable with visible focus; aim and spin contexts are unambiguous and cancel/reset are consistent after GUI actions.

**Test/evidence:** Complete a shot, spin selection, undo, scratch placement and pause with keyboard alone.

**Counterexample to catch:** A focused slider silently steals global fine-aim keys.

### AIM-010 — Response latency

**Target (required; product):** On declared 60 Hz baseline hardware, native input to first correct visible aim response: p95<=25 ms, p99<=40 ms, no unexplained >100 ms stall in 1000 adjustments.

**Test/evidence:** Timestamp input and displayed output using calibrated capture; measure mouse and trackpad separately.

**Counterexample to catch:** Internal handler timestamps exclude queued frames and display delay.

## PWR — Power and useful force levels

Owner surface: StrokePower / GameHUD / control researcher. Test family: [F-POWER](../TEST_PROTOCOLS.md#f-power). Primary gate: **G3**.

### PWR-001 — Physical meaning

**Target (required; product):** Specify input displacement -> authored power -> cue speed -> impulse -> ball speed/spin. A percentage is not force in newtons. If force is exposed, its integral and contact-time model must reproduce impulse.

**Test/evidence:** Trace units and each mapping; independently audit energy/work.

**Counterexample to catch:** Equal slider percentages are asserted to mean equal kinetic energy.

### PWR-002 — Delicate minimum

**Target (required; product):** Zero does not animate, count, sound or fire. Minimum useful nonzero selectable center shot travels 10–30 mm on the frozen reference cloth. Every reachable nonzero setting above that minimum yields measurable motion.

**Test/evidence:** Dense low-end UI sweep using actual controller-to-settle behavior, not a copied formula.

**Counterexample to catch:** Increase rolling friction until a coarse minimum shot looks short.

### PWR-003 — Target distance resolution

**Target (required; product):** Nearest machine-selectable unobstructed center strokes can land at 50,100,200,500,1000 mm within max(2 mm,1% of target). Adjacent settings in the 20–200 mm travel range differ by <=2 mm.

**Test/evidence:** Sweep actual reachable input states; report nearest attainable endpoints and unsatisfied gaps.

**Counterexample to catch:** Fine display decimals conceal coarse actual input quantization.

### PWR-004 — Full range and monotonicity

**Target (required; product):** Preserve the declared full stroke range; current reference maximum cue speed is 8 m/s until a sourced profile revision. At least 101 settings plus every low-end UI quantum have strictly increasing launch speed and smooth travel response outside physical outcome boundaries.

**Test/evidence:** No-rail power/travel plot; compare old/new maximum and curve derivatives.

**Counterexample to catch:** Improve soft shots by removing the break range or hide a dead band.

### PWR-005 — Repeatable selection

**Target (required; product):** Identical committed input/profile produces identical speed/spin on one build. In pilot landing tasks, median absolute error <=5 mm for 50–200 mm targets and <=2% for 500–1000 mm, after practice.

**Test/evidence:** Separate machine reachability from human selection, at least 20 repetitions per target/user.

**Counterexample to catch:** Tuned bot values pass while the mouse cannot select them.

### PWR-006 — Valid and finite input

**Target (required; product):** Zero, negative, nonfinite, out-of-range, canceled and repeated inputs have explicit behavior; each physical commitment fires once. Readout corresponds to committed resolution.

**Test/evidence:** Real controller and UI malformed/boundary requests; hold and release through focus changes.

**Counterexample to catch:** A zero setting still adds a stroke, or two callbacks fire.

## FEL — Stroke feel and state continuity

Owner surface: GameController / presentation / interaction researcher. Test family: [F-FEEL](../TEST_PROTOCOLS.md#f-feel). Primary gate: **G3**.

### FEL-001 — State contract

**Target (required; product):** Aiming, power/spin adjustment, committed delivery, simulation, placement and pause have explicit allowed transitions. Each transition has visual acknowledgement and a cancellation/recovery rule.

**Test/evidence:** Input/state transition table plus native interrupted sequences.

**Counterexample to catch:** Several booleans permit aim and ball placement simultaneously.

### FEL-002 — Tactile correspondence

**Target (required; product):** Cue pullback, selected strength, delivery velocity and result convey the same action. Soft/medium/hard strokes are distinguishable without a percentage readout and remain physically consistent with CUE.

**Test/evidence:** Blind 3-level strength recognition>=90% in pilot, then matched task trials.

**Counterexample to catch:** A different tween duration merely looks dramatic but communicates wrong strength.

### FEL-003 — Ready and pause

**Target (required; product):** Ready appears within one displayed frame after true settle; pause/resume introduces no time jump, late sound, stale input or moving-state freeze.

**Test/evidence:** Slow terminal roll, spin-only state, pause near impact/capture and long suspension.

**Counterexample to catch:** An arbitrary timer calls the table settled before the last ball stops.

### FEL-004 — Placement feedback

**Target (required; product):** Ball-in-hand has a stable translucent preview plus valid/invalid indication that is not color-only; only valid confirmation places the ball and aim begins separately.

**Test/evidence:** Overlapping balls, jaw edges, shelf, resize and GUI crossing with native pointer.

**Counterexample to catch:** An invalid red preview still accepts the click.

### FEL-005 — Camera continuity

**Target (required; product):** No unrequested camera motion during acquisition/delivery; optional transitions preserve aim, target visibility and picking. Motion-reduced mode removes decorative movement.

**Test/evidence:** Toggle/zoom/resize at each state, measure reprojection and retained shot data.

**Counterexample to catch:** The camera changes the apparent line while a stroke is committed.

### FEL-006 — Feedback honesty

**Target (required; product):** Pot, scratch, invalid stroke, miscue and rest have distinct restrained feedback tied to actual events. Cosmetic timing never changes outcomes or delays essential input.

**Test/evidence:** Simultaneous events, guide-off/mute and undo through the full loop.

**Counterexample to catch:** A celebration blocks aiming long after physical rest.

## VIS — Visual fidelity and detail

Owner surface: TablePresentation / BallVisual / shaders / art review. Test family: [F-VISUAL](../TEST_PROTOCOLS.md#f-visual). Primary gate: **G3**.

### VIS-001 — Original coherent direction

**Target (required; product):** Freeze a reviewed reference sheet for table construction, phenolic balls, cloth, cue, pocket lining, lighting and typography. Every asset has provenance and a declared quality/performance budget.

**Test/evidence:** Three matched original keyframes and one pocket/three-ball vertical slice before the full pass.

**Counterexample to catch:** Add high-frequency textures without resolving silhouette or lighting.

### VIS-002 — Ball recognition

**Target (required; product):** Color/group/number identification >=95% correct at ordinary gameplay scale in all supported views; ball versus preview identity>=95%. Include rotation/occlusion and accessible identification aid where physical markings face away.

**Test/evidence:** Run the prospectively frozen recognition deck in F-VISUAL with per-ball/view/experience and context/view/experience strata, explicit exposures/timeouts/misses and counts. Apply the declared descriptive sample floor and report participant-clustered uncertainty; do not claim a population lower bound of95%.

**Counterexample to catch:** Only enlarged stationary numbers are tested.

### VIS-003 — Material separation

**Target (required; product):** Cloth, cushion, wood, lining, cue and ball resin have convincing distinct scale/roughness/reflection response. Perceptual panel median>=4/5 for every material class; no crushed identities or blown white patches.

**Test/evidence:** Neutral/unlit/roughness views plus fixed-exposure gameplay captures and material-specific ratings.

**Counterexample to catch:** One attractive lighting setup conceals flat pocket geometry.

### VIS-004 — Temporal stability

**Target (required; product):** No visible moire, texture crawl, z-fighting, seams, shadow pop or highlight flicker in a 60 s adversarial motion deck. Numerical image-difference evidence is accompanied by real-time viewing.

**Test/evidence:** Slow diagonal rolls, camera motion, high-DPI/downscaled windows and side-on edges.

**Counterexample to catch:** A still screenshot is used to approve a shimmering weave.

### VIS-005 — Grounding and rotation

**Target (required; product):** Contact shadows track support/height without double blobs; spin orientation follows the simulated trajectory and remains continuous through impact, falling and undo. Render state cannot alter physical state.

**Test/evidence:** Marked-ball clips and world-state hashes across visual-quality toggles.

**Counterexample to catch:** Keep every number facing the camera by changing simulated rotation.

### VIS-006 — Pocket construction quality

**Target (required; product):** Visible shelf, facing, rounded lips and recessed lining have coherent depth in both cameras; no intersecting corners, floating rims, filled cutouts or detached strips. Meet GEO alignment at every LOD.

**Test/evidence:** Unlit topology/collision overlay and slow entry/rejection clips for all six pockets.

**Counterexample to catch:** Replace geometry with black circles or alter its physics radius to suit art.

### VIS-007 — Guide legibility

**Target (required; product):** Guide remains distinguishable without hiding contact detail; real/preview identity meets AIM gates. Overhead width 1–2 OS logical coordinate units, variation<=0.5 across DPI/zoom; lounge alternatives require an equally readable declared style.

**Test/evidence:** Dark/white/striped ball and cluster deck; trial recognition and pixel-width audit.

**Counterexample to catch:** Increase line width until it obscures the pocket acceptance margin.

### VIS-008 — UI readability and access

**Target (required; W3C + product):** At every supported window/DPI, essential text rendered em size>=12 OS logical coordinate units, ordinary contrast>=4.5:1 and essential non-text contrast>=3:1. Hit targets>=32 OS logical coordinate units in each dimension, primary>=40, with visible focus. Record actual design-to-OS scaling and glyph cap height; a theme-font number is not proof of rendered size.

**Test/evidence:** Measure actual post-scaling bounds/contrast; resize to 1100 x 700 including letterboxing; keyboard and color-vision checks.

**Counterexample to catch:** Design-unit font size passes while final rendered text is 8 points.

### VIS-009 — Table dominance

**Target (required; product):** At normal play the complete playable area, cue ball and intended target remain visible; no panel, tooltip or decorative object masks a needed line. UI density is evaluated at minimum size.

**Test/evidence:** Reference-task occlusion audit in both cameras and every input state.

**Counterexample to catch:** A permanent tutorial sidebar hides useful table area or overlaps a rail.

### VIS-010 — Geometry-independent appearance options

**Target (required; product):** Exposure, colorblind aids, guide style, shadow quality and motion settings preserve identical physical trajectories/events and retain required readability.

**Test/evidence:** State-hash replay with visual options toggled and capture comparisons.

**Counterexample to catch:** A material/LOD toggle changes collision geometry or ball radius.

## AUD — Sound fidelity and timing

Owner surface: TableAudio / audio author / listening reviewer. Test family: [F-AUDIO](../TEST_PROTOCOLS.md#f-audio). Primary gate: **G3**.

### AUD-001 — Actual listening evidence

**Target (required; product):** Obtain and listen to identified gameplay audio and the local candidate; separate real game effects from trailer music/voiceover. Silent GIFs and waveform plots cannot pass sound-naturalness review.

**Test/evidence:** Matched playback on built-in speakers and wired headphones with written event-specific notes.

**Counterexample to catch:** Call reference sound natural without hearing any reference sound.

### AUD-002 — Contact vocabulary

**Target (required; product):** Cue, ball, cushion/facing and pocket lining/drop are recognizably distinct; each material/dynamic class has panel median>=4/5. At least 4 natural ball-impact variants and 3 variants PER other physical-contact class, unless reviewed synthesis provides equivalent natural variation. Error/miscue cues must also be distinct.

**Test/evidence:** Blind material/dynamic classification and repetition/fatigue listening.

**Counterexample to catch:** One beep is pitch-shifted into every sound class.

### AUD-003 — Physical intensity

**Target (required; product):** Median perceived intensity/loudness increases with declared impact energy/impulse across 9 levels; use repeated variants and report uncertainty. At the frozen calibrated volume/noise setting, softest legal contact detection>=90% and silence false positives<=5%. Full breaks retain headroom. Spectral/attack/decay quality is evaluated separately from scalar intensity.

**Test/evidence:** At least 9 log-spaced intensities, waveform envelope and blinded intensity-order trials.

**Counterexample to catch:** A hard threshold silences the new delicate stroke.

### AUD-004 — Dense contacts and duplicates

**Target (required; product):** Contact identity and scheduling remain auditable under the declared voice budget. Coalesce numerical duplicates per contact identity; preserve perceptually salient cue/rail/pocket events and convincing texture during realistic breaks. Document all priority/voice drops; no global unrelated-contact deletion gate.

**Test/evidence:** Separate 100 contacts/100 ms event-integrity stress from actual listening to plausible breaks; record voice decisions, repeated true contacts, masks and salient event recognition.

**Counterexample to catch:** Delete every ball collision within 16 ms of the last unrelated collision.

### AUD-005 — Mix and tails

**Target (required; product):** Final mix true peak<=-1 dBTP under documented oversampled measurement, no clicks/clipped samples, and >=5 ms de-click fades when stealing active tails unless an equivalent artifact-free method is validated.

**Test/evidence:** Worst-case overlap plus captured output; mute/unmute and voice-budget transitions.

**Counterexample to catch:** Every sample is clean alone but the break clips or voice stealing clicks.

### AUD-006 — Synchronization

**Target (required; product):** On built-in/wired baseline output, visual-contact/audio-onset median absolute offset<=10 ms and p95<=20 ms, capture uncertainty<=5 ms; no drift>5 ms over 10 minutes. Bluetooth/other outputs have separately published budgets.

**Test/evidence:** Calibrated high-speed display-light/photodiode capture synchronized with acoustic mic or wired electrical path; report which path, propagation/clock uncertainty,100 repeated onsets per condition and long-run drift. Ordinary 30/60 Hz video alone cannot establish 5 ms uncertainty.

**Counterexample to catch:** Engine callback timestamps ignore the device buffer.

### AUD-007 — Spatial and cosmetic consistency

**Target (required; product):** Subtle positioning matches camera/visible event; cosmetic variation and voice choices do not alter physics randomness or replay. No double cue sound after cancel/resume.

**Test/evidence:** Mirrored contacts, camera transitions and identical physics replays with audio toggled.

**Counterexample to catch:** Left contact pans right, or sample selection consumes the simulation RNG.

### AUD-008 — Mute and resource lifecycle

**Target (required; product):** Mute may use an artifact-free de-click ramp<=10 ms; afterward every class, queued/tail voice is digitally silent with no later burst. Repeated rack/reset/device changes retain no stale event or unbounded resource growth.

**Test/evidence:** Digital silence check, actual listening and long lifecycle test.

**Counterexample to catch:** Turning sound off leaves an already playing pocket tail at full volume.
