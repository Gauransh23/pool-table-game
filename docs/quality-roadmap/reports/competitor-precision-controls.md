# Competitor observation: 8 Ball Pool precision controls

**Observed:** 2026-10-31, via Brave on macOS desktop. This is a narrow controls review, not a gameplay-quality ranking.

## Provenance and limits

I used the native Brave UI because the browser automation host was unavailable. I opened Miniclip’s official [Basic Controls article](https://support.miniclip.com/hc/en-us/articles/35451942766865-Basic-Controls-Improving-your-skills-8-Ball-Pool), its official [Advanced Plays — Spins article](https://support.miniclip.com/hc/en-us/articles/35451960569361-Advanced-Plays-Spins-8-Ball-Pool), and the articles’ embedded control images and top/backspin GIFs in browser tabs. The direct GIFs were also sampled locally at 0.5 s and 2.0 s with `ffmpeg` and inspected as images. These times are offsets into tutorial animations; they are not match-time or input-latency measurements.

I opened the official [8 Ball Pool web page](https://8ballpool.com/game). It showed the branded game splash with a Login button and a “Play Focus Mode” toggle, not a playable table. I did not sign in or start a match. A YouTube search result for a Miniclip spin tutorial was marked private, so I did not use it. The observations below come from the official support article UI and its actual attached gameplay/tutorial visuals, not search-result summaries.

The support GIFs are 800×370, show a Portuguese-language HUD, and appear to be authored demonstrations. I cannot determine from those assets whether the rendered playfield is the current web build, a mobile build displayed in a canvas, or a tutorial simulation. I do not infer a current client version, player input, audio, or exact timing from them.

## What I observed

| Control area | Visible evidence and official description | What remains unknown |
|---|---|---|
| Aim and micro-adjustment | The official desktop table image shows a cue stick and a straight guide from the cue ball toward the rack. The article says web players click and drag the cue to change trajectory; mobile players can drag the cue or use an aiming wheel “for more precision.” The article also points to configurable control settings. | No angular step size, sensitivity curve, minimum pointer movement, or repeatability is documented in the observed material. The browser game did not reach a playable state, so I could not test its actual desktop drag response or settings. |
| Power resolution | The desktop screenshot places a vertical control at the left edge of the table UI. The article identifies the left icon as the Power Bar for mobile: drag down farther for a stronger shot. On web, hold the left mouse button, move the mouse backward to set power, then release to shoot. The GIFs visibly show the left meter changing during demonstration sequences. | No numeric percent readout, tick spacing, smallest distinguishable movement, or power-to-speed curve is visible in the reviewed assets. I did not measure bar pixels against shot outcomes. |
| Spin selection | The article says web players click the cue-ball icon and select the contact point. On mobile, tap the cue-ball icon and drag the red circle to the chosen point, then release. The visible spin control is a cue-ball face with a red target marker. The top/backspin attachments show the marker/control and subsequent cue-ball movement. | The images do not provide calibrated normalized coordinates, dead zones, precision increments, or cue-stat dependence. I cannot quantify how precisely a player can select an off-center point. |
| Guide semantics | The official screenshot visibly draws an initial line from the cue ball toward the object-ball group. The top/backspin GIFs show guide/aim visuals during the shot setup. The support article describes the guide as helping aim the shot. | The reviewed page does not say whether the live guide accounts for side-spin squirt, collision throw, object-ball deflection, or post-contact cue-ball paths. The still and sampled frames do not falsify or confirm those behaviors. |
| Cue timing | The GIFs show a cue/aim setup followed by ball movement, but do not expose a recorded mouse release/touch event or a time-coded contact event. | No competitor release-to-contact latency, cue-animation duration, audio timing, frame cadence, or native-device response can be measured from these support animations. |

## Comparison with this repository

The current local implementation is more explicit about step size and guide limits in source, while Miniclip’s reviewed materials describe gestures but do not publish numeric resolution.

- **Aim:** Local play begins with a left press on playable cloth, updates while the left button remains held, and retains aim on release. Arrow keys rotate aim by 0.001 radians, or 0.0002 radians with Shift. Miniclip’s web article instead describes dragging the cue itself; mobile adds an optional aiming wheel. These are different interaction mappings. There is no evidence here to claim local and Miniclip have equal sensitivity.
- **Power:** Local HUD uses a 0–1 slider with 0.005 increments and displays tenths of a percent. The source maps positive power quadratically to 0.075–8 m/s; the focused sweep measured 0.0211 m travel at the 0.5% step. Miniclip’s reviewed web control uses pull-back distance and release, while mobile uses a vertical power bar. Its tick resolution and force curve were not measured, so a numeric parity comparison would be invented.
- **Spin:** Local SpinPad exposes center, vertical and side offsets, caps normalized tip offset at 0.5, supports Shift-drag fine movement, and double-click reset. Miniclip’s web interaction selects an impact point on its cue-ball icon; mobile drags a red marker. Both expose contact-point spin, but no comparable coordinate scale is available from the Miniclip visuals.
- **Guide:** Local guide uses a previewed launch direction, shows a first-contact ghost, and labels its limits: later spin, throw and rebounds are not predicted. The Miniclip materials show an initial aim line but do not establish whether its live version predicts any of those later effects.
- **Cue timing:** Local source has a 25 ms backswing and 75 ms delivery; the impulse and cue audio run in the contact callback. The local render probe records contact at frame 7 and first ball motion at frame 8. This says nothing about Miniclip timing, and the GIF playback cannot supply the missing input timestamp.

## Smallest useful follow-up probes

These are falsifiable comparisons; do not assign Miniclip coefficients until the client can be played and instrumented.

1. **Aim repeatability:** In a permitted practice table, use the same cue-ball/target arrangement. Apply repeated small pointer displacements in both directions, record resulting line angle and return-to-origin error, then repeat with local pointer drag and arrow-key fine aim. The “same fine adjustment feel” hypothesis fails if increments are inconsistent, dead-zoned, or not reversible. Keep the desktop and mobile controls separate.
2. **Power resolution:** Hold the shot arrangement constant and record each distinct bar/drag position plus resulting shot travel over the low-power range. Repeat identical inputs to estimate noise. This can falsify the hypothesis that Miniclip exposes finer controllable power than the local 0.5% step; it cannot be answered from the screenshot alone.
3. **Spin mapping:** Record center, top, bottom, left, right, and four diagonal selections; photograph the marker position before release and the resulting cue-ball path after object contact and a rail. Repeat with local SpinPad. This can reveal axis/sign mapping and selection dead zones without assuming their coordinate systems match.
4. **Guide semantics:** For a center hit and a side-spin hit, capture the displayed line before shooting, then compare the first cue-ball path, first contact point, and post-contact path. This distinguishes a first-contact guide from a prediction of squirt, throw, or rebounds. Current Miniclip materials leave that claim open.
5. **Cue timing:** Record input release, visible cue-tip contact, first ball movement, and audio onset on the same high-frame-rate capture on each platform. Repeat enough times to report a distribution. Do not infer timing from GIF duration or the local tween duration alone.

## Sources and visual records

- [Miniclip Basic Controls — Improving your skills](https://support.miniclip.com/hc/en-us/articles/35451942766865-Basic-Controls-Improving-your-skills-8-Ball-Pool) — opened and inspected in Brave; includes the table controls image and web/mobile input descriptions.
- [Miniclip Advanced Plays — Spins](https://support.miniclip.com/hc/en-us/articles/35451960569361-Advanced-Plays-Spins-8-Ball-Pool) — opened and inspected in Brave; includes the cue-ball marker and spin demonstrations.
- [Official topspin demonstration GIF](https://support.miniclip.com/hc/article_attachments/41975216546321) and [official backspin demonstration GIF](https://support.miniclip.com/hc/article_attachments/41975216548625) — opened as browser image pages; sampled at 0.5 s and 2.0 s for visual review.
- [Official 8 Ball Pool page](https://8ballpool.com/game) — opened in Brave; only the splash/login screen was available without signing in.
- Local comparison: `scripts/app/game_controller.gd`, `scripts/ui/game_hud.gd`, `scripts/ui/spin_pad.gd`, `scripts/presentation/table_presentation.gd`, `scripts/sim/stroke_power.gd`, and `docs/quality-roadmap/reports/render-contact.json`.
