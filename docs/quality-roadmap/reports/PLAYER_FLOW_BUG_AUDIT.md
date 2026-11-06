# Offline practice flow: bug audit

Date: 2026-11-06. Candidate: Long Rail 0.3.0, source commit `57644e0`. Focus: aim, release, move to power, shoot and continue. This is a diagnostic report; no product code was changed.

## Verdict

The exact mouse sequence works in the default `1600×900` viewport when exercised through Godot's actual GUI input routing. I reproduced: left-button drag on cloth → release → unpressed cursor travel → power slider drag → Take Shot click → simulation settle → Undo. All 16 isolated checks passed. The active game also showed eight strokes and four balls pocketed during this investigation. Those observations support basic playability at the default size; they do not prove a representative player can select precise shots reliably.

I found two confirmed defects in surrounding conditions, plus a keyboard-access gap against the project's own quality contract. The most direct shot-input failure occurs at the game's advertised minimum window size.

## Confirmed findings

| Priority | Finding | Reproduction/evidence | User effect |
|---|---|---|---|
| **P1** | **HUD overlaps and blocks part of the table at the supported minimum window size.** | Project minimum is `1100×700` ([project.godot](../../../project.godot#L19)). At that viewport, an isolated Godot subviewport reports the side panel rectangle `(790,112)` with size `298×680`. The camera maps the valid cloth point `(1.1,0.55) m` to screen `(816.98,529.07)`, inside the HUD. `TableSpec` accepts the world point as cloth, but a left press does not start the aim gesture because the covering `PanelContainer` has mouse filter `STOP`. The projected right-rail center `(872.33,350)` and both right corner pockets are also under the panel. Camera size/offset and HUD anchoring are in [TablePresentation](../../../scripts/presentation/table_presentation.gd#L346) and [GameHUD](../../../scripts/ui/game_hud.gd#L58); aim starts only through [unhandled input](../../../scripts/app/game_controller.gd#L99). | At a permitted narrow window size, the player cannot see or set aim on the rightmost cloth region, including the right corner pockets. This is a genuine playable-area occlusion/input failure, even though a portion of the table remains playable. The app was not resized on the user's live window; this was reproduced in a separate headless subviewport. |
| **P1** | **A global 16 ms debounce drops distinct ball-contact sounds.** | [TableAudio](../../../scripts/presentation/table_audio.gd#L18) discards every `ball` event if it occurs within 16 ms of the previous ball event, regardless of which balls collided or the impulse. [PhysicsStepper](../../../scripts/sim/physics_stepper.gd#L235) emits separate contacts; [GameController](../../../scripts/app/game_controller.gd#L57) drains the event batch synchronously during a render update and passes only contact speed to audio. Thus several distinct break contacts delivered within one update are reduced to one sound; the threshold uses wall-clock milliseconds rather than the simulation event tick. | Breaks and dense clusters can sound sparse or inconsistent across frame schedules. The code-level loss is confirmed; how noticeable it is in the mix still requires listening. This also directly conflicts with [AUD-004](../targets/02-controls-and-presentation.md#aud-004-dense-contacts-and-duplicates), which prohibits a global unrelated-contact gate. |
| **P2 / accessibility requirement** | **A keyboard-only player cannot set power or spin.** | The controller maps arrows to fine aim, Space to shoot, U to undo, V to camera and Escape to menu in [GameController](../../../scripts/app/game_controller.gd#L87). The [power slider](../../../scripts/ui/game_hud.gd#L78) and other HUD controls disable keyboard focus; [SpinPad](../../../scripts/ui/spin_pad.gd#L39) implements only mouse events. No power or spin keyboard actions appear in the controller. This fails the required [AIM-009](../targets/02-controls-and-presentation.md#aim-009-keyboard-access). | Keyboard alone can fire the default shot, but cannot choose a deliberate strength or tip offset. This does not break the requested mouse sequence; it blocks an alternate basic practice input mode. |

## Exact mouse flow checks

Existing [aim-controls tests](../../../tests/aim_controls.gd) pass with 0 failures for unpressed cursor movement, right-button drag, HUD-origin drag, left drag, release outside the viewport, placement, fine keyboard aim, focus loss, Escape, camera switching, undo, re-rack and shot cancellation. Existing [practice-flow tests](../../../tests/practice_flow.gd) pass 42 checks for shooting, settle, undo, placement and recovery.

Neither existing test joined the specific user sequence into one UI transaction. A temporary, uncommitted probe exercised mouse events through the actual viewport controls: aim and release on cloth, move the free cursor, drag the actual HSlider, move to the actual Take Shot button, settle and Undo. It passed **16/16** checks at the default viewport. The temporary script used a unique `/tmp` save path, and the open desktop session was not touched.

This clears the original concern for the specific `1600×900` mouse workflow: I could not reproduce aim drift or a lost slider setting. It does not establish human repeatability or narrow-window usability.

## Visual and audio limits

The current live screenshot showed small muted HUD labels and a filled translucent ghost ball that might be confused with a real ball. Those are hypotheses, not confirmed defects from a single frame; the contract requires [normal-size recognition and readability trials](../targets/02-controls-and-presentation.md#vis-002-ball-recognition) and [measured UI bounds](../targets/02-controls-and-presentation.md#vis-008-ui-readability-and-access). The parallel visual/source review also confirmed it did not hear either the game's audio or live Miniclip sound. I therefore make no sound-naturalness or audio-latency claim.

Both existing headless tests emitted shutdown warnings (`2 ObjectDB instances leaked`, `1 resource still in use`). These are test-run cleanup warnings and do not prove a gameplay leak; QA already lists a lifecycle teardown issue separately. No code or tests were changed in this audit.

## Next targeted checks

1. At `1100×700`, try the right rail and both right corner pockets. Keep a point’s world coordinate while resizing and verify that every supported cloth point remains visible and can start aim.
2. Exercise real browser/game audio events for a multi-ball break. Compare audible contact count with the physics event list at 30, 60 and 120 Hz; do not solve duplicates by dropping unrelated valid contacts.
3. Decide whether keyboard-only power/spin is required. The current acceptance contract says it is; then add explicit input bindings and test a full mouse-free practice shot.
4. Run the recognition/readability deck at default and minimum sizes and get human listening feedback before treating the two sensory observations as bugs.
