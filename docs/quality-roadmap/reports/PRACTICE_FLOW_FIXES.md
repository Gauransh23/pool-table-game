# Practice interaction fixes — 0.3.1

Date: 2026-11-06. Baseline commit: `41b860f`. Scope: the identified layout, audio event-loss and keyboard-access issues. The active GDScript physics engine, coefficients and numerical prototype promotion are unchanged.

## Diagnosis correction

The original [bug audit](PLAYER_FLOW_BUG_AUDIT.md) accurately reproduced overlap in a `1100×700` SubViewport, but overstated that result as a native window failure. A fresh native 0.3.0 capture showed a `1100×700` window displaying a fixed `1600×900` logical canvas as a `1100×618` render image with letterboxing. The table did not overlap the sidebar in that native capture; text and controls were scaled down.

The new project uses a window-sized canvas. The camera fits the full table into the area left of the HUD, in both cameras and during resizing. The sidebar is compact enough to fit the minimum height, and essential labels use at least 12 design units. Native capture now reports window, viewport and image all at `1100×700`. Actual DPI/contrast/human-readability acceptance still needs its own measurement.

## Changes and evidence

| Requirement slice | Change | Verification and actual result | Remaining limit |
|---|---|---|---|
| VIS-009, AIM-003/008 | HUD exposes an unobstructed play rectangle; the orthographic camera fits table bounds to it. Native canvas no longer shrinks a fixed design layout. Resize cancels the drag but preserves its physical heading. | `tests/practice_input_flow.gd`: sampled the entire cloth outline and formerly blocked target in overhead/lounge views at 1100×700, 1600×900 and 1920×1080; all visible and clear of the panel. A real 1600→1100→1600 viewport resize also passed. Native small/default/lounge captures inspected. | Bounded layouts and sampled geometry, not arbitrary monitor/DPI or population usability acceptance. |
| AIM-001 | Retained aim survives normal release, free cursor travel, slider drag and movement to Take Shot. | Complete UI transaction is now permanent test coverage: actual Viewport routing, actual HSlider and button; one shot, settlement and Undo at all three sizes. | Synthetic engine input; native mouse/trackpad latency and human precision remain separate. |
| AIM-009 | Tab/Shift-Tab focus traversal; P power; S tip; arrows adjust the focused control; Shift fine tip; Home center; Escape returns to table aim. Menus retain focus internally. Keyboard arrows/Enter place a cue-ball preview after a scratch; mouse placement still works. | Routed keys verify power/spin change without changing aim, focus traversal, menu trapping/resume, Enter/Space shooting, Undo and scratch placement. Total `practice_input_flow.gd`: **200 checks, 0 failures**. Native focus/menu/placement captures inspected. | No full assistive-technology audit. Focus and shortcuts are implemented, but broad accessibility compliance is not claimed. |
| AUD-004 | Removed the global wall-clock ball-contact deletion gate. Every valid delivered contact now reaches the bounded voice pool. | `tests/audio_contacts.gd`: two independent physical ball collisions generated in one tick both scheduled; all 100 events in a batch scheduled; muted/invalid events rejected. **0 failures**. | The existing 12-voice pool can reuse a voice under overload. No solver contact-identity coalescing or full event-priority audit was added. This closes the unrelated-contact gate bug, not the whole AUD-004 target. |
| Audio headroom | Contact voices use a dedicated bus with a hard limiter set to -2 dB. Without a limiter, twelve identical stored peaks at the old maximum per-voice gain have a conservative summed amplitude above 1. | Test checks the bus, enabled limiter and voice routing. Godot documents the [hard limiter's peak prevention](https://docs.godotengine.org/en/stable/classes/class_audioeffecthardlimiter.html). | Configuration/backend tests do not establish output true peak, naturalness or audible device timing. No listening parity claim. |

## Red-to-green record

Before source changes, the new input test had 38 failures (layout and keyboard) across 197 assertions; the new audio test failed both simultaneous-contact and batched-delivery checks. After the changes and added resize/Space coverage, input had 200 checks with 0 failures and audio had 0 failures.

The headless backend exposes a 64×64 root window when project stretch is disabled. Root-window input fixtures explicitly declare their logical canvas; direct SubViewport fixtures retain their actual tested size. Native screenshots separately verify that the shipped project really uses the requested window dimensions. This prevents a test-only canvas setting from being mistaken for native layout evidence.

## Regression commands

All completed successfully with Godot 4.7.2 on Apple M4 macOS:

```sh
bash tools/godot.sh --headless --path . --script tests/practice_input_flow.gd
bash tools/godot.sh --headless --path . --script tests/audio_contacts.gd
bash tools/godot.sh --headless --path . --script tests/run.gd
bash tools/godot.sh --headless --path . --script tests/aim_controls.gd
bash tools/godot.sh --headless --path . --script tests/practice_flow.gd
bash tools/godot.sh --headless --path . --script tests/save_recovery.gd
bash tools/godot.sh --headless --path . --script tests/stroke_contact.gd
bash tools/godot.sh --headless --path . --script tests/spin_precision.gd
```

Results: 950 simulation/rules assertions; aim controls 0 failures; practice flow 42/0; save recovery 39/0; stroke contact 24/0; spin precision 5/0. New input fixtures mute their private audio instance; new audio fixtures use empty streams with the headless Dummy audio driver to inspect event scheduling. No waveform fidelity is inferred. The user's live app and save were not used by these tests.

Rendered captures are local build artifacts under `build/verification/`: `flow-small.png`, `flow-default.png`, `flow-small-lounge.png`, `flow-power-focus.png`, `flow-menu.png`, `flow-placement.png`, each with a JSON window/viewport/image-size record. The native captures came from the current source and were opened for inspection.

## Build

`bash tools/build_mac.sh` exports a versioned app bundle and DMG, verifies the local app signature, and writes `build/SHA256SUMS.txt`. Versioned bundle paths preserve the older running app. Exact source/capture/package hashes and startup evidence are in [practice-flow-fixes.json](practice-flow-fixes.json).

The universal arm64/x86_64 bundle reports version 0.3.1. Signature and DMG checksum checks passed. The exported binary started with `--headless --quit-after 3`, exited 0 and printed no runtime errors. This startup check is separate from the source-native rendered captures and is not an installed-app human interaction test.

This is a bounded bug-fix candidate. Ghost-ball recognition, sensory preference and the full high-fidelity quality catalog remain unverified.
