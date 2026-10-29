# Sol implementation contract: earn a good pool experience

Owner: Sol implementation agent. Review: 2026-10-28, baseline 688dda1.
Read this before implementation. The owner rejected 0.2.0 on visuals, physics, sound,
controls and feel. That feedback supersedes the earlier description of a polished
preview. A successful export, attractive screenshot, or large assertion count does
not satisfy this assignment. Keep scope to a practice table until its fundamentals
meet the gates below. No AI, match menus, extra platforms, progression, or content
breadth during this recovery.

## Findings and evidence

1. **Premature pocket capture, reproduced.** `TableSpec.pocket_at()` subtracts a ball
   radius from the mouth plane. A stationary side-pocket ball whose center is still
   27.58 mm inside that plane becomes FALLING. `_classify_exits()` injects downward
   speed; FALLING bypasses ordinary collision resolution. Hanging balls, shelf support,
   jaw rattles and in/out shots cannot emerge from this model.
2. **Render/collision mismatch, source-confirmed.** `table_presentation.gd` draws
   independent pocket disks (0.067/0.072 m radii), a continuous cloth plane, and skips
   visible jaw bodies; `table_spec.gd` creates jaw segments converging to single
   throat points. Changing visual radii did not repair physical mouths or shelves.
3. **Fine control is not stable, reproduced.** `_unhandled_input()` aims on every
   unpressed pointer movement. Keyboard fine adjustments are overwritten when moving
   to the power slider. There is no explicit aim-lock or drag gesture state.
4. **Soft strokes are too coarse, reproduced.** The UI minimum, mapped through
   `.25 + power*7.75`, sends a center-ball shot about 0.399 m on unobstructed cloth.
   Delicate few-centimeter positional touches are unavailable. This is a control
   mapping defect; do not compensate by increasing cloth friction.
5. **TOI label overstates the solver.** GDScript integrates a complete substep before
   resolving overlap, then substitutes a predicted normal. It does not advance to
   impact and integrate the remainder. Its clean cut-direction tests say little about
   contact timing, final positions, clusters, rail/slate coupling, or convergence.
6. **Sound is an engineering placeholder, source-confirmed.** `generate_audio.py`
   produces damped sinusoids/noise. `TableAudio` has one clip per material, no spatial
   position, and a global 16 ms ball-contact suppression gate. A break loses contact
   texture. Round-robin playback can cut a voice mid-tail. No listening or mix gate
   existed. This review does not claim a new listening comparison was performed.
7. **Visual foundation remains schematic.** Reviewed rendered 0.2.0 images show
   flat cloth, coarse rail/pocket construction, black disk wells, weak material
   separation and very small/rotation-dependent number readability. Sine-color
   weave and wood grain alone do not establish convincing materials. Lighting and
   silhouette must be assessed at gameplay scale, not in shader code.
8. **Interaction is disconnected.** Power is a sidebar percentage followed by a
   generic delayed cue tween. Tip selection is not a visible cue contact. Placement
   has no valid/invalid preview. Audio/physics/cue impact timing is not measured.
9. **Save robustness hole, reproduced.** A valid-format IN_PLAY state with 2 m/s
   velocity loads while `_shot_in_motion` stays false, leaving moving state frozen.
10. **Verification gap.** Hundreds of repeated assertions in analytic sweeps are
    useful but are not hundreds of independent behaviors. There is no commercial
    comparison capture, timed interaction evidence, listening panel, representative
    render review, or calibrated physical reference set. Existing docs admit the
    gaps, but the previous stopping decision ignored them.

## Product specification

One excellent, original table with overhead play and optional inspection camera.
Aim deliberately, retain aim while choosing power/spin, execute a readable stroke,
see and hear the exact contact, watch believable rolling/collisions/pocket entry,
and immediately understand when the next shot is ready. Keep Undo and recovery.
All numerical targets below are initial engineering acceptance targets chosen for
this product, not published universal billiards constants. Real table calibration
requires separately cited measurements and their uncertainty.

### Controls and feel (first implementation gate)

- Introduce explicit Idle/Aiming/PowerAdjust/Stroke/Simulating/Placement/Paused
  interaction states. Define allowed transitions in code and tests. Primary mouse
  control: press/drag on cloth to aim, release to retain the line. Fine arrows remain
  available. Pointer travel to UI must never modify a retained line. Add a short
  first-use hint; avoid multiple conflicting shooting gestures.
- Fit a monotone power curve with usable low end. Center stroke on empty cloth must
  support 2–10 cm travel at its lowest nonzero useful settings, intermediate touches,
  and the current full break range. Zero power must not fire. Plot stopping distance
  against at least 21 settings; no reversal, sudden knee or zero-response band.
- Show stroke strength through cue pullback and a compact meter near the action.
  Animate backswing, forward acceleration and contact; apply physics exactly at tip
  contact. No fixed unexplained delay after the visual hit. Freeze captured shot
  parameters during stroke. Menu/reset must safely cancel pending strokes.
- Pointer-to-visible-aim p95 <=33 ms; visual cue contact vs first simulated motion
  <= one displayed frame at 60 Hz. These require frame/input instrumentation,
  not a headless method-call test. Target cue-contact audio onset within 30 ms of
  displayed impact; measure loopback or disclose measurement unavailable.
- Ball placement uses a translucent preview and red/green validity cue. Never place
  through balls, cushions or unsupported pocket shelf. Confirm only valid positions.
- No unrequested camera motion during aim/stroke. Keep cue/object target visible.
  Keyboard shortcuts work after every UI action. Test mouse AND trackpad.

### Physics (shared geometry before aesthetic tuning)

- One immutable table geometry description must generate render meshes, collision
  surfaces, pocket mouths, shelf support/fall edges and aim queries. All six mouths
  agree between visible and collision boundaries within 1 mm in world space.
- Replace region-trigger capture with support/fall-edge behavior and finite jaw
  geometry. Retain appropriate collisions during partial descent. Declare captured
  only below the slate inside the pocket volume. No magnets or downward kick at a
  pre-mouth threshold. Start from WPA dimensions in RESEARCH_NOTES; interpret cut
  angles with a diagram and verify derived geometry, not just parameter values.
- Choose a real impact-time integration strategy. Compare analytic phases/hybrid
  with bounded swept substeps on the SAME scenarios; do not port the current flawed
  stepping wholesale to C++ and call it fixed. Keep rendering independent.
- Quiet analytical fixtures: rolling speed/stopping distance <=1% error, stun-to-roll
  speed/distance <=1%; equal-mass elastic contact conserves momentum/energy <=0.1%.
  Lossy isolated contact must not add energy. Results include angular energy.
- Convergence: compare 240/480/960/1920 Hz or equivalent solver tolerances. For
  isolated collision/rail cases, successive high-quality results should differ by
  <=0.5 mm final position and <=0.1 degree departure. Report the worst case. For
  chaotic breaks do not require identical final layouts; bound energy, penetrations,
  missed events and outcome sensitivity instead.
- Test speed .05/.2/1/3/8 m/s, cut 0/15/30/60/80 degrees, both mirror signs,
  center/follow/draw/side combinations, moving targets, frozen pairs and clusters.
  Include collision timing shifted across the entire step interval.
- Rails need correct nose geometry AND slate reaction/friction during contact.
  Compare a sourced cushion model/reference curve. Prevent unexplained downward
  impulses from simply being discarded next step. No coefficient tuning by eye to
  hide incorrect normals or integration.
- Pocket matrix: each pocket, slow center drop, shelf rest, jaw-first, rail-hugging,
  grazing miss, high-speed rejection and double-jaw contact. Verify event counts,
  support, continuous visible descent and absence of invisible early captures.
- Run 1,000 deterministic seeded breaks after isolated tests pass: all finite,
  no unbounded energy increase, no persistent overlap >0.5 mm after settling,
  no lost balls outside declared lifecycle. Save failing seeds/inputs; do not delete
  outliers. Repeated identical inputs at 30/60/120 rendering Hz must reproduce
  simulation state on this build. Cross-platform determinism remains a separate gate.

### Visual art direction and acceptance

- Establish a restrained premium billiards-room reference sheet: table construction,
  phenolic balls, cloth, leather pockets, cue shaft/tip, and gameplay framing. Compare
  current official Miniclip 8 Ball Pool gameplay at matched viewport size, recording
  date/version/source and interaction clips. Use product observations, not copied art.
  Our previous captures are in build/Preview.png; preserve a baseline before edits.
- Create a coherent hero table with real pocket cutouts, cushion cross-sections,
  rounded jaw lips, recessed liners, and believable rail proportions. Black circles
  laid over a solid cloth plane are unacceptable. Show an unlit geometry view and
  collision overlay alongside the lit view to prove agreement.
- Give balls readable color/stripe/number identity under rotation, a coherent soft
  light reflection and grounded contact shadow. Do not enlarge their physical radius
  to repair readability; tune camera, exposure and marking treatment. If physical
  number decals rotate out of view, optional hover identification must be clear.
- Material detail must survive 1440×900 and 1920×1080, both cameras and Retina scale:
  no moire, z-fighting, floating labels, stair-step edges, plastic-looking wood,
  washed-out whites, crushed colored balls, visible mesh seams or hard shadow blobs.
  Use suitable texture filtering, geometry, reflection environment and tone mapping.
- UI should leave the table dominant. Reduce dashboard-like explanatory text and
  excess sidebar chrome. Strong primary stroke affordance, concise tip/power feedback,
  consistent type scale and intentional hover/pressed/disabled states. No clipping
  at 1100×700 minimum or at Retina scale; controls at least 32 logical px targets.
- Capture fixed rack, spread layout, tight cluster, near-pocket and mid-stroke views,
  plus a 30-second motion clip. Still-image attractiveness cannot waive motion defects.

### Sound and tactile rhythm

- Replace the four generated placeholders with original or appropriately licensed
  recordings, or a validated synthesis approach that passes listening comparison.
  Record provenance/license for every sample. At least 4 natural variants for ball
  impact and 3 for cue/rail/pocket; author soft/medium/hard dynamics rather than
  stretching one tone. Avoid exaggerated pitch variation.
- Drive timbre/loudness from impulse or impact energy; use event position for subtle
  stereo placement. Handle dense breaks with a deliberate voice budget and graceful
  envelopes/voice stealing, not global deletion of every impact within 16 ms.
- Offline mix tests: no clipped samples, final peak <=-1 dBFS, mute silence, monotone
  energy-to-loudness behavior, no discontinuities from voice stealing, stable timing
  at 30/60/120fps. Keep cosmetic variation separate from simulation randomness.
- Listen on Mac speakers AND headphones at matched level. A soft touch must sound
  like contact, a hard break like multiple distinct contacts, a rail like rubber/wood,
  and a pocket like a drop/liner—not four differently pitched beeps. Listening gate
  requires actual reviewer notes; waveform tests alone cannot pass it.

## Perceptual release gate

Use the same five tasks on our build and the recorded reference: delicate tap,
straight pot, thin cut, rail rebound, full break. Have at least the owner plus one
independent reviewer rate clarity, physical plausibility, responsiveness, visual
finish and sound naturalness on anchored 1–5 scales (1 broken/prototype, 3 functional
but visibly rough, 5 coherent commercial finish). Target >=4 in EVERY category,
no category materially worse than the reference, and owner acceptance. These are
judgment gates, not objective measurements. Until reviewers respond, label the build
"candidate awaiting perceptual review"; never self-certify commercial parity.

## Sol execution sequence and deliverables

1. Preserve 0.2.0 captures and run `tests/quality_contract.gd`. Read BASELINE.md.
2. Fix control state/soft power/save validation with behavioral regressions; record
   a short control clip. Do not silently change target values to turn tests green.
3. Implement shared pocket/table geometry and impact integration; add the matrices,
   convergence report and seeded stress harness described above.
4. Refine one hero table and ball set with fixed-camera before/after captures.
5. Author and mix sound; run the audio checks and perform listening review.
6. Test frame pacing in exported release on M4 at 1440×900: 60fps target, p95 frame
   <=16.7ms and p99 <=25ms over 60s idle/shot/break segments. Record warm-up policy,
   renderer, resolution, CPU/GPU timing, RSS and hardware. Instrumentation must use
   frame traces; average FPS alone cannot establish smoothness.
7. Rebuild signed local Mac app/DMG, install/launch from the artifact, exercise all
   five tasks, pause/reset/undo/save-resume, and run an independent defect review.
   Include screenshot/video/audio evidence, test results and known blockers.
8. Stop for owner testing only after automated gates and internal visual/listening
   reviews pass. Request specific perception feedback, and record owner acceptance
   separately. Do not add features to offset a weak core category.

Required artifacts: shared geometry spec/diagram; control transition spec; calibration
source register; machine-readable scenario metrics and failure seeds; reference and
candidate captures; listening notes; release frame trace; installable candidate;
updated quality ledger. Split work into reviewable commits. Keep existing regressions
passing, and mark intentional model changes with reviewed physical evidence.
