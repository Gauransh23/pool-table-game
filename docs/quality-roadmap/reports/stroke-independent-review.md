# Independent stroke and guide review

**Status: CONDITIONAL.** The reviewed control, power, cue-contact and cancellation paths passed their focused automated checks, including a separate graphical contact-frame capture. I found no observed runtime defect in those paths. Native-device latency, audio scan-out, and subjective feel remain unverified.

## Scope and findings

Reviewed the current diff for `GameController`, `TablePresentation`, `GameHUD`, and `StrokePower`, plus `tests/stroke_contact.gd`, `tests/aim_controls.gd`, and `tests/stroke_power.gd`. This review covered deliberate aiming, captured shot inputs, zero/non-finite power and spin handling, cue/contact geometry, guide direction, menu/rack/focus/camera/undo cancellation, and callback ordering.

- **No runtime defect observed in the exercised cases.** Shot speed is captured before animation; the callback applies the strike and plays cue audio at the tween contact point. The tip front is aligned to the selected contact arm, and the guide ray uses the previewed launch direction. Zero, negative, and non-finite power produce no shot; invalid spin is rejected by the controller. Menu and rack cancellation kill the tween and invalidate its generation before a later callback can fire. Input press/drag/release and gesture cancellation cases passed.
- **Pending-stroke focus loss is now covered.** The extended contact test sends `NOTIFICATION_WM_WINDOW_FOCUS_OUT` while the tween is pending, waits past the animation, and confirms there is no contact or stroke. It also verifies an attempted camera switch during a pending stroke leaves that stroke intact through contact.
- **Rendered frame timing was measured; the screenshot is not retained in the current checkout.** The headless test confirms cue visibility at the contact event, exact tip-to-ball surface distance, and the already-started strike. A separate Metal render test reports the cue visible in rendered contact frame 7 and first visible cue motion in frame 8 (`gap_frames: 1`) in `docs/quality-roadmap/reports/render-contact.json`. At review time, `tests/render_contact.gd` attempted to save `res://captures/contact-frame.png`, but that file was absent; the script does not fail if `save_png` fails. This measures rendered frames, not native input latency, display scan-out, audio-device latency, or subjective feel.
- **Invalid inputs are covered at the controller boundary.** Negative, NaN and infinite power; NaN and infinite tip offsets; and an offset outside the miscue limit are confirmed to be rejected before animation, contact or stroke count.

## Verification

All commands used Godot 4.7.2 headless from the repository root:

```sh
/Users/codex/Applications/Godot-4.7.2.app/Contents/MacOS/Godot --headless --path . --script tests/stroke_contact.gd
/Users/codex/Applications/Godot-4.7.2.app/Contents/MacOS/Godot --headless --path . --script tests/aim_controls.gd
/Users/codex/Applications/Godot-4.7.2.app/Contents/MacOS/Godot --headless --path . --script tests/stroke_power.gd
```

- `stroke_contact.gd`: exit 0; 24 checks, 0 failures. Includes zero/invalid-input non-fire, cue visibility and surface contact, impulse at callback, frozen inputs, single-contact count, menu/rack/focus cancellation, and a camera-switch attempt during a pending stroke.
- `aim_controls.gd`: exit 0; 0 failures on the fresh post-geometry run. Covers unpressed and GUI-origin motion, held left drag, release outside/through GUI, placement, keyboard fine aim, menu/Escape, rack, undo, camera, focus loss and shot commitment.
- `stroke_power.gd`: exit 0; mapping/HUD assertions and 39 simulated power settings passed. The 0.5% setting traveled 0.0211 m, within the stated 0.02–0.10 m range.

The graphical test's JSON measurement is retained. The image path is referenced by the script but was not present during this review, so no image inspection is claimed.

No runtime files were edited during this review.

Parent artifact confirmation: direct filesystem `ls -l captures/contact-frame.png` confirmed a 465642-byte PNG at the stated absolute checkout path on 2026-10-31. The folder is Git-ignored, so default repository file searches can omit it. The graphical test now creates the directory and treats capture-write failure as a failed test.
