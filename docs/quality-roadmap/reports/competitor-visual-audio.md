# Competitor observation: visual design and audio

Observed 2026-10-31. Dedicated visual/audio pass; no physics or control-precision conclusions. Only this report was authored in the repository.

## Evidence and confidence

**Observed** means directly visible in the named images/chronological frames, or explicitly present in local source. **Inferred** means a design interpretation. **Unknown** means the available evidence cannot establish it.

The reference is actual official Miniclip gameplay/tutorial imagery, rather than a description generated from search results. The [Spins article](https://support.miniclip.com/hc/en-us/articles/35451960569361-Advanced-Plays-Spins-8-Ball-Pool) and [Basic Controls article](https://support.miniclip.com/hc/en-us/articles/35451942766865-Basic-Controls-Improving-your-skills-8-Ball-Pool) were also retrieved to establish provenance. These assets show a Portuguese HUD and apparently a timed practice/Quick Fire presentation. Exact platform, build, capture date, and whether demonstrations were edited are **unknown**. They do not establish how every current Miniclip table looks.

Sources inspected:

| ID | Official source | Inspected evidence |
|---|---|---|
| T | [Table controls image](https://support.miniclip.com/hc/article_attachments/35451926199441) | `/tmp/8ball-reference/table.jpg`; full table, rack, guide, rails and pockets. Red control callout circles are tutorial annotations. |
| B | [Backspin GIF](https://support.miniclip.com/hc/article_attachments/41975216548625) | 800×370, 14.64 s. Independently extracted chronological sheet at 2 samples/s: `/tmp/8ball-reference/visual-observer/backspin-halfsec.png`. |
| C | [Combined-spin GIF](https://support.miniclip.com/hc/article_attachments/41975201180817) | 16.60 s. Independently extracted chronological sheet at 1 sample/s: `/tmp/8ball-reference/visual-observer/combined-sec.png`. |
| S | [Side-spin GIF](https://support.miniclip.com/hc/article_attachments/41975201179665) | Existing chronological one-second contact sheet `/tmp/8ball-reference/sidespin-1s.jpg`. |
| F | [Topspin GIF](https://support.miniclip.com/hc/article_attachments/41975216546321) | Existing extracted frame `/tmp/8ball-reference/topspin-2.png`, 2 s into asset. |

Sheet offsets below are nominal output sample times, read left-to-right then top-to-bottom. Resampling can choose a nearby source frame; allow roughly half a sample interval. GIF offsets describe the supplied animation, **not input latency, a live match clock, or measured animation duration**. Upscaling aids inspection without adding original detail. Temporary evidence files are not durable repository artifacts; source URLs permit reproduction.

Local comparison images: `captures/shared-geometry-overhead.png` and `captures/reflections-lounge.png`, both 1600×900. Their capture-time state is the comparison baseline; current source was inspected separately.

## Direct visual findings

| Area | Reference observation | Local difference and interpretation |
|---|---|---|
| Surface and edge separation | **Observed, T:** cyan cloth has a broad bright center and darker perimeter, fine visible mottling, a distinct light inner cushion edge, reddish rails with small bright sights, and dark circular/rounded pocket wells. | **Observed:** local green cloth and brown rails are quieter; corner and side openings have visibly angular jaws. **Inferred:** Miniclip's strong value separation makes each material boundary easier to parse immediately. Local muted wood/cloth supports the club atmosphere; adopting cyan or round-looking openings is not required and must not detach render geometry from collision geometry. |
| Balls and grounding | **Observed, T and B 0–4 s:** saturated ball colors, bright small highlights, contrasting number patches and dark lower/right edge shading keep tiny balls distinct. Individual digits are not reliably legible throughout the compressed GIF. | **Observed:** local numbered caps are readable in these larger captures; balls have compact contact shadows and glossy highlights. Local green/6 and dark 7/8 deserve deliberate contrast checks against green cloth. **Inferred:** current palette cohesion costs some instant separation; brighter color/value separation can help without copying reference artwork. |
| Rotation | **Observed, C 7–15 s:** the moving red/white ball presents visibly changing white patches while travelling; it does not retain one fixed screen-facing marking. Stationary blue ball appearance stays comparatively stable. | **Observed in source:** `BallVisual.sync_from` assigns physical orientation to the ball node and keeps the shadow separate. **Unknown:** competitor rotation axes, slip accuracy, texture implementation, and exact revolutions. Local stills alone cannot verify motion quality. The useful target is perceptible coherent markings during slow roll, rather than an invented competitor rotation constant. |
| Camera and frame | **Observed, S sheet and F 2 s:** overhead table remains fixed while aim/spin state changes. Side meters and a compact top HUD frame the playfield. | **Observed:** local overhead view includes substantial instructional text and a large right panel; lounge view adds table thickness and legs. **Inferred:** reference prioritizes spatial continuity and immediate play; local view prioritizes learning and atmosphere. Retain both strengths by checking that essential information remains readable without overwhelming the table. |
| Guide visual weight | **Observed, T:** fine pale line with a dark outline and hollow contact ring. **Observed, F 2 s:** the same hollow endpoint treatment is visible against the rack. | **Observed:** local guide is a thin ivory line with a filled translucent ghost sphere. **Inferred:** the hollow reference endpoint preserves the underlying ball/cloth boundary better; the local ghost communicates physical ball size but can resemble another ball. Any guide refinement should retain the local documented first-contact scope. No outgoing-path accuracy claim is made here. |
| Spin feedback | **Observed, C 1–3 s:** enlarged shaded cue-ball face, red hollow marker, and dimmed table; after dismissal the corner cue-ball icon retains an off-center marker. | **Observed:** local spin pad is permanently visible, with crosshairs, a solid tip dot and adjacent explanation. **Inferred:** reference concentrates attention during selection and preserves a compact reminder; local allows fast adjustment without a modal interruption. A persistent, unambiguous off-center state is the transferable goal. |
| Shot/pot feedback | **Observed, B about 7.5–10 s:** cue/guide leave the table during motion; a potted purple ball subsequently travels down the visible right return track. Score changes from 200 to 300 and another recent-ball icon appears. | **Observed:** local screenshot presents a count and instructions, with no visible return track. Source updates score/status and hides setup visuals during motion. **Inferred:** reference turns a pot into a small readable sequence—entry, retained ball identity, progress—rather than only a counter. A restrained local equivalent could suit practice; the timed mode's score/time rewards need not transfer. |

## Small motion details worth preserving or testing

**Observed:** B 4.5–6 s shows the enlarged spin control appearing over a dimmed table, with the target marker moving downward. B 8–13.5 s makes the potted ball's onward travel visible independently of cue-ball motion. C 5–15 s keeps the table/camera stable during a multi-ball sequence. These are compositional continuity observations, not measurements of easing or collision physics.

**Inferred priorities:** first improve identity and state continuity at ordinary play scale, then subtle material richness. Stronger reflections alone will not answer whether the dark ball is distinguishable, the selected spin is remembered, or a pot reads clearly. Local restrained colors and perspective camera are legitimate design choices, not automatic quality deficits.

**Unknown:** high-refresh cadence, motion blur, exact pocket shrink/fade treatment, cue release-to-contact timing, and whether a live client contains additional celebrations or accessibility options. Sampling these small compressed assets cannot settle them.

## Audio: unobserved competitor, inspected local implementation

**Unknown:** competitor sound character, layering, loudness, stereo placement, variation, and synchronization. GIFs contain no audio. This observer did not hear an official gameplay source. A native Brave attempt to reach an official trailer was blocked by the locked Mac; automatic unlock failed. The proposed trailer [Miniclip 8 Ball Pool](https://www.youtube.com/watch?v=MarGQrmbPm0) was therefore **not played or used as sound evidence**. Even audible trailer music would not establish isolated gameplay effects.

**Observed in local source, not listening:** `scripts/presentation/table_audio.gd` loads four WAV event classes, rotates twelve non-positional `AudioStreamPlayer` voices, maps speed to volume/pitch, and suppresses ball events within 16 ms of the last ball event. `tools/generate_audio.py` creates short mono decaying sine/noise effects: ball 0.13 s, rail 0.17 s, cue 0.18 s, pocket 0.32 s. This is an implementation inventory, not an assessment of their audible realism. `scripts/app/game_controller.gd` routes cue sound through the stroke contact callback and routes simulation contact events to audio.

Concrete next listening protocol:

1. Open an authorized, playable official practice client with sound enabled and confirm actual audible playback; record platform/build, cue, audio setting and source. If only a video is available, verify continuous unmixed gameplay and record exact source timecodes.
2. At one fixed output volume, record isolated soft/medium/hard cue hits, separated ball contacts, cushion contacts, a clean pot and scratch, then a dense break. Repeat each isolated event five times. Listen for timbre, decay, intensity scaling, variation and whether dense contacts mask useful events.
3. Capture system audio and video in one recording. Mark first visible contact and waveform onset for each event; report capture resolution and repeated offsets rather than claiming device latency. Separately listen for room tone/music and whether controls have sounds.
4. Repeat the same local shot classes and levels. Compare normalized clips for timbre separately from original-level clips for mix balance. Verify mute silences every class, rapid events do not steal crucial cues, and soft shots remain audible without making breaks harsh. Do not assert parity until both listening sets exist.

## Repository anchors and suggested test targets

| Target | Current anchors | Smallest useful verification |
|---|---|---|
| Ball identity, rolling, grounding | `scripts/presentation/ball_visual.gd:7`, `:39`; `assets/shaders/ball_surface.gdshader:9` | Capture all 15 balls overhead and lounge at normal viewport sizes; separately record slow straight/diagonal rolls and a rolling striped ball approaching a pocket. Check number-cap continuity, shadow attachment, contrast and shimmer. Source orientation alone is not a visual pass. |
| Cloth/rail/pocket readability | `scripts/presentation/table_presentation.gd:111`, `:159`, `:231`, `:286`; `assets/shaders/cloth_surface.gdshader:6` | Review matched bright/dark ball placements beside every pocket and along rails. Preserve physical mouth boundaries; compare stationary and slow camera movement for cloth/wood aliasing. |
| Guide endpoint clarity | `scripts/presentation/table_presentation.gd:63`, `:358` | Render a dark ball, striped ball and close cluster under the endpoint in both cameras. Ask a fresh observer to identify actual cue/object balls versus preview marker; retain guide-off checks. |
| State and pot continuity | `scripts/ui/game_hud.gd:39`, `:142`, `:151`; `scripts/app/game_controller.gd:59`, `:228` | Record setup → stroke → motion → pot → ready in one shot. Verify guide/cue disappearance, selected-spin reminder, one progress update per pot and a clear ready state; evaluate at the smallest supported window. |
| Audio behavior and synchronization | `scripts/presentation/table_audio.gd:9`, `:19`; `scripts/app/game_controller.gd:65`, `:191`; `tests/render_contact.gd:32` | Extend the existing rendered-contact evidence with recorded audio onset; its current result explicitly excludes audio-device latency. Audit mute, repeated simultaneous contacts, low-speed audibility and voice reuse using actual listening plus waveform inspection. |

No game changes, new acceptance claims, or competitor parity claims follow from this pass. The strongest directly supported opportunities are clearer edge/material hierarchy, ball identity across motion, and richer but restrained pot/state continuity. Audio remains a distinct open evidence requirement.
