# Presentation rebuild — execution handoff

Status: planned, not implemented. Written 2026-11-06 against `daabb6e96703c03900ab2827fd5edf9d67c1fef8` (0.3.1).

## Owner direction and execution constraints

The owner approved improving the existing Godot game rather than starting an Apple-native port. They then requested documentation only because usage limits were close to expiring. Resume implementation only when requested.

- Work directly on `main` in `/Users/gt/Documents/My Public repos/Pool table game`.
- Do not create branches or worktrees. The owner explicitly prohibited both.
- Use cheaper implementation agents with `superpowers:subagent-driven-development`; the lead owns design decisions, integration and final visual assessment. Use a standard model such as Sol for prose-driven implementation; reserve Luna for small, fully specified mechanical changes. Give each agent a fresh, bounded task and exact working directory. Review each task before proceeding.
- Preserve the active GDScript physics engine, equipment dimensions, ball radius, power mapping, coefficients, save/undo behaviour and keyboard access. Do not promote the experimental solver.
- Read `AGENTS.md`, `QUALITY_TARGETS.md`, `targets/02-controls-and-presentation.md` and relevant `TEST_PROTOCOLS.md` sections. Do not lower thresholds or equate regression counts with commercial quality.
- Preserve the existing 0.3.1 bundle and installer; package a separately versioned candidate after validation.

No gameplay source was changed during this planning turn. An unused managed worktree was created immediately before the owner prohibited it. The app refused to archive it because it considers it the chat's primary checkout. It is not the implementation destination; always pass the original directory explicitly.

## Goal and chosen approach

Deliver one convincing, readable offline practice table with a satisfying aim → power → strike → settle loop. Feature quantity is secondary. Keep Godot and improve the artwork, camera, controls, animation and sound together. Godot already supports Metal; switching language alone would not solve the observed weaknesses.

Alternatives considered: Swift/SpriteKit for an overhead 2D game; Swift/RealityKit for Apple-only 3D; a custom Metal renderer. All require substantial presentation work as well as a port. Reconsider only after a matched prototype demonstrates an engine limitation that matters to this game. Do not start a SceneKit port.

Art direction proposed by the lead: overhead-first, clean tournament-table presentation with rich teal cloth, dark finished wood, restrained warm metal accents, bright readable resin balls and compact controls. This palette is an implementation proposal, not a separately approved mockup. Prefer coherent material contrast over decorative complexity.

## Evidence from the live review

The lead opened the exported 0.3.1 app, adjusted power, played a shot, used Undo and inspected both camera views. The saved table was restored and power returned to its original setting.

- The app was running successfully. The previous assistant's assertion that it exited immediately was not established and is contradicted by this live review.
- Rails resemble assembled blocks; pocket mouths and transitions are visibly angular.
- The low-contrast green/brown palette weakens material separation and ball prominence.
- Ball markings become hard to identify as their physically rotating caps face away. Physical rotation must remain honest.
- A large sidebar and ordinary slider/button make stroke setup resemble a utility panel. The panel contains substantial unused space.
- The filled guide ghost can be mistaken for a real ball.
- In the lounge camera, the near cushion partly obscured a ball beside the rail.
- Source uses a fixed 25 ms backswing, 75 ms delivery and brief contact hold. This limits expressive stroke animation.
- Audio uses one sample per category, varied by speed-based gain and pitch. This is a source finding, not a completed listening comparison.

Competitor evidence is documented in `reports/competitor-visual-audio.md` and `reports/competitor-user-controls.md`, based on official Miniclip imagery. A fresh matched live latency/audio comparison has not been completed.

## Implementation sequence

### 1. Establish the visual slice

Owner files: `scripts/presentation/table_presentation.gd`, `ball_visual.gd`, `assets/shaders/`, original visual assets and capture fixtures.

Create three original keyframe alternatives and choose a coherent direction through lead review. First finish a pocket plus three-ball slice before applying it to the whole table. Improve rail silhouettes, bevels, recessed lining and material transitions. Keep visible openings aligned with shared table geometry; do not cover invalid geometry with black circles or change pocket acceptance to suit artwork.

Improve light/value separation between cloth, rubber, wood, lining and balls. Control high-frequency textures and reflections at actual gameplay scale. Keep physical ball dimensions and orientation. Provide an optional nonphysical identification aid for hidden number caps without altering simulation state. Replace the aiming ghost with a clearly distinct hollow contact marker; retain the separate translucent placement preview and prediction scope.

Make the overhead camera the primary playing view. Adjust the lounge view to preserve near-rail ball visibility, or clearly treat it as a presentation view rather than promising equivalent playability.

Targets: VIS-001/002/003/004/005/006/007/009 and AIM-006. Capture rack, spread, dark balls at rails, stripes facing away, cluster under guide, six pockets, and both cameras at 1100×700 and 1600×900. Keep before/after captures. Human recognition/material ratings remain unverified until actually measured.

### 2. Rebuild the stroke interaction and feedback

Owner files: `scripts/ui/game_hud.gd`, a focused custom power control if needed, `scripts/app/game_controller.gd`, cue-animation methods and input tests.

Replace the large permanent sidebar with compact controls around the table. Prototype a slim pullback power control whose movement visibly retracts the cue. Keep the same power-to-cue-speed mapping and numeric precision. Preserve the explicit Take Shot/Space path initially; adopt release-to-shoot only after cancellation and accidental-release behaviour are specified and tested. A focus loss, menu, resize or cancelled gesture must never fire a shot.

Keep aim fixed when the pointer moves to controls. Show clear retained-aim, power-adjustment, delivery, motion and ready states. Spin selection must retain a visible offset reminder. Keep P/S, Tab, Escape, fine aim, Undo and keyboard scratch recovery discoverable and functional.

Use selected power to shape pullback and delivery, with the physical impulse occurring exactly once at visible tip contact. Add restrained follow-through without delaying readiness or changing simulation. Keep pot/scratch feedback tied to actual events. Do not add camera shake or celebrations that obstruct aiming.

Targets: AIM-001/003/008/009, PWR-001/006, FEL-001/002/003/004/005/006, VIS-008/009. Extend actual Viewport-routing tests for new gestures, cancellation, zero power, focus loss, release outside the control and resize. Preserve existing regression coverage; update tests to exercise behaviour rather than old widget internals. Inspect native mouse and keyboard flows separately.

### 3. Improve contact audio

Owner files: `scripts/presentation/table_audio.gd`, licensed/original `assets/audio/`, audio-generation tooling if used, provenance and audio tests.

Acquire or author convincing ball, cue, cushion and pocket samples with natural variants and distinguishable soft/medium/hard layers. Record provenance/licensing. Do not claim a few procedural tones equal recorded realism. Use a cosmetic RNG independent of simulation. Add subtle event positioning only from valid contact positions and current camera orientation.

Keep the protected contact bus and eliminate audible hard voice-stealing cuts with a bounded, documented policy. Preserve salient cue/pocket events during dense breaks. Muting must silence active tails as well as future events. Use actual listening to assess repetition, material identity and intensity; event scheduling tests alone cannot do this.

Targets: AUD-001 through AUD-008, with explicit limits where calibrated latency or true-peak instrumentation is unavailable. Keep the existing simultaneous-contact regression.

### 4. Integrate, review and package

Run the affected source tests once the final changes are in place: `tests/run.gd`, `aim_controls.gd`, `practice_input_flow.gd`, `practice_flow.gd`, `save_recovery.gd`, `stroke_contact.gd`, `spin_precision.gd`, `audio_contacts.gd`, plus new focused coverage. Investigate failures; do not loosen expectations to make the candidate pass.

Review a native continuous session: aim, retained line, power, spin, cancel, shot, collision, pot, scratch, placement, Undo, menu and resize. Inspect slow rolls, dense breaks, all six pockets and camera transitions. Record frame pacing and input response with honest measurement limits. Screenshot quality does not prove motion or latency quality.

Request an independent whole-change review. Build a versioned universal macOS app and DMG, verify signature and checksum, and launch the actual exported GUI. A headless startup is insufficient. Leave the owner a playable candidate and concise release notes mapping changes to evidence and outstanding limits. Do not claim Miniclip parity without owner comparison and the required perceptual evidence.

## References

- Godot renderers: https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html
- Apple SpriteKit: https://developer.apple.com/documentation/spritekit
- Apple RealityKit migration example: https://developer.apple.com/documentation/RealityKit/bringing-your-scenekit-projects-to-realitykit
- Apple SceneKit deprecation: https://developer.apple.com/documentation/scenekit

These references informed the engine decision; implementation should recheck API details when needed.
