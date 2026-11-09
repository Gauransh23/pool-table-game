# Fine mouse aiming — first implementation slice

Status: implementation verified in the stated automated scope; broader first checkpoint conditional.
Baseline: main at 23cb30f, Godot 4.7.2, macOS Apple M4. The two preceding research/plan documents were untracked at entry and are preserved.

## Understanding and decision

The existing coarse gesture points from cue ball to cursor. Its angle sensitivity varies inversely with pointer distance. Keyboard precision does not fix mouse acquisition. The viewport route already provides correct GUI-origin exclusion and release observation before GUI consumption; reuse that lifecycle rather than adding a second independent input listener.

Shift + left press on valid cloth starts fine mode without changing direction. Horizontal event-relative movement rotates physical aim by 0.00005 rad/logical viewport pixel (about 0.002865 degrees). Vertical movement has no angular effect. Shift is latched at press, preventing a surprise return to coarse aiming if released mid-drag. Release, focus loss, menu, camera change, resize, undo, rack reset and shot commitment use the existing cancellation function, which now clears both modes. Relative event movement avoids jumping across skipped GUI motion. Motion outside playable cloth is ignored. This is an intentional bounded design candidate, not a measured best sensitivity for users or hardware.

Expected and actual code owners: game_controller.gd input/lifecycle, game_hud.gd discoverability, tests/aim_controls.gd routed input. No new simulation owner or persistence schema was needed.

## Evidence

Baseline aim suite: 0 failures. New routed-input tests before implementation: 18 failures, demonstrating that existing coarse behavior cannot satisfy the fine-mode contract. After implementation: 0 failures. Tests cover entry without snap, 100 positive and 100 negative increments at three headings including angle wrap, two pointer locations, increment bounds, reversal residual, release and focus-loss cancellation. Existing coarse, GUI-origin, placement, menu, undo, camera and shot cancellation regressions remain green.

Other fresh checks: practice_input_flow 200/0; practice_flow 42/0; stroke_contact 24/0; save_recovery 39/0. Logs and source hashes accompany this report. git diff --check passed.

Separate candidate exported successfully to /tmp/LongRail-fine-aim-candidate.app and codesign --verify --deep --strict passed. Source native Metal capture at 1100×700 was inspected: instructions and footer fit, and controls/table remain visible. This is source-rendering evidence, not installed candidate interaction or latency evidence. Existing release artifacts were preserved.

Requirement mapping: AIM-001 intent retention and AIM-002 fine increment/reversal receive bounded routed-input evidence. AIM-003 complete reprojection/DPI matrix, AIM-004 human acquisition, AIM-009 full keyboard/native access and complete quality-gate acceptance remain open. Do not convert these partial results into catalog-wide PASS.

## Remaining work and next action

The larger plan's package A is not complete: reusable shot fixtures, timing instrumentation and the three-ball/one-pocket baseline still need implementation. Full hardware/DPI/window acquisition trials and a native mouse/trackpad comparison remain unverified. No independent review or final perceptual acceptance has occurred. The red test run also emitted previously observed teardown resource warnings; the green run did not emit them, which does not close the lifecycle investigation.

Next: implement fixture load/replay and baseline timing capture for the three-ball scene; use that scene to evaluate fine-aim acquisition before changing sensitivity or starting the power-response atlas. Keep solver, coefficients and power mapping stable during this input comparison. Rollback: revert this slice's controller/HUD/test changes to baseline, retaining the evidence and research documents.
