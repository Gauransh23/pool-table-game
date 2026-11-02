# Physics and geometry targets

Generated from `../QUALITY_REQUIREMENTS.json`, revision **quality-bar-1**. Edit that catalog and run `python3 docs/quality-roadmap/tools/render_targets.py` from the repository root.

Read [contract and definitions](../QUALITY_TARGETS.md) before interpreting thresholds. All rows start **UNVERIFIED**. A separate evidence ledger establishes execution status; this page makes no gameplay acceptance claim.

## GEO — Geometry and equipment

Owner surface: TableSpec / TablePresentation / geometry reviewer. Test family: [F-GEOMETRY](../TEST_PROTOCOLS.md#f-geometry). Primary gate: **G1**.

### GEO-001 — Declared equipment profile

**Target (required; WPA + product):** Ship a versioned reference profile. Existing 9-foot profile uses 2.54 by 1.27 m, ball diameter 57.15 mm and mass 0.168 kg; declare all tolerances and source pages. Geometry values are profile choices inside a sourced range, not universal tables.

**Test/evidence:** Independently measure generated coordinates and profile manifest; consult WPA sections 5,7,9,16.

**Counterexample to catch:** Correct settings labels with meshes scaled in centimeters.

### GEO-002 — Shared contact surfaces

**Target (required; product):** Render, collision, support, placement and guide queries consume the same immutable mouth/jaw/slate/nose description. Maximum visible/contact boundary discrepancy <=0.25 mm in world space in both cameras and all LODs.

**Test/evidence:** Overlay sampled collision curves on unlit mesh sections and measure signed distances.

**Counterexample to catch:** A decorative pocket disk conceals an uncut cloth plane.

### GEO-003 — Complete pocket construction

**Target (required; product):** Each of six pockets has explicit mouth, finite facing/jaw, nose cross-section, shelf, fall edge, lining and capture volume. Corner/side distinctions survive mirroring.

**Test/evidence:** Inspect dimensions, section diagrams, simple polygons, contact normals and open volumes for all IDs.

**Counterexample to catch:** Six differently placed copies of one radius trigger.

### GEO-004 — Published range interpretation

**Target (required; WPA + product):** Reference profile mouth widths, shelf depths, cut angles and nose height trace to WPA or a measured table. Source-range compliance is not calibration. Preserve diagrammed angle conventions.

**Test/evidence:** Verify endpoint distances, angle calculations and shelf measured along pocket axis from mouth center.

**Counterexample to catch:** Use an interior angle as the jaw deflection, or apply corner shelf depth to side pockets.

### GEO-005 — Solid sphere contact datum

**Target (required; product):** Ball center height R is tangent to slate y=0. Mesh radius and physical radius differ by <=0.01 mm; no shader-dependent enlargement to improve identity.

**Test/evidence:** Measure world transforms and mesh bounds at supported, airborne and falling states.

**Counterexample to catch:** Raise cloth 2 mm through the ball to hide a shadow.

### GEO-006 — Normals and seams

**Target (required; product):** Contact normals are unit within 1e-6; every contacting seam has an unambiguous outward side. Rendered top normals face out, and adjacent intended contact surfaces have no gap >0.05 mm.

**Test/evidence:** Sample joins, segment endpoints and cross-sections; render front/back debug colors.

**Counterexample to catch:** A reversed triangle passes scalar dimension tests but disappears from above.

### GEO-007 — Finite endpoints

**Target (required; product):** Nose, jaw endpoint and corner contacts use the actual finite shape, including declared rounding. No zero-width converging throat or invisible infinite plane.

**Test/evidence:** Sweep approaches around both endpoints at 0.1 mm spacing, refine contact boundary to 0.01 mm.

**Counterexample to catch:** A ball reflects from an extrapolated rail inside a pocket.

### GEO-008 — Support boundary consistency

**Target (required; product):** Support/volume queries agree with mesh geometry within 0.01 mm for sampled boundary points; test both sides at 1,10,50,100 micrometers and exact edge.

**Test/evidence:** Independent point/triangle and edge-distance tests over the same exported geometry.

**Counterexample to catch:** One inclusive-boundary epsilon quietly creates a large capture strip.

### GEO-009 — Profile changes and cache safety

**Target (required; product):** Every parameter used by a derived surface invalidates its cache. Rendering, guides and audio cannot mutate geometry/profile state.

**Test/evidence:** Vary each parameter individually; hash shared data before/after 10000 queries and scene rebuilds.

**Counterexample to catch:** A cached jaw updates while support polygons remain old.

### GEO-010 — Placement validity

**Target (required; product):** Cue placement requires full supported sphere clearance from other balls, physical rails/jaws and unsupported openings, within 0.05 mm query tolerance. Preview and confirmation agree.

**Test/evidence:** Boundary corpus plus confirm at every displayed valid/invalid transition.

**Counterexample to catch:** Center point is on cloth but half the ball intersects a cushion.

### GEO-011 — Cue obstruction and clearance

**Target (required; product):** Ordinary stance includes shaft/tip/ferrule clearance; no cue penetration >0.25 mm into rail or balls during aim/stroke. A physically unavailable stroke is visibly blocked or uses a validated elevated stance.

**Test/evidence:** Sweep cue-ball rail distance, direction and tip offsets; inspect full cue swept volume.

**Counterexample to catch:** A perfect impulse is generated by a cue drawn through a rail.

### GEO-012 — Round-trip geometry

**Target (required; product):** Serialization and profile reload preserve dimensions to <=1 micrometer and preserve pocket IDs, handedness and normals exactly in meaning.

**Test/evidence:** Export/reload two profiles and repeat support/contact queries.

**Counterexample to catch:** x/z or millimeter/meter swap survives a screenshot test.

## CUE — Cue strike, impulse and stance

Owner surface: CueStrikeModel / GameController / TablePresentation. Test family: [F-STRIKE](../TEST_PROTOCOLS.md#f-strike). Primary gate: **G2**.

### CUE-001 — Energy and impulse

**Target (required; derived + product):** For a legal resting-ball strike, ball kinetic-energy gain (translation+rotation) <=0.5*m_cue*v_cue² plus declared external work and max(1e-9 J,1e-6*input energy). A closed cue+ball model also accounts for outgoing cue/recoil and losses. Unsupported moving-ball strikes are explicitly rejected or separately validated.

**Test/evidence:** Independent effective-mass/energy cases and a speed/offset/elevation grid.

**Counterexample to catch:** Linear speed is bounded but spin adds unaccounted energy.

### CUE-002 — Contact point mapping

**Target (required; product):** Input axes, rendered tip and physical contact arm agree within 0.1 mm. Top/bottom/left/right/diagonal signs are verified in both cameras.

**Test/evidence:** Inspect world contact coordinates and resulting spin; perturb each sign independently.

**Counterexample to catch:** UI says draw while the physical contact is above center.

### CUE-003 — Offset behavior

**Target (required; product):** Launch speed/spin, squirt and miscue boundary agree with a sourced model/measurement within calibration bounds; include combined offsets and near-limit cases.

**Test/evidence:** Fit/hold out families with r/R=0,.1,.25,.45,.49,.50 and points just outside supported domain.

**Counterexample to catch:** Only cardinal-axis spin cases work.

### CUE-004 — Delivered speed coherence

**Target (required; product):** Continuous visual tip velocity at contact agrees with the commanded physical cue speed within 10%; derive motion travel/duration consistently. Displayed frame samples match the integrated trajectory rather than a separately timed fake hit.

**Test/evidence:** Analytic motion-curve audit and high-frame-rate rendered capture for soft/medium/hard delivery.

**Counterexample to catch:** A fixed 75 ms tween depicts 2 m/s while physics delivers 6 m/s.

### CUE-005 — Contact synchronization

**Target (required; product):** One committed stroke emits exactly one physical impulse at tip contact; world-space contact error <=0.1 mm and first visible ball motion is within one rendered 60 Hz frame. Selected inputs are frozen until impact.

**Test/evidence:** Capture rendered contact plus impulse state; mutate pending UI values and compare delivered shot.

**Counterexample to catch:** A timer fires independently of cue animation.

### CUE-006 — Clearance and ordinary elevation

**Target (required; product):** Final required coverage includes physically valid ordinary elevated stances from0 to10 degrees and usable rail-adjacent shots with cue clearance. Geometrically impossible strokes are visibly blocked. Reject unsupported candidates during development, but declaring all everyday elevated strokes unavailable does not pass this gate.

**Test/evidence:** Obstacle-distance/elevation/offset matrix with swept cue volume and ball launch.

**Counterexample to catch:** The interface hides a common clearance limitation until the shot behaves wrong.

### CUE-007 — Squirt and swerve distinction

**Target (required; product):** Initial deflection and subsequent cloth-driven curvature are separately represented and calibrated where ordinary elevation is supported; signs and speed/elevation dependence are tested.

**Test/evidence:** Matched center/left/right and mirrored elevated families with tracked trajectories.

**Counterexample to catch:** Add permanent sideways acceleration for all side spin.

### CUE-008 — Commit/cancel motion

**Target (required; product):** Input acknowledgement appears within one frame; deliberate stroke timing is explicit. Cancel, menu/reset/focus loss before contact produce no impulse, sound or score; after contact never undo an already delivered impulse implicitly.

**Test/evidence:** Interrupt at 0/25/50/90/99/100% of authored delivery timeline.

**Counterexample to catch:** A canceled tween later shoots after resume.

## CLT — Cloth, rolling, draw and spin decay

Owner surface: PhysicsStepper cloth integration / calibration owner. Test family: [F-CLOTH](../TEST_PROTOCOLS.md#f-cloth). Primary gate: **G2**.

### CLT-001 — Analytic rolling

**Target (required; derived + product):** For a calibrated constant-resistance ideal fixture, speed, stopping time and distance error <=0.1% relative with appropriate near-zero absolute tolerances. Test several speeds and durations.

**Test/evidence:** Use v(t)=max(v0-mu_r*g*t,0), distance v 0²/(2*mu_r*g) and stopping time v0/(mu_r*g).

**Counterexample to catch:** Endpoint is correct only because sleep truncates a wrong deceleration.

### CLT-002 — Slide-to-roll transition

**Target (required; derived + product):** Ideal homogeneous-sphere sliding transition time, displacement and speed agree within 0.1%; residual contact slip <=1e-4 m/s at transition, with no velocity/spin discontinuity.

**Test/evidence:** Use independent slip/torque equations and full transition traces, including reversed slip.

**Counterexample to catch:** A threshold toggles between regimes and adds energy.

### CLT-003 — Pure rolling kinematics

**Target (required; product):** Contact slip stays <=1e-4 m/s and integrated orientation error <=0.25 degrees over 1 m for the ideal no-slip fixture.

**Test/evidence:** Marked sphere translation/rotation oracle on axis and diagonal paths.

**Counterexample to catch:** A ball center moves correctly while its texture skates.

### CLT-004 — Follow/draw/stun repertoire

**Target (required; product):** Measured center, follow, draw and stun shots meet the calibrated trajectory/endpoint bounds independently across distance and speed, including draw reversal and combined english.

**Test/evidence:** At least 5 initial speeds,3 cue-object distances, signed top offsets and held-out combinations.

**Counterexample to catch:** One tuned draw shot passes; longer draw becomes unintended follow.

### CLT-005 — Spin-in-place and decay

**Target (required; product):** Pure sidespin decays monotonically under the declared model and stays within measured angular-decay bounds; no unsupported lateral drift >0.1 mm on the ideal level/isotropic fixture.

**Test/evidence:** Zero-translation spin tests both signs, then compare sourced/measured traces.

**Counterexample to catch:** Spin friction accidentally accelerates the ball sideways.

### CLT-006 — Last millimeters and sleep

**Target (required; derived + product):** Sleep removes <=0.05 mm of remaining ideal rolling travel and causes no position/orientation snap. Ready state waits for relevant motion; no fixed shot timeout forces rest.

**Test/evidence:** Derive tail bound from v²/(2*mu_r*g), inspect slow motion at 30/60/120 Hz and prolonged spin.

**Counterexample to catch:** A velocity-only .012 m/s cutoff would discard about 0.61 mm on this cloth; test the actual compound sleep condition rather than assuming that omission.

### CLT-007 — Cloth profile variation

**Target (required; product):** Each cloth preset has sourced/calibrated parameter ranges and held-out behavior; directional drift/nap/random skid is an explicit separate model when supported.

**Test/evidence:** Sensitivity plots, profile swaps and reproducibility checks with variation disabled.

**Counterexample to catch:** Random drift is introduced to hide systematic model error.

## BAL — Ball impacts and contact detail

Owner surface: PhysicsStepper ball contact / independent physics reviewer. Test family: [F-BALL](../TEST_PROTOCOLS.md#f-ball). Primary gate: **G1**.

### BAL-001 — Elastic isolated conservation

**Target (required; derived + product):** Frictionless equal-mass isolated impacts preserve total momentum and kinetic energy within1e-6 relative or1e-9 in corresponding SI absolute units; outgoing vectors meet the analytic solution.

**Test/evidence:** Head-on/cut/moving-target and 3 D-height fixtures with independent vector solution.

**Counterexample to catch:** Correct departure angle but incorrect transferred speed.

### BAL-002 — Dissipative accounting

**Target (required; product):** At isolated contacts with no external work, translational+rotational energy cannot increase by >1e-6 relative or1e-9 J. Record normal/tangent impulses and losses.

**Test/evidence:** Before/after same-position contact ledger and pure spin-transfer cases.

**Counterexample to catch:** Friction removes translation but creates too much rotation.

### BAL-003 — Impact timing

**Target (required; product):** Isolated sphere contact-time error <=10 microseconds +2 micrometers/normal closing speed for well-conditioned contacts. Grazing cases use closest-approach/boundary error <=2 micrometers, not division by a near-zero speed.

**Test/evidence:** Analytic quadratic roots, time-phase sweep, exact-touch and near-gap cases.

**Counterexample to catch:** Use the correct normal after integrating an entire overlap interval.

### BAL-004 — Thin cuts and tangencies

**Target (required; product):** Outside the declared contact uncertainty band (<=2 micrometers), legal thin hits and true clearances are classified correctly. Inside it, report tolerance-limited classification. Ideal outgoing direction error <=0.02 degrees when speed>=0.05 m/s; slower outputs use vector error bounds.

**Test/evidence:** Cut angles 0–89.9 degrees, refine around tangent at micrometer offsets and mirror both sides.

**Counterexample to catch:** A broad epsilon causes ghost contacts or suppresses valid grazes.

### BAL-005 — Throw and spin transfer

**Target (required; product):** Cut-induced/spin-induced throw, gearing, follow/draw interaction and spin transfer meet sourced/measured bounds; absence/sign-change locations are tested.

**Test/evidence:** Independent sourced curves within their domain and held-out speed/cut/spin grids.

**Counterexample to catch:** Constant tangential correction matches one cut but reverses gearing behavior.

### BAL-006 — Frozen and simultaneous contacts

**Target (required; product):** Touching pairs,3/4-ball chains, double kisses and tight racks have finite, converged observable outcomes under a declared contact law. Individual simultaneous-contact impulses are checked only against an appropriate solver/contact-law oracle, not an assumed universal unique decomposition.

**Test/evidence:** Symmetric and asymmetric multi-contact corpus with increasing solver quality.

**Counterexample to catch:** A single pair sweep hides cluster order dependence.

### BAL-007 — Penetration budget

**Target (required; product):** Immediately before contact resolution, isolated penetration <=0.01 mm and dense-cluster transient penetration<=0.2 mm. Record post-resolution residual separately; every settled overlap<=0.05 mm. Bounds include all declared slop. Report worst pair/time, not an average.

**Test/evidence:** Measure every substep across the stress corpus; retain offending states.

**Counterexample to catch:** Position correction leaves a visibly compressed frozen rack.

### BAL-008 — Contact identity and order

**Target (required; product):** Events distinguish true physical contacts from numerical solver iterations. First contact, repeated distinct impacts and separations have stable chronological identity with declared simultaneous-event tie semantics.

**Test/evidence:** Inspect raw event times/pairs and separated/repeated-contact fixtures.

**Counterexample to catch:** One collision produces six sounds or suppresses a later double kiss.

### BAL-009 — Total angular momentum

**Target (required; derived + product):** Closed free-space ball contacts conserve orbital plus intrinsic angular momentum within1e-6 relative or1e-9 kg*m²/s absolute, using the defined noncancelling reference scale. Table/cue external torques are accounted for separately.

**Test/evidence:** Signed spin transfer and oblique moving-pair fixtures at several reference origins; compute sum(r cross m*v + I*omega) independently.

**Counterexample to catch:** Check only intrinsic spin and falsely report a transfer imbalance, or omit external table torque.

## RAI — Cushions and slate coupling

Owner surface: PhysicsStepper rails / table model / calibration reviewer. Test family: [F-RAIL](../TEST_PROTOCOLS.md#f-rail). Primary gate: **G2**.

### RAI-001 — Geometry-aware contact

**Target (required; product):** Contact location/normal follows nose height, finite shape and sphere height; no rectangular fallback changes rail position at pockets. Ideal geometric contact error <=0.01 mm.

**Test/evidence:** Height/incidence/endpoint sweeps with mesh-section oracle.

**Counterexample to catch:** A ball clears the visible nose but collides with a full-height wall.

### RAI-002 — Speed-angle-spin response

**Target (required; product):** For measured supported rail families, outgoing angle median error<=0.15 degrees and p95<=0.5 degrees; speed-ratio median error<=2% and p95<=5%; spin must meet CAL bounds.

**Test/evidence:** Repeat at several speeds, incidence angles and both english signs; hold out entire families.

**Counterexample to catch:** Tune one restitution scalar to one perpendicular bounce.

### RAI-003 — Coupled support reaction

**Target (required; product):** Rail/slate forces and friction form one consistent contact model. Downward impulses are reacted/accounted for rather than silently discarded; small hops and landing are finite and calibrated where present.

**Test/evidence:** Log 3 D impulse/work, vertical state, normal loads and post-impact slip through contact.

**Counterexample to catch:** Reset vertical velocity next tick and call that a validated slate reaction.

### RAI-004 — Running/reverse english

**Target (required; product):** Mirror-related shots mirror, running/reverse responses vary continuously away from physical regime boundaries, and tangent/normal components have the sourced signs.

**Test/evidence:** Incidence 5/15/30/45/60/75/85 degrees and signed spin ratios.

**Counterexample to catch:** A visually plausible bank has reversed spin or a sign error on one rail.

### RAI-005 — Published model domain

**Target (required; Mathavan + product):** Every paper-derived rail model records its ball/cushion/material assumptions and speed domain. Mathavan 2010 rigid-cushion results are a limited oracle, not a universal 8 m/s preset.

**Test/evidence:** Read source equations/validation limits; test below/near/above the stated limit using different evidence above it.

**Counterexample to catch:** Apply a snooker rigid-cushion coefficient to every fast pool break.

### RAI-006 — Near-parallel and repeated rails

**Target (required; product):** Grazing/rail-hugging shots neither stick nor gain energy; multiple cushion paths preserve correct event counts and calibrated losses.

**Test/evidence:** Long near-parallel rolls, spin reversals and 2/3-rail position drills.

**Counterexample to catch:** A ball jitters forever along a straight rail or tunnels past a jaw.

### RAI-007 — Facing and main cushion distinction

**Target (required; product):** Jaw/facing and cushion responses use declared material geometry and calibration; equality is allowed only with evidence, not by convenience.

**Test/evidence:** Compare same incoming state on rubber nose, facing and recessed liner.

**Counterexample to catch:** Every rail-like contact uses the same restitution despite visibly different outcomes.

## POC — Pocket entry, rejection and continuity

Owner surface: TableSpec / PhysicsStepper / pocket presentation. Test family: [F-POCKET](../TEST_PROTOCOLS.md#f-pocket). Primary gate: **G2**.

### POC-001 — Support before gravity

**Target (required; product):** Supported resting balls remain supported indefinitely. Unsupported balls descend under gravity/contact forces with no injected capture velocity or attracting force.

**Test/evidence:** All six shelf/edge positions, exact boundary and epsilon pairs,100 s stationary holds.

**Counterexample to catch:** Crossing a rectangular trigger gives an immediate downward kick.

### POC-002 — Partial descent remains physical

**Target (required; product):** Balls near a shelf/facing/other ball remain collidable until geometrically separated below the playable volume. Legitimate re-entry occurs before irreversible capture.

**Test/evidence:** Two-ball pocket collisions, jaw-first in/out paths, hanging balls and support recovery.

**Counterexample to catch:** FALLING state disables collisions and guarantees a pot.

### POC-003 — No supported-bed scoring

**Target (required; product):** Zero pots caused by penetrating solid slate or bypassing the real opening. The first irreversible capture must follow a valid 3 D free-volume entry path. A2 D bed projection alone is not an oracle; a legitimately captured downstream return may pass beneath the bed.

**Test/evidence:** Replay fast center/jaw and retained 8 m/s counterexamples using sphere/solid membership, entry history, contact and scoring events on all pockets.

**Counterexample to catch:** A liner rebound travels under the table and is counted as pocketed.

### POC-004 — Capture lifecycle

**Target (required; product):** Exactly one capture event occurs after the ball is irreversibly inside the matching pocket volume below the slate. Off-table and captured outcomes are distinct and conserved in the ball inventory.

**Test/evidence:** Full per-ball lifecycle ledger through high-speed entry, rejection, scratch and return presentation.

**Counterexample to catch:** Score at mouth entry; later reject without undoing an already granted pot.

### POC-005 — Acceptance boundary fidelity

**Target (required; product):** Against a measured pocket, stable pot/reject classifications agree >=95% outside the measured transition band. Predicted transition location differs <=2 mm at the mouth or <=0.25 degrees in approach angle, whichever scan is used.

**Test/evidence:** Rasterize outcome maps, repeat boundary shots and estimate natural variability; report confusion by pocket/speed.

**Counterexample to catch:** Tune a generous radius until most clean-center pots succeed.

### POC-006 — Speed and spin dependence

**Target (required; product):** Slow center drop, rail-hugging entry, high-speed rejection, jaw-rattle, double-jaw and signed-spin families are independently validated for corners and sides.

**Test/evidence:** Use F-POCKET scan axes and repeat both mirror signs.

**Counterexample to catch:** One easy pocket entry is treated as proof of all pocket behavior.

### POC-007 — Shelf and edge behavior

**Target (required; product):** A ball can rest/hang, roll off and return according to actual geometry; the edge reaction has bounded energy/projection error and passes numerical refinement.

**Test/evidence:** Slow near-threshold shots with energy/potential ledger and refined geometry/time step.

**Counterexample to catch:** A position correction creates an unexplained jump or sticky equilibrium.

### POC-008 — Rendered descent

**Target (required; product):** Visible ball-node/mesh world transforms agree with physics within 0.25 mm through entry/descent; assess that subpixel bound in world space. Image-space evidence separately establishes continuous occlusion/rotation/shadow/disappearance and no visible suspension/pop-through.

**Test/evidence:** Frame-by-frame overhead/lounge shots, including slow edge descent and high-speed entry.

**Counterexample to catch:** A depth cutoff hides a floating ball before it reaches the return path.

### POC-009 — Pot identity feedback

**Target (required; product):** Each pot has a clear retained identity/progress update within 100 ms of capture, never before it; scratch is visually distinct. Cosmetic return/celebration cannot change the physical outcome.

**Test/evidence:** Capture setup→entry→capture→feedback→ready; include simultaneous pots and undo.

**Counterexample to catch:** A count changes but the player cannot tell which ball disappeared.

### POC-010 — Stable terminal storage

**Target (required; product):** Every ball is active, captured or off-table exactly once. Hidden pocket storage is bounded, finite and deterministic; visible stacks/returns are collision-consistent or an explicit cosmetic presentation.

**Test/evidence:** Repeated multi-pot clears, six-ball pocket load and reset/restore cycles.

**Counterexample to catch:** Hidden pocket bodies keep simulating unbounded positions or leak into a later rack.

## NUM — Numerical precision and determinism

Owner surface: Active stepper owner / independent numerical reviewer. Test family: [F-NUMERIC](../TEST_PROTOCOLS.md#f-numeric). Primary gate: **G1**.

### NUM-001 — Quiet final convergence

**Target (required; product):** On identical smooth/isolated initial states at matched horizons, two successive high-quality refinements converge to <=0.10 mm endpoint difference and <=0.02 degrees departure difference. Demonstrate at least three refinement levels.

**Test/evidence:** 240/480/960/1920 Hz or equivalent event tolerances, then continue until plateau; distinguish transient versus final.

**Counterexample to catch:** Only the finest level is tested, or horizon differs by one tick.

### NUM-002 — Production error budget

**Target (required; product):** Production settings differ from the independently validated high-quality result by <=0.25 mm and <=0.05 degrees on every quiet family; physical calibration error is reported separately.

**Test/evidence:** Compare actual shipped solver/profile to reference at matched times and first-contact events.

**Counterexample to catch:** An experimental engine meets the bound while the app uses another path.

### NUM-003 — Scale-aware tolerances

**Target (required; product):** Each epsilon has units, magnitude rationale and a float-precision budget. Numerical contact tolerance <=2 micrometers on the supported table domain; separating pairs beyond it do not collide.

**Test/evidence:** ULP/gap/tangent probes at center and far coordinates; exact-touch approaching and separating cases.

**Counterexample to catch:** A0.1 nm nudge rounds away in Vector2 float32 or one epsilon is reused for squared distance and speed.

### NUM-004 — No tunneling

**Target (required; product):** No missed ball/rail/jaw/slate crossing in the declared maximum-speed domain including full-phase and grazing sweeps. Failure is explicit outside that domain.

**Test/evidence:** Swept analytic or independently oversampled collision oracle, translated and time-shifted fixtures.

**Counterexample to catch:** A speed cap silently clips a legal break to conceal missed contacts.

### NUM-005 — Conservation ledger

**Target (required; product):** Elastic isolated pair momentum/energy and dissipative contact budgets satisfy BAL gates. Gravity potential, cue work, projection work and removed/captured states are separately accounted for in system-level energy.

**Test/evidence:** Record per-step before/after total energy and nonphysical residuals.

**Counterexample to catch:** Kinetic energy grows during a fall and is falsely called numerical gain, or projection work is ignored.

### NUM-006 — Mirror and rotation covariance

**Target (required; product):** For valid symmetries, endpoint differences <=0.01 mm, speed differences<=1e-5 m/s and spin differences<=1e-4 rad/s. Angular velocity uses axial-vector transform det(M)*M; geometry and cue inputs transform too.

**Test/evidence:** Both table reflection axes and 180-degree rotation; compare transformed events by semantic identity.

**Counterexample to catch:** Mirror angular velocity as an ordinary position vector.

### NUM-007 — Storage-order sensitivity

**Target (required; product):** Permutation of ball storage changes quiet outcomes by <=0.10 mm/0.02 degrees; simultaneous clusters meet a declared converged solution budget and no classification bias by ID.

**Test/evidence:** At least 24 permutations for representative clusters and reversed rack traversal; stable IDs stay attached.

**Counterexample to catch:** Renumbering balls changes a straight frozen-chain outcome.

### NUM-008 — Frame-chunk independence

**Target (required; product):** On one binary/profile and equal fixed-tick schedules,30/60/120/144 Hz render chunks and injected stalls yield identical canonical physical states/events; compare at equal simulation ticks, not arbitrary wall times.

**Test/evidence:** Chunk/replay fixtures and full trace hashes through undo/save/restore.

**Counterexample to catch:** Dropped accumulated time makes the game run slower during a stall.

### NUM-009 — Budget exhaustion visibility

**Target (required; product):** All event/iteration/catch-up limits emit auditable diagnostics; zero unreported exhaustion. Shipped stress corpus has zero accuracy-changing fallbacks. Overload policy preserves explicit simulation semantics.

**Test/evidence:** Frozen chains and adversarial contacts exceed prototype limits; verify failure/reporting and bound sensitivity.

**Counterexample to catch:** A16-event cap silently reverts to a less accurate solver.

### NUM-010 — Stress ladder

**Target (required; product):** Pass 1000 development then 10000 release seeded legal breaks plus difficult clusters. No nonfinite/lost balls, no safety-invariant failures; settled overlap<=0.05 mm. Retain every failing seed.

**Test/evidence:** Record sampled transient energy/contact diagnostics and simulate to actual rest, not a 1000-tick cutoff.

**Counterexample to catch:** Twenty short breaks are labelled a completed release stress test.

### NUM-011 — Long-session stability

**Target (required; product):** Ten-thousand reset/shot/undo/load cycles preserve state invariants and deterministic replay; invalid inputs return explicit failure without state mutation.

**Test/evidence:** Lifecycle stress with resource and memory accounting, including interrupted strokes.

**Counterexample to catch:** A capture-event suppression map survives into a new rack.

### NUM-012 — Cross-platform scope

**Target (required; product):** Every advertised platform/architecture passes shared numerical fixtures. Bitwise cross-platform equality is claimed only if demonstrated; otherwise publish strict bounded divergence and classification policy.

**Test/evidence:** Same fixture hashes on each supported build, compiler/precision metadata recorded.

**Counterexample to catch:** One Mac result is presented as Android or universal determinism.
