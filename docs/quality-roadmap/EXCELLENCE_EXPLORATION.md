# Excellence exploration: from working pool to a convincing instrument

Date: 2026-10-30. Supplement to ASSESSMENT.md and RESEARCH.md; preserves their findings. This is a second source-based exploration prompted by the owner's clarification. No new gameplay capture or physical calibration was performed. All numerical targets below are proposed research targets unless explicitly identified as derived quantities. They must not be described as measured performance of this game or competitors.

## 1. The corrected ambition

The previous assessment emphasized defects and minimum quality gates. Those gates are necessary but insufficient. The ambition is a pool experience whose fine control, motion, contact, material response and timing reward sustained scrutiny. An expert should recognize familiar positional play; a novice should learn a stable relationship between intention and outcome. The ordinary shot should feel considered from initial aiming to the last millimeter of rolling.

Assume the current implementation has many missing dimensions. Classify them through investigation rather than assuming every simplification is a defect. A phenomenon can be physically real, unmodeled, and irrelevant to this product; another can be a tiny effect that determines whether positional play feels credible. Measure which is which.

This goal does not require recreating every physical imperfection. Unexplained random skids, cloth drift or cue variation can reduce trust. First establish a calibrated reference table with stable equipment. Introduce variation only when it serves a deliberate, visible product choice and has evidence. High fidelity means the important relationships are right, including when their importance changes with speed, angle and spin.

## 2. Six independent bars

1. Physical fidelity: the model expresses the relevant mechanisms and their coupling.
2. Numerical fidelity: the solver approximates that model accurately enough over the supported domain.
3. Expressive control: players can select useful small changes without accidental changes elsewhere.
4. Perceptual coherence: trajectory, rotation, cue motion, sound and contact cues describe the same event.
5. Visual craft: geometry, materials, lighting, composition and temporal stability hold up at playing scale.
6. Experiential quality: the complete interaction is understandable, predictable, satisfying and learnable.

No average score may hide a failed dimension. Beautiful materials cannot compensate for misleading aim; precision trajectories cannot compensate for coarse power control. A quality scorecard should retain each dimension and its uncertainty.

## 3. What this version represents—and leaves unexplored

These are source observations, not a claim that each omitted effect must be implemented.

| Area | Current representation | Higher-bar investigation |
|---|---|---|
| Strike | Cue mass, efficiency, effective end mass, tip offset and squirt formula | Calibrate delivered speed/spin across offsets; validate contact location, effective cue response and the semantics of power |
| Cue elevation | Strike API accepts elevation; playable controller supplies zero | Assess ordinary rail-adjacent cue clearance and mild elevation, not only spectacular jump/masse shots |
| Tip selection | 0.5-radius disk clamp, visual marker; no numeric fine adjustment in inspected pad | Discoverable valid region, center reset, fine positioning, stable selected offset and explicit unreachable input |
| Power | Slider step .005, minimum .01, percent rounded to integer; affine cue-speed mapping | Perceptual and physical resolution, low-end sensitivity, misleading rounded readout, and cue pullback equivalence |
| Aiming | Geometric guide using direction and ball intersections | Honest distinction between direction aid and predicted trajectory; squirt/throw/spin consistency |
| Cloth | Constant sliding/rolling/spinning coefficients and slip threshold | Transition continuity, residual spin, slow roll, speed dependence if data supports it |
| Ball collision | Normal restitution plus capped tangential impulse | Throw regimes, spin transfer, frozen contacts, speed dependence, simultaneous contact and sensitivity |
| Cushion | Radial nose contact and friction impulse | Normal/tangent coupling, rebound spin, rail-induced hop, compliance and speed/angle response |
| Pockets | Mouth/jaw segments and immediate fall classification | Shelf support, facing shape, rejection, rattles, capture timing and coherent falling motion |
| Rest | Velocity/spin thresholds and snapping | Last visible millimeters, spin-in-place, ready-to-shoot timing and no perceptible pop |
| Audio | One clip per event kind, speed-driven pitch/volume, 12 voices, global ball debounce | Contact-dependent timbre, dense break texture, spatial placement, tails and perceptual dynamic range |
| Balls | Smooth spheres, fixed roughness/clearcoat, procedural stripe and block digits | Convincing resin, reflections and contact shadows, legible identity without falsifying rotation |
| Cloth appearance | High-frequency sinusoidal albedo variation | Correct texture scale, antialiasing, directional response if appropriate, and motion stability |
| UI | Fixed panels, generic buttons, power/spin controls | Visual hierarchy, table occupancy, input focus, precision accessibility and unobtrusive feedback |

Source anchors: cue_strike_model.gd:apply; game_controller.gd:_on_shoot_requested; game_hud.gd:_build; spin_pad.gd:normalized_tip_offset; table_presentation.gd:set_aim; physics_stepper.gd:_apply_cloth_friction/_resolve_ball_pair/_resolve_rails; table_audio.gd:play_contact; ball_visual.gd:configure; cloth_surface.gdshader.

A particularly important cross-system gap: set_aim receives power but computes the path using geometric direction; spin is not an input. CueStrikeModel can alter the launch direction through squirt. A mathematically valid geometric guide may therefore communicate a promise the actual shot does not fulfill. Decide whether to display a deliberately limited direction aid or an actual predictive aid, then validate and explain that promise. Do not silently make physics follow a decorative guide.

## 4. Physics research at the detail level

### Strike and force vocabulary

A slider percentage is not force. Separate input displacement, cue speed, impulse, initial ball speed, spin and subsequent travel. The player may reasonably expect equal input increments to feel useful rather than to be equal in physical energy. Choose the user-facing meaning, then design a monotone mapping.

For ideal pure rolling with constant rolling deceleration, stopping distance is v²/(2 μ_r g). Doubling speed quadruples distance under those assumptions. A linear speed slider therefore does not provide uniform distance resolution. Use this analytic relationship to design candidate curves, but measure full center-ball shots because sliding precedes rolling. Draw/follow must not be tuned with the pure-roll formula alone.

Research cue-speed response at at least five radial offsets and multiple azimuths. Measure launch speed, angular velocity, squirt, energy transfer and resulting motion. Check combined horizontal/vertical offset, not just independent draw and sidespin. Explore whether power should preserve cue speed or desired ball speed across offset; those are different contracts. The former is more directly physical; the latter is an assist that must be explicit.

### Cloth and spin transitions

Measure slip velocity, spin and translation through sliding-to-rolling transition. Investigate discontinuity at the implementation threshold, terminal creeping, overshoot into reversed slip, and visible stopping snaps. Inspect roll orientation as well as center trajectory. In the roll regime, a marked ball should satisfy the appropriate rolling kinematics within numerical tolerance.

Use long draw, short draw, follow, stun at different travel distances, slow sidespin, and a shot whose spin outlasts translation. Research cloth anisotropy and speed dependence as candidate refinements, not assumed necessities. Decide whether their measured effect exceeds the perceptual and numerical error budgets.

### Ball contacts

Study cut-induced throw, spin-induced throw, gearing conditions and spin transfer over speed/cut/spin grids. A constant Coulomb friction cap is a starting model; it does not by itself establish measured throw behavior. Compare clean-ball reference cases before considering contamination/skid effects.

Include near-grazing contacts, moving balls, frozen pairs, double kisses and clusters. Track first contact time, normal/tangential impulse, transferred spin, outgoing velocity and final position. A correct outgoing angle alone can hide a wrong speed or contact point. Near discontinuous outcomes, evaluate boundary location and sensitivity instead of demanding smooth pocket outcomes.

### Cushions and ordinary elevated play

Map outgoing angle, speed and spin versus incoming speed, incidence and spin. Compare running/reverse english, nearly parallel approaches and slow rebounds. Investigate the coupled cloth/cushion response: a cushion impact can alter vertical and rotational motion, so a single restitution number is not a full quality specification.

Research clearance when the cue ball is close to a cushion or obstructing ball. Decide how legal ordinary strokes are represented before adding advanced elevated shots. Do not introduce a visible cue that passes through a rail while claiming physical fidelity.

### Pockets and rest

Pocket acceptance depends on approach, speed, facing, shelf and spin. Build acceptance maps, including repeatable misses and near misses, rather than a single generous capture radius. Small changes near a pocket boundary legitimately produce different outcomes; success is a physically supported boundary, not universal smoothness.

Study how balls fall, strike lining or other pocket contents, become occluded and finish audibly. Full hidden ball-return simulation may be unnecessary: an event-driven presentation approximation is acceptable if it preserves visible causal timing and cannot alter gameplay outcomes.

## 5. Precision as an error budget

Do not choose precision by asking for the smallest possible epsilon. Allocate error across input, geometry, physical model, numerical integration and presentation.

For a straight path of length L, small angular error δθ produces lateral error approximately Lδθ. At 2m, 0.01° is about 0.35mm; 0.1° is about 3.5mm. These are derived geometric examples, not claims about required human accuracy. The current fine keyboard increment is 0.0002rad, about 0.0115°; evaluate whether pointer handling, camera projection and guide rendering preserve that useful resolution.

Propose an initial research target of <=0.5mm numerical endpoint error for isolated smooth shots, while recording experimental uncertainty separately. At collision or pocket discontinuities, specify contact/boundary error and outcome classification instead. Do not assert 0.5mm real-world accuracy from a solver benchmark.

For each representative shot, estimate how a small change in each parameter changes the endpoint. Rank sensitivities. Spend effort where a parameter meaningfully alters play; avoid tuning an insignificant fifth decimal while cushion response is wrong. Use finite differences on smooth regimes and bracketing near discontinuities. Reserve held-out speed/angle families to expose overfitting.

## 6. Controls that feel like a precise instrument

Beyond fixing aim retention, study acquisition, refinement, commitment, cancellation and recovery. A player should be able to approach the desired line quickly, refine it, alter power/spin, inspect it and commit without losing intent.

Research absolute pointer aiming versus relative drag, coarse/fine modifiers, pointer sensitivity across zoom/DPI, keyboard accessibility, click/drag thresholds, clamping at UI edges, and behavior after focus loss. Measure target acquisition time, overshoot, accidental commits and repeated-shot variance. Do not smooth input by default: smoothing can hide jitter while adding lag.

Inspect the low-end power curve densely. Adjacent usable levels should not jump across a desired short landing zone. Define a proposed task: place an unobstructed cue ball at 5, 10, 20, 50 and 100cm target distances repeatedly. First measure machine-selectable resolution, then human achievable precision. Separate training effects from interface limitations. A UI that permits exact values but makes them hard to select is not complete.

For spin, provide a visible center, a meaningful reachable boundary, reliable reset and precise incremental adjustment. Test diagonals and near-boundary selections. Decide whether selected spin persists between shots; never silently reset it inconsistently. Position the cue tip consistently with the selected contact point or clearly communicate when the diagram is abstract.

Prototype cue pullback and forward stroke curves. Judge perceived weight and exact contact synchronization, not animation duration alone. Strong and soft strokes should read differently without unnecessary waiting. Cancellation must be predictable before commitment; after commitment the simulation must receive exactly one shot.

## 7. Visual craft and temporal quality

The target is a coherent table that survives normal play, zoomed inspection and motion. Photorealism is optional; material credibility and visual clarity are mandatory. Pick an original direction with a visual hierarchy before adding assets.

- Geometry: believable rail proportions, cushion nose, facings, pocket openings, shelf edges and bevels; no impossible joins or black disks hiding missing depth.
- Balls: consistent diameter, resin-like highlight shape, readable stripe widths, clean number patches, smooth silhouettes, subtle imperfections only where visible and licensed/original assets.
- Cloth: believable weave scale and color, stable fine detail, no moire or procedural banding. Avoid adding noisy texture as a substitute for lighting.
- Lighting: stable exposure, coherent light sources, reflection cues that describe curvature, shadows that ground balls without double-dark contact blobs. Inspect dark balls beside rails.
- Camera: table readable without exaggerated perspective, stable framing, predictable zoom and transitions, correct picking throughout transition; never lose the selected shot due to camera animation.
- Motion: rotational continuity, no stair-step translations, no interpolation through a collision or teleport, no incorrect shadow beneath a falling ball, no highlight flicker during slow rotation.
- UI: readable typography at supported scaling, quiet hierarchy, consistent spacing, no control masking a needed sightline, precise rather than misleading rounded values.

Create a frozen visual test deck with adversarial scenes: black eight beside dark rail; striped ball with number facing away; slow diagonal roll over cloth; dense rack; corner pocket entry; cue beside cushion; lounge camera with UI; minimum window; high DPI. Judge both stills and video. Screenshot approval is insufficient for motion stability.

Godot documents that interpolation can reduce jitter but adds latency. Because this project manually advances a custom simulation in _process, enabling a project setting is not evidence that BallVisual has correct interpolation. Investigate explicit previous/current state sampling and discontinuity resets, and verify latency before choosing a solution.

## 8. Sound and tiny timing cues

Sound communicates speed, hardness, location and contact order. Research normal impact speed or impulse as an audio driver, not merely arbitrary speed-to-pitch scaling. Use several subtle variants only if they sound like the same material. Variation must not obscure physical consistency.

Compare sparse clicks, rail thuds, a pocket drop and a break. The current global 16ms suppression removes closely timed ball events; a better policy should suppress duplicate solver events without erasing distinct physical contacts. Consider energy-aware voice priority, tail preservation and restrained spatialization. Measure clipping and headroom during breaks, intelligibility at low volume, repeated-shot fatigue and sound-off usability.

One-frame synchronization is only an initial ceiling. Proposed laboratory target: <=10ms difference between visible contact and sound onset where equipment permits measurement, with hardware audio latency separately recorded. Choose acceptable bounds using perceptual comparison; do not confuse engine timestamps with sound reaching the listener.

## 9. How to earn a claim of excellence

Establish a documented set of reference products, clips and real-table shots. Aim for best-in-set performance on each chosen axis rather than copying one competitor wholesale. Physical reference, competitor feel and owner art preference are different evidence sources.

Run paired comparisons on identical tasks with randomized order. Include experienced players and novices; report their results separately. Ask whether they can predict and intentionally reproduce outcomes, not only whether screenshots look attractive. Measure short-shot placement, aiming errors, time to commit, accidental input, perceived contact weight, material credibility and overall preference. Small panels are formative; do not turn them into population-wide claims.

A high bar must survive adversarial cases and repeated play. Require: no critical honesty/coherence failures; all frozen physical/numerical contracts pass; representative experts can recognize and reproduce the intended shot families; visual and audio defects above the agreed severity are resolved; comparison results show no material deficit on chosen core axes. Freeze the comparison set and material-deficit margins before evaluating the final candidate.

Do not ship a single weighted score. Publish the quality matrix, confidence, exceptions and raw evidence links. A strong preferred look does not waive unexplained spin response.

## 10. Evidence sources consulted for this exploration

- Dr. Dave technical proof index: https://drdavepoolinfo.com/technical-proof/ — use the original derivations to identify distinct shot mechanisms, not a universal table preset.
- Dr. Dave TP B.6: https://drdavepoolinfo.com/technical_proofs/new/TP_B-6.pdf — a research entry point for rolling-distance relationships and stated parameter assumptions.
- Dr. Dave squirt/swerve/throw discussion: https://drdavepoolinfo.com/bd_articles/2008/aug08.pdf — distinguishes related effects; retrieve specific proofs and measured demonstrations before implementation.
- Swerve and masse reference: https://billiards.colostate.edu/resource_files/masse.pdf — advanced mechanism research; not evidence that every effect belongs in the next release.
- Godot jitter/stutter/input-lag documentation: https://docs.godotengine.org/en/latest/tutorials/rendering/jitter_stutter.html — timing tradeoffs; verify applicability to the pinned engine and custom runtime.

These sources guide research. No current competitor build was played in this pass, and no claim of parity or superiority is established.
