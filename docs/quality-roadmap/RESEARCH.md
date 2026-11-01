# Research protocol and acceptance catalogue

## 1. Establish a representative comparison set

“All internet pool games” is neither enumerable nor a meaningful single quality target. Build a dated inventory spanning casual mobile/browser pool, precision simulation, and premium desktop presentation. Start with Miniclip 8 Ball Pool; investigate current access to Virtual Pool, ShootersPool, Cue Club 2, and at least two accessible browser alternatives. These are research candidates, not a claim that their current versions were tested or that they all outperform this game.

Record product, exact version, platform, device, refresh rate, resolution, input method, access date and availability. Do not compare phone touch latency directly against mouse latency without labeling the difference. Use legitimate access; if a title is inaccessible, label it and substitute another in the same category. Stop expanding the set once two successive candidates add no new material interaction or quality benchmark; retain the coverage limitation.

For every accessible title capture the same sequence: aim a long straight shot; move to power/spin; minimum useful touch; center-ball stop; follow/draw; side-spin rail; thin cut; pocket jaw miss; hanging ball; break; scratch recovery; pause/resume. Record screen video with input timing where possible and screenshots at native gameplay scale. Annotate observations separately from inferred physical mechanisms. Marketing descriptions are not measurements.

Evaluate five independent axes: control precision, physical plausibility, visual readability, material/lighting quality, audiovisual timing. Avoid a weighted total until the owner agrees that tradeoffs are acceptable. A title can be a reference for controls without being a reference for physical realism.

## 2. Primary sources and how to use them

Sources discovered October 30, 2026:

- Miniclip official game page: https://www.miniclip.com/games/8-ball-pool/ — identify the product; does not establish physics accuracy.
- Official web access guidance: https://support.miniclip.com/hc/en-us/articles/7759609431953--8-Ball-Pool-Web-PC-version — verify actual availability at execution time; help pages may lag service changes.
- Pooltool modular physics documentation: https://pooltool.readthedocs.io/en/latest/resources/custom_physics.html — investigate interchangeable models and parameter assumptions. Pin a version before experiments.
- Pooltool physics API: https://pooltool.readthedocs.io/en/latest/autoapi/pooltool/physics/index.html — locate reference implementations and event semantics. Differential agreement is not proof of truth.
- Mathavan/Jackson/Parkin cushion paper: https://drdavepoolinfo.com/physics_articles/Mathavan_IMechE_2010.pdf — read equations, assumptions, experimental conditions and uncertainty before deriving a rail oracle.

Next research must retrieve current official WPA equipment specifications, Alciatore technical proofs and original measured friction/throw studies. Store title, author, publication date, URL, retrieval date, relevant page/equation, units, assumptions and licensing. Existing RESEARCH_NOTES.md is a lead index, not automatically verified evidence. Do not transplant a default coefficient as a universal constant.

## 3. Turn research into specifications

For each proposed behavior create one requirement row: ID; player-visible problem; source or product decision; independent oracle; inputs and units; expected output; tolerance and why; counterexample; owning runtime path; test; evidence artifact; reviewer. Classify values as physical measurements, analytic consequences, product targets, or provisional hypotheses. Uncertainty larger than the target tolerance requires better measurements, not fabricated precision.

Calibration procedure: measure table dimensions and ball properties; calibrate video scale and camera perspective; track positions with timestamps; estimate measurement error; fit rolling resistance first, then sliding/spin behavior, then collisions/cushions; reserve entire shot families for held-out validation. Record parameter covariance and residual plots. Do not fit all coefficients simultaneously to one impressive break. Repeat shots to estimate physical variability. Separate numerical error from experimental uncertainty and intentional game assistance.

## 4. Proposed initial engineering targets

These are product proposals, not measured competitor statistics or universal physical laws. Reconcile with the older handoff and hardware baseline before freezing them. Never lower a target solely to make a patch pass.

| ID | Target | Method and limitation |
|---|---|---|
| CTL-LOCK | Unpressed pointer travel and HUD interaction preserve retained aim | Automated input sequence, plus real mouse session |
| CTL-SOFT | Lowest useful nonzero strokes allow 2–10cm travel; zero does not fire | At least 21 power samples and dense low-end sweep; keep full-power range |
| PHY-SUPPORT | Supported stationary balls remain supported; capture requires support loss | Geometry-derived fixtures on both sides of each boundary |
| PHY-GEOM | Renderer and collision mouths derive from the same table definition | Debug overlay at two cameras; propose <=1px visible boundary discrepancy at 1600×900 |
| PHY-ANALYTIC | Isolated no-friction equal-mass impacts meet analytic velocity/momentum results | Proposed relative error <=0.1%, excluding near-zero denominators; absolute tolerance specified per quantity |
| PHY-CONVERGE | Ordinary isolated shots change terminal position <=1mm and direction <=0.1° between refined settings | Compare 480/960/1920Hz plus travel limits; chaotic breaks use distributions, not identical endpoints |
| PHY-STRESS | No nonfinite states, impossible pocket IDs or unexplained energy creation in 10,000 seeded legal breaks | Log max overlap and energy residual; collision/friction-free conservation tests separate from dissipative cases |
| VIS-IDENTITY | At least 95% correct ball identification in a timed gameplay-scale test | Proposed pilot with >=8 people, novices and pool players; report confidence intervals and failures, not statistical proof of universal quality |
| VIS-POCKET | No cloth occlusion/pop-through during entry; readable jaw and shelf depth | Slow-motion replay and matched camera captures at 100% scale |
| PERF-FRAME | Proposed 60Hz baseline: p95 <=16.7ms, p99 <=25ms during representative play | Warm 10-minute session on declared minimum target device; separate CPU/GPU and loading |
| FEEL-CONTACT | Cue contact, impulse and audio onset occur within one displayed frame | Timestamp events and validate video/audio; intentional backswing excluded |
| LIFE-REPLAY | Undo/restore reproduces valid settled state; malformed/moving saves handled explicitly | Serialized fixtures, interrupted lifecycle and repeated restore |

## 5. Required scenario corpus

Every fixture contains schema version, seed, table geometry/version, coefficients, units, positions, linear/angular velocity, shot input, expected event sequence, reference source, tolerance and classification.

A: analytic rolling, slide-to-roll, spin decay and no-friction equal-mass impacts. B: cuts at 0/15/30/60/80 degrees, both signs, moving targets, low/medium/high speeds, draw/follow/side-spin. C: cushions at 5/15/30/60/85-degree incidence with zero and both signs of spin; nose-height variations; corners. D: each pocket, centerline and mouth-edge paths, several speeds, jaw-first contacts, shelf rests, in/out rattles, nearby second balls. E: frozen/touching balls, grazing contacts, dense clusters, rack permutations, seeded breaks. F: render rate 30/60/120/144Hz, injected stalls, pause, resize, camera switching, undo and save/restore.

Metamorphic checks: mirror table and spin with correctly transformed axial vectors; rotate applicable symmetric configurations; permute ball storage order; change render frame chunks while preserving elapsed simulation time. Explain expected invariance and numerical tolerance. For every passing test name a wrong implementation that could pass, then add the cheapest discriminator. Never treat the native engine and runtime as two independent oracles if they share the same flawed assumptions.

## 6. Visual and listening study

Capture overhead, lounge and close-up views under a fixed exposure at 1100×700 and 1600×900 plus target high-DPI settings. Include empty table, rack, moving balls, a dark ball near a rail, stripes with numbers facing away, and pocket entry. Review silhouette, contact shadows, reflection shape, number readability, cloth frequency, wood scale, pocket depth, cue alignment and HUD obstruction separately.

Create three original art-direction frames before producing assets. Use matched crops and randomized A/B presentation, ask which supports shot judgment and why, and preserve disagreements. Choose a direction on evidence and owner preference. Build one pocket and three balls as a vertical slice before a complete asset pass. Track mesh/texture/shadow budgets and licenses.

Audio research must compare cue/ball/rail/pocket events at several impact speeds, voice overlap during breaks, silence during rest, volume balance and fatigue. Inspect actual playback timing and voice truncation. Synthetic generation is not inherently disqualifying; judge audible results. A screenshot cannot approve audio or motion quality.
