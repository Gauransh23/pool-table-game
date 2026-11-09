# Why the practice game still falls short

2026-11-06. Source baseline: 23cb30f. This is a fresh source/design assessment, not a new live playtest or listening session. Prior live observations are attributed to PRESENTATION_REBUILD_PLAN.md. Competitor controls were checked against official Miniclip documentation. Hypotheses below require measurements; no commercial parity claim is made.

## Core diagnosis

The project has implemented many ingredients of pool without establishing the quality of the complete perception–action loop. The player must be able to see a shot, express an intention precisely, predict the useful consequences, feel the strike, understand the collision, and learn from the result. Each ingredient can pass isolated correctness checks while the combined experience remains weak.

The existing presentation handoff is useful but insufficient. Its instruction to preserve power mapping and coefficients is appropriate for a bounded artwork change, not a conclusion that these parameters are good. Reopen them in a separate calibration checkpoint. Preserve reproducible baselines, not unvalidated assumptions.

## 1. Control precision is not player precision

Source: game_controller.gd::_update_aim_direction points directly from cue ball to pointer. Only a 20 mm world-space dead zone guards the origin. The same pointer movement therefore produces a much larger angle change near the cue ball than far away. Arrow keys offer 0.001 rad steps and Shift reduces that to 0.0002 rad, but this does not make ordinary mouse aiming uniformly controllable.

At 100 screen pixels from the ball, a one-pixel perpendicular displacement is approximately 0.57 degrees. At 500 pixels it is approximately 0.115 degrees. These are geometric examples, not measured UI latency. Tiny adjustments can therefore feel jumpy despite precise numerical state.

Required experiment: compare direct aim with a dedicated relative fine-aim gesture or wheel, with documented sensitivity and cancellation. Measure endpoint error and adjustment time on thin cuts and long shots at multiple window sizes. Preserve direct coarse aiming. Do not add smoothing that trails the user's intention without measuring the delay.

Official Miniclip controls explicitly expose aiming-wheel/sensitivity and power-bar preferences. That demonstrates attention to input ergonomics, not evidence of superior underlying numerical precision.

## 2. The aim guide leaves the crucial decision unexplained

Source: table_presentation.gd::set_aim draws the initial ray and a filled ghost at first object contact. The source explicitly omits an outgoing ray because it would omit frictional throw.

Avoiding a misleading prediction is correct, but stopping there leaves a major usability gap. The player is trying to select where the object ball goes and where the cue ball finishes. A visually precise contact point does not explain either. This is especially costly when the physics includes throw and squirt that the player has little help understanding.

Implement a clearly scoped assistance mode: hollow contact marker, short object departure and cue departure indicators from the active collision model, with explicit truncation at the supported prediction horizon. Validate against actual shots across cut, speed and spin. Do not draw confident full-table trajectories from a simplified model. An optional practice explanation can expose why spin changed the result without cluttering normal play.

## 3. Power is specified as a formula, not established as a usable instrument

Source: stroke_power.gd maps p to 0.075 + 7.925*p² m/s for positive p, and zero to zero. HUD increments p by 0.005. The first nonzero setting therefore jumps to about 0.0752 m/s cue speed. Half-scale is about 2.056 m/s, roughly 26% of maximum cue speed. Near full scale a single HUD increment changes cue speed by about 0.0791 m/s; near zero it changes by much less.

A quadratic curve is not inherently wrong. The unanswered question is whether it distributes useful shot outcomes well: feather touches, position shots, medium pots and breaks. Percentage does not communicate travel distance, and equal percentage increments do not imply equal energy or stopping-distance increments. Tip offset also changes launch speed through the strike model.

Measure a power-to-outcome atlas using actual HUD settings: initial ball speed, sliding distance, rolling distance, stopping time and cue-ball leave after representative contacts. Include zero-to-first-setting and spin-dependent response. Choose the curve based on controllability in these shot families. Do not tune friction to hide a poor input mapping.

## 4. Physics complexity has outrun calibration evidence

Source: physics_config.gd labels its coefficients as starting/calibration inputs. Ball and cushion restitution and friction are constants. Cloth uses separate sliding and rolling regimes. The code includes angular impulse, squirt, nose-height cushion contacts and pocket support loss: this is substantive machinery, not proof of accurate response.

Missing evidence is most consequential at the boundaries: sliding-to-rolling transition, slow stopping, thin collision throw, draw-to-stun-to-follow transition, running/reverse side on banks, jaw rebounds, and hanging balls. Those are where skilled players form trust.

Calibrate isolated mechanisms first. Measure straight roll and slide, then direct collision, cut collision, clean rail bounce, spin rail bounce, and finally pocket acceptance. Use uncertainty bands and multiple starting conditions; fitting one attractive shot is insufficient. Keep physical calibration distinct from a deliberately forgiving gameplay profile. Miniclip's cue stats affect force and spin, so reproducing its behavior is not synonymous with simulating a regulation table.

## 5. A 480 Hz update is not a precision certificate

Source: physics_stepper.gd integrates positions, then processes overlaps in array order for up to six passes. It estimates an earlier impact normal for overlapping pairs, but does not advance the world to each event time. Nonoverlapping end positions exit before that estimate. Travel substeps reduce risk but do not prove all grazing contacts or dense contact sequences are handled correctly.

Potential consequences needing reproduction: grazing misses, cluster order sensitivity, altered post-impact remaining travel, and sensitivity to step size. These are hypotheses from algorithm structure, not newly reproduced failures.

Before promoting or replacing a solver, compare mirrored layouts, permutations of ball storage order, grazing contacts, frozen clusters, simultaneous contacts and timestep refinements. Measure outgoing angle, event order, residual penetration, energy and final position. A stable break is not evidence of accurate thin cuts. Retain failed fixtures and numerical convergence reports.

## 6. Render and audio timing are part of perceived physics

Source: game_controller.gd advances all elapsed fixed ticks in _process, drains events, then syncs ball transforms. BallVisual copies current simulation state directly. There is no interpolation in this source path. A small fixed step limits quantization, so absence of interpolation alone does not establish visible stutter. Frame stalls and catch-up work must be measured.

Audio events from many simulation ticks are delivered together after advance. A delayed frame can compress distinct contacts into one audible batch. TableAudio uses twelve round-robin players, one sample per category, speed-driven pitch/gain, no contact-position input, and no salience policy. Voice reuse can interrupt a previous tail. Pocket speed is floored to 1.0 in the controller, reducing the distinction between very gentle pocket entries.

Measure frame intervals and event-to-render/audio scheduling under slow rolls and dense breaks. Record physical event time separately from delivery time. Evaluate interpolation only if measurements justify it, with no blending through collision discontinuities. Add contact-type and intensity layers, sample variants, spatial cues and an explicit voice-priority/fade policy. Listening remains mandatory; scheduling assertions do not establish timbre or weight.

## 7. The strike fails to express the requested energy

Source: delivery always takes 75 ms after a 25 ms backswing; rest pullback varies linearly with power. It ends in a brief hold and disappearance rather than a developed follow-through. The physical contact callback is a sound architectural improvement, but the animation has little expressive range.

Tune pullback, acceleration, contact and follow-through as one gesture, matched to soft, medium and break shots. Keep impulse timing exact and cancellation safe. Compare apparent cue speed with the launched response. Avoid decorative camera movement that compromises aiming or hides the result.

## 8. Readability needs its own specification

Prior live review reports block-like rails, angular mouths, weak material separation, obscured number caps and near-rail occlusion in the lounge camera. Source confirms physically rotating ball identification, a filled guide ghost and 3D presentation. A physically honest number texture can become unreadable in play. Detailed geometry can still have a poor silhouette.

Design at actual screen-space ball size. Establish solid/stripe and dark-ball recognition, pocket opening readability, contact-shadow grounding and unobstructed near-rail play before adding texture complexity. Use optional identification aids without falsifying physical rotation. Judge moving clusters, not only rack screenshots. The handoff's proposed teal/wood palette is an art proposal, not evidence that palette alone fixes the experience.

## 9. The loop offers too little deliberate practice

The controller presents open practice, strokes and pots, and generic post-shot status. Even before a full match mode, players need repeatable situations that make mastery visible: save a shot, retry the identical setup, select a target leave zone, compare actual outcome with intention, and practice a short progression of cuts and speed control.

Undo helps but is not a complete training loop. Implement a small set of curated drills with immediate, legible results. Do not substitute currencies, menus or cosmetic inventory for a satisfying shot.

## Revised execution order

1. Create a baseline experience reel and fixtures: feather pot, long straight pot, thin cut, stun, draw/follow, running/reverse bank, jaw rejection, hanging ball, dense break, scratch recovery. Capture input, simulation state/events, frames and audio. Use the actual exported app. Record what is measured and what is only judged.
2. Complete one playable vertical slice: fine aim, usable assistance, tactile power control, coherent strike, readable balls/pocket, and layered contact sound. Apply it to three balls and one pocket first. Compare identical situations before spreading changes to the whole table.
3. In parallel with visual iteration only where ownership allows, establish power/outcome and physics calibration evidence. Change one mechanism at a time. Solver replacement requires demonstrated improvement on the cases above.
4. Evaluate with users on aim accuracy, power repeatability, time to set a shot, ability to explain misses, material recognition and perceived weight. Compare against a recorded Miniclip session with platform/cue/assistance settings documented. Do not infer hidden coefficients from video alone.
5. Integrate repeatable drills and a coherent session loop. Then broaden to match play and other features.

## What would change the diagnosis

If measured input and calibrated physics are already excellent but users still dislike the game, prioritize presentation/audio and task flow. If visually improved builds remain hard to control, prioritize input and power response. If identical intended shots give unexplained or storage-order-dependent results, prioritize solver/calibration. This prevents all dissatisfaction being assigned to artwork or all of it being assigned to physics.

The immediate deliverable should be one demonstrably better minute of play, with matched evidence. More target documents, higher solver frequency, extra shaders and larger assertion counts do not individually prove that result.

## Official competitor references checked

- https://support.miniclip.com/hc/en-us/articles/203747546-How-to-Aim-with-the-Cue-8-Ball-Pool
- https://support.miniclip.com/hc/en-us/articles/360020665798--How-to-start-playing-8-Ball-Pool
- https://support.miniclip.com/hc/en-us/articles/35451960569361-Advanced-Plays-Spins-8-Ball-Pool
- https://8ballpool.com/news/pro-tips-cue-stats

This pass did not play a live competitor match or listen to either game. Fresh perceptual comparisons remain required. Source-derived risks must not be reported as observed failures.
