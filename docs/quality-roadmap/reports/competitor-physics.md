# Miniclip 8 Ball Pool: qualitative physics observation

**Observed:** 2026-10-31
**Scope:** cue-ball speed/roll, spin, cuts, cushions, pockets, stopping, and breaks.
**Finding:** useful qualitative cues are visible in Miniclip’s official spin demonstrations, but the material does not provide matched initial states or physical units. It cannot calibrate the pool-table-game coefficients or establish numerical parity.

## Observation record

I opened the official [8 Ball Pool web game](https://8ballpool.com/en/game) in Brave. The page loaded the game title screen with the Miniclip branding and Login/guest options. I did not get into a match or manipulate a live table; there are no live-shot observations in this report. Miniclip identifies `8ballpool.com` as its web version and says web and mobile versions differ, so observations from one surface should not be assumed to represent the other.[^web]

I inspected the four animated examples embedded in Miniclip’s [Advanced Plays – Spins](https://support.miniclip.com/hc/en-us/articles/35451960569361-Advanced-Plays-Spins-8-Ball-Pool) article. The article is dated December 16, 2025 and describes the web/mobile spin controls. The animations are 800×370 GIFs. `ffprobe` reports 314 frames/15.79 s for topspin, 291/14.64 s for backspin, and 330/16.60 s each for side and combined spin, at a nominal 239/12 fps. I sampled them at approximately one-second intervals. The GIFs have no audio track.

The direct first-party media links are [topspin](https://support.miniclip.com/hc/article_attachments/41975216546321), [backspin](https://support.miniclip.com/hc/article_attachments/41975216548625), [side spin](https://support.miniclip.com/hc/article_attachments/41975201179665), and [combined spin](https://support.miniclip.com/hc/article_attachments/41975201180817). The article labels these illustrations as topspin, backspin, side spin, and combined spin. These are official instructional animations, not an instrumented recording of a controlled laboratory shot.

## What the animations show

| Clip and approximate elapsed time | Directly visible | What remains unmeasured |
|---|---|---|
| Topspin, 0–1 s | A cue-ball spin selector is enlarged; its red selection marker moves from near center to the upper area. | Marker pixel position does not reveal the game’s normalized tip offset or cue stats. |
| Topspin, about 2–4 s | The view returns to an overhead table with a cue ball and a tight rack aligned for a strong shot; a line runs from the cue ball toward the rack. The next sampled frames show the rack dispersed. | There is no speed readout, frame-synchronized contact point, or fixed-time position log. Break scatter cannot be used to infer launch speed or friction. |
| Topspin, about 5–8 s | The balls continue to move and the on-screen score changes; later sampled arrangements are less clustered than the rack. | The selected cue stat, tip offset, power, initial ball coordinates, score rule, and exact pot events are not recoverable from the GIF. |
| Backspin, about 0–3 s | A partially settled table and an aiming cue are visible; the power meter is also present. | The cue ball and object ball are not labelled with coordinates, and the demo does not show an input trace. |
| Backspin, about 4–5.5 s | The enlarged spin selector appears, with the red marker moving below center in the later samples. | This establishes the intended control selection, not the resulting angular velocity. |
| Backspin, about 6–8 s | Table-ball locations and the HUD score change after the shot sequence. | The sampled frames do not isolate the cue ball through target contact closely enough to measure draw distance or decay. |
| Side spin, about 0–3 s | A cue/aim line points across the table toward a long rail; the enlarged selector appears and the marker moves laterally from center in the next sampled frame. | The trajectory after cushion contact is not recorded at a known scale or time step; the visible guide, cue ball, and object balls make attribution ambiguous. |
| Side spin, about 3–7 s | The guide disappears after the shot; the ball arrangement and score change. | The frames do not expose a controlled no-spin comparison, the rebound angle, or a measured post-rail speed. |
| Combined spin, about 0–2.5 s | The selector marker moves from center toward a lower-right region; the cue and aim line remain visible. | The selected components are shown graphically, but no numeric offsets are provided. |
| Combined spin, about 3–8 s | The overhead ball arrangement changes after the shot and the score changes. | The clip does not isolate which part of the observed path came from follow/draw, side spin, collision throw, or a rail rebound. |

Across these clips, the strongest trajectory observation is the topspin clip’s rack breakup: a cue ball is lined up with a tight group, then the group becomes a broad table spread. In the side-spin example, the aim line extends from a cue ball toward the right-side cushion before the next table state appears. In the other spin examples, the clearest repeatable visual is selection followed by changed ball layouts; the cue ball cannot be followed unambiguously through contact in the sampled frames. A few later layouts persist across adjacent samples, suggesting balls have stopped, but the GIF timing discontinuities make their actual roll-to-rest time unknown. I saw no clean jaw-first rejection or matched slow/fast pocket pair.

The later frames are not a trustworthy clock. In the topspin sequence, the HUD timer moves from about 01:58 down to 01:55, then jumps back to about 02:04; score and table state also jump between samples. That is consistent with edits, transitions, or repeated demo states. I therefore use timestamps only to locate frames within each GIF, not as shot durations or measured decay times.

### Close view: topspin rack contact

I extracted 16 consecutive GIF frames, indices 60–75, around the rack approach. The source frame is 800×370; coordinates below are approximate cue-ball center x values in those original pixels. With the nominal 19.9 fps rate, these frames cover about 3.02–3.77 s of the GIF, but the rate is not a calibrated capture clock.

| GIF frame | Approx. elapsed | Cue-ball center x | Visible state |
|---:|---:|---:|---|
| 60 | 3.02 s | 282 px | Cue ball is on a straight guide toward the rack; rack is still tightly grouped. |
| 67 | 3.37 s | 335 px | Cue ball has moved right along the same line; rack still grouped. |
| 68 | 3.42 s | 388 px | Cue ball continues right toward the rack. |
| 69 | 3.47 s | 412 px | Cue ball remains on the line; rack still appears intact. |
| 71 | 3.57 s | 502 px | Cue ball reaches the front of the rack; its outline is close to/overlapping the front ball. |
| 72 | 3.62 s | not separately trackable | Several rack balls have begun to separate. |
| 75 | 3.77 s | obscured in the cluster | More balls are displaced in different directions; cue-ball identity is obscured. |

So the directly observed event is a cue ball moving roughly 220 source pixels toward a tight rack, followed by visible cluster separation between frames 71 and 72. The cue ball’s post-contact direction, spin transfer, and eventual stop are not separable from the overlapping balls in these frames. The pixel displacement is not a speed measurement: world scale, reliable per-frame delay, game power value, and cue statistics are missing.

The shots are visually plausible examples of a rack break, an aimed shot, and spin selection followed by changed ball layouts. The clips do not clearly isolate a thin cut, a jaw-first pocket miss, a slow roll-to-stop, or a controlled cushion rebound. They show pocket mouths and changing scores, but do not give enough temporal detail to judge jaw rejection, shelf support, capture speed, or pocket acceptance boundaries. There is no basis here for measuring collision coefficients or claiming that Miniclip’s balls conserve any specified energy.

## Vendor description versus observation

Miniclip says topspin carries the cue ball forward after target contact, backspin draws it back, and side spin changes the rail rebound; it also says spin effect depends on cue stats and shot force.[^spin] Those are first-party explanations of intended gameplay. The animations visually show the selector and resulting play sequence, but are not controlled evidence that quantifies those claims.

Miniclip’s current control guide describes web aiming by click/drag, setting force by pulling the cue backward while holding the left mouse button, and releasing to shoot.[^controls] Its web-version article points to the current `8ballpool.com` domain and says the web UI has changed while the game remains the same in broad terms.[^web] I observed the title/login screen only; I did not verify live input, current in-match controls, or current runtime physics.

## Comparison with this repository

This comparison is source-level only; it does not claim that either implementation matches a physical table or that the GIFs validate this code.

| Area | Repository implementation | Evidence gap against Miniclip |
|---|---|---|
| Speed and stopping | `StrokePower.cue_speed()` maps normalized power quadratically to 0.075–8 m/s. `PhysicsStepper._apply_cloth_friction()` handles sliding slip, then applies constant rolling resistance and a separate vertical-spin decay. | Miniclip shows a power bar and says shot force affects spin, but provides neither cue-ball speed nor distance/time measurements. A Miniclip power fraction cannot be equated to this repository’s m/s. |
| Tip contact and follow/draw | `CueStrikeModel.apply()` turns tip offset into an impulse and angular velocity; subsequent cloth and ball-contact steps determine follow/draw. | The official clips show center/top/bottom selection and qualitative paths, but do not expose the tip coordinates, cue stats, launch speed, or collision-time frames needed to test this response. |
| Cuts and ball contact | `_resolve_ball_pair()` applies a normal restitution impulse and a capped tangential friction impulse, including spin coupling. It integrates to overlap and uses a predicted impact normal; it is not a measured Miniclip collision model. | The available GIFs do not provide a matched cut-angle sequence or tracked trajectories. No collision-throw result can be inferred from them. |
| Cushion response | `_resolve_rails()` uses a cushion nose height, restitution, and a friction impulse that can change angular velocity. | The side-spin illustration motivates a rail-spin test but has no measured incidence, incoming/outgoing velocity, or zero-spin control. |
| Pockets and jaws | `TableSpec` defines six mouth/fall/back polygons and provisional shelf/cut geometry. The stepper applies slate-edge and liner handling, waits for descent, and emits a pocket event below the slate. | Miniclip’s drawings show six mouths but do not expose shelf dimensions or slow-motion jaw/shelf outcomes. No Miniclip pocket geometry should be copied from the screenshots. |
| Breaks and end-of-roll | The repository can log full deterministic states and events. Its current break is generated from a fixed rack and a configured cue impulse. | The topspin GIF shows a break-like spread, but the shot power, rack coordinates, cue stats, and replay seed are absent. It is not a numerical break benchmark. |

Relevant implementation references: [physics_config.gd](../../../scripts/sim/physics_config.gd#L6), [stroke_power.gd](../../../scripts/sim/stroke_power.gd#L4), [cue_strike_model.gd](../../../scripts/sim/cue_strike_model.gd#L10), [physics_stepper.gd](../../../scripts/sim/physics_stepper.gd#L154), [physics_stepper.gd](../../../scripts/sim/physics_stepper.gd#L203), [physics_stepper.gd](../../../scripts/sim/physics_stepper.gd#L252), [physics_stepper.gd](../../../scripts/sim/physics_stepper.gd#L307), [physics_stepper.gd](../../../scripts/sim/physics_stepper.gd#L338), [physics_stepper.gd](../../../scripts/sim/physics_stepper.gd#L367), and [table_spec.gd](../../../scripts/sim/table_spec.gd#L8).

The repository’s current values are explicit implementation inputs, not Miniclip measurements: 480 Hz fixed step; rolling resistance 0.012; sliding friction 0.19; spin friction 0.0127; ball restitution 0.94; cushion restitution 0.84; ball friction 0.055; cushion friction 0.12; and pocket-liner restitution 0.2. The table dimensions, shelf depths, and cut angles are also repository values. No cross-game coefficient matching was attempted.

## Next useful evidence

To compare actual behavior, record the current Miniclip web client or an identified mobile version in a playable practice mode. Preserve the version/build, platform, cue identity/stats, table, power setting, tip marker, initial ball positions, and video frame rate. Use repeatable families rather than highlight shots:

1. Clear-cloth center-ball rolls at several power settings; track cue-ball center versus frame time through rest.
2. Identical cue/object placement with center, top, and bottom tip contact; record post-impact cue-ball travel and spin direction.
3. Thin and full hits at fixed speeds; track both balls through contact, then repeat with mirrored sides.
4. Direct rail hits at fixed incidence with zero and both signs of side spin; compare incoming/outgoing direction and speed.
5. Centerline and jaw-first pocket approaches at slow, medium, and fast speeds; include support/hanging states, rejection, and capture.
6. Repeated breaks with recorded cue configuration and starting layout; retain the full break distribution, not one favorable rack.

Use those observations first to define paired outcome tests and tolerances. Only estimate physical parameters after the game exposes or permits enough controlled inputs and measurable positions. Keep score, multipliers, GUI power, and cue stats separate from physical speed until their mapping is independently measured.

## Limitations

- The official web page was opened, but the session remained at the title/login/guest screen; no live shot was played.
- The four media samples are official animated instructional GIFs, not raw research footage. Their frame timing and state transitions include discontinuities.
- No coordinates, velocities, cue statistics, force values, calibrated table dimensions, or audio are supplied by these clips.
- I did not test a registered account, spend in-game currency, or infer any coefficient from the animations.

[^web]: [8 Ball Pool Web/PC version](https://support.miniclip.com/hc/en-us/articles/7759609431953--8-Ball-Pool-Web-PC-version), updated May 9, 2025; [Facebook web version change](https://support.miniclip.com/hc/en-us/articles/50506906989713--Facebook-web-version-to-be-discontinued), September 4, 2026; [Miniclip Web Games](https://www.miniclip.com/games/web).
[^spin]: [Advanced Plays – Spins](https://support.miniclip.com/hc/en-us/articles/35451960569361-Advanced-Plays-Spins-8-Ball-Pool), updated December 16, 2025.
[^controls]: [Basic Controls – Improving your skills](https://support.miniclip.com/hc/en-us/articles/35451942766865-Basic-Controls-Improving-your-skills-8-Ball-Pool) and [How to Aim with the Cue](https://support.miniclip.com/hc/en-us/articles/203747546-How-to-Aim-with-the-Cue-8-Ball-Pool).
