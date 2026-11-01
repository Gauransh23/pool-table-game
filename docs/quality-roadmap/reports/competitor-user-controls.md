# Competitor observation: user controls and interaction flow

Date observed: 2026-10-31
Scope: aiming, power, spin, shot commitment, feedback, and recovery only. This is a formative observation of interface behavior, not a product-quality or parity score.

## What I could inspect

I opened Miniclip's current web entry point, [8ballpool.com/game](https://8ballpool.com/game), in Brave Guest. The visible start screen offered “Login with Miniclip ID” and “Play as Guest.” I did not reach an active match; the guest click did not enter gameplay. The current web build/version therefore remains unobserved.

I opened a public YouTube result, [“8 BALL POOL SPIN TUTORIAL”](https://www.youtube.com/watch?v=1WL9f2LTTdA) by Pooja & Vinay Gaming (5:52; YouTube displayed August 23, 2017 / “9y ago”). The inspected 0:00–0:02 segment was an animal intro, not gameplay. A newer-looking tutorial result was marked “Private video.” I do not use either video as gameplay evidence.

The available direct gameplay visuals were Miniclip help-page animations: [topspin.gif](https://support.miniclip.com/hc/article_attachments/41975216546321) and [backspin.gif](https://support.miniclip.com/hc/article_attachments/41975216548625), embedded under the official [Advanced Plays – Spins](https://support.miniclip.com/hc/en-us/articles/35451960569361-Advanced-Plays-Spins-8-Ball-Pool) article, updated December 16, 2025. I inspected extracted frames at these animation offsets: topspin 0.5, 1, 2, 3, 5, 8, 12 and 15 s; backspin 0.5, 1.5, 2.5, 5, 8 and 12 s. The 800×370 landscape capture shows an iOS-style home indicator and a Portuguese label, “Efeito do taco 9”; exact device, OS, game version and capture date are not shown. These are real game-interface frames, but the animations do not show a finger or pointer, so they do not establish the exact input gesture.

## Direct visual observations

| Control stage | What is visible in the inspected frames | What remains uncertain |
|---|---|---|
| Aim | A long guide starts at the cue ball. Some frames add circular target/contact markers and a second projected segment. The cue graphic, line and balls share the same table view. | The frames show line changes, but no touch/pointer; they do not prove whether aim is acquired by dragging the cue, moving a wheel, or another gesture. |
| Power | A tall, narrow rail sits at the far left. It changes from a dark outline to a yellow/red fill with a small light marker visible lower on the rail in one frame. | No numeric value or labelled percentage is visible in these frames. The exact mapping from marker position to shot strength cannot be measured from this clip. |
| Spin | A cue-ball icon remains at the upper-right. A large cue-ball overlay appears over the table with a red target ring; later frames return to the small icon with a red marker near its upper edge. | This sequence is consistent with selecting a contact point, but the initiating tap/drag and exact selection confirmation are not shown. |
| Commit and response | A later frame shows the rack dispersed; top HUD values and pocket indicators change in subsequent frames. The cue and aim line are visible again in later board states. | No on-screen Shoot button or release event is visible at the point of commitment. The frames do not isolate which input caused the shot. |
| Cancel and recovery | A green menu icon remains at upper-left. | No menu opening, cancel action, undo/retry, or ball-in-hand recovery is shown. I cannot infer that these are absent from the game. |

The supporting static [Table.jpg](https://support.miniclip.com/hc/article_attachments/35451926199441) shows the same two edge controls highlighted: a left vertical rail and a right-side rail. It is a diagram, not an observed interaction.

## Comparison with this project’s current controls

The local build acquires aim with left-button press/drag on the cloth and retains the line on release ([game_controller.gd:100](../../../scripts/app/game_controller.gd:100), [game_hud.gd:67](../../../scripts/ui/game_hud.gd:67)). Power is a separate right-side 0–100% slider with 0.5% steps; shot commitment is a “TAKE SHOT” button, with Space as a keyboard alternative ([game_hud.gd:71](../../../scripts/ui/game_hud.gd:71), [game_hud.gd:101](../../../scripts/ui/game_hud.gd:101), [game_controller.gd:92](../../../scripts/app/game_controller.gd:92)). Spin is a persistent visible pad, and Undo/U restore the previous shot state ([game_hud.gd:84](../../../scripts/ui/game_hud.gd:84), [game_hud.gd:108](../../../scripts/ui/game_hud.gd:108), [game_controller.gd:214](../../../scripts/app/game_controller.gd:214)). The competitor frames instead place a vertical power control beside the table and show spin as a cue-ball overlay. Because the competitor frames omit the pointer/finger and commit moment, treat the physical gestures and release-to-shoot behavior as unknown here.

## Small interaction details to carry into tests

- The cue-ball control is separate from the aiming guide and appears to open a larger, direct contact-point selector; the selected red marker is visible again on the small cue-ball icon afterward.
- The visible power rail has a changing fill/marker, but no percentage readout in the inspected frame. The local build should retain its numeric readout if it explores a compact edge meter; the images do not establish that numeric feedback is unnecessary.
- The guide is visually tied to the cue ball and the first target. Changes to direction are apparent on the table rather than only in a detached settings panel.
- Top-row score and pocket indicators provide post-shot feedback. The captures do not show how the game explains a foul, turn change, or recovery action.

## Proposed acceptance tests for this project

1. **Aim acquisition and retention:** press on valid cloth, drag through several targets, and release. The line should follow the drag, remain fixed after release, and not move when the pointer crosses the HUD.
2. **Power preview and commit:** sweep 0, minimum nonzero, middle, and maximum settings while keeping aim fixed. Verify that the value readout, cue pullback, and resulting launch speed agree; zero must not fire. Button and Space should each submit exactly one shot.
3. **Spin adjustment:** open/change/reset tip selection without changing aim or power. Confirm the selected point remains visible through shot setup and that shot parameters freeze at commitment.
4. **Cancellation boundary:** cancel a pending backswing before contact and verify no strike, movement, score change, or undo entry. After contact, the shot must be applied exactly once.
5. **Feedback and recovery:** after a pot, foul/scratch, and ordinary miss, verify the status/score/turn state explains what happened. Undo/U should restore the prior balls and counters after the shot settles; menu/reset during pending stroke should not leave a hidden shot queued.

These are proposed tests for the local implementation, not claims about Miniclip behavior. A future observation should capture an actual play session with input visible and explicitly demonstrate release, cancellation, turn feedback, and recovery before making stronger interaction comparisons.
