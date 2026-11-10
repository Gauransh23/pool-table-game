# Proportional guides and recorded audio — 0.3.3 candidate

Updated 2026-11-09. [Guide design and checks](docs/quality-roadmap/plans/PROPORTIONAL_GUIDES.md), [audio research and evidence](docs/quality-roadmap/reports/REAL_AUDIO.md).

Outgoing arrows now represent immediate post-collision planar momentum with one
shared screen scale, rather than two independently capped travel paths. Guide
length is adjustable through Menu → Guide length and persists separately from
practice saves. Common obstruction clipping preserves the displayed ratio.
Later spin curvature and stopping distance are outside this diagram's promise.

Recorded audio replaces the previous sine/noise effects: five ball, five cue,
five pocket and one rail take. The rail recording's phone-source quality and
single-take limit are explicit. Attribution is available in the installed app.
The actual engine offline mix deck measures about -1.96 dBTP with no clipped
PCM and later digital silence after mute. This does not establish human sound
quality, speaker/headphone parity, device latency or a sample-accurate mute bound.

See the implementation report for final test/review/release evidence. Full
physical calibration, recognition/DPI and native performance acceptance remain
open; older checkpoint results below retain their historical scope.

# Two-ball outgoing guides — 0.3.2 candidate

Updated 2026-11-08. [Implementation and evidence](docs/quality-roadmap/reports/OUTGOING_GUIDES.md).

The candidate adds ivory cue-ball and dashed cyan object-ball paths, a hollow
first-contact ring and estimated outgoing planar speeds. A cloned replay uses the
active solver and current power/spin settings. Each outgoing preview is bounded
to 0.8 seconds / 0.45 meters and ends before another interaction; ambiguous
clusters and unsupported cases omit outgoing paths. These are estimates within
the active model, not exact real-table predictions or momentum percentages.

Full guide accuracy sweeps, calibrated physics, DPI/user recognition and native
performance gates remain open. See the implementation report for source tests,
raw output, preserved failures, review corrections and release evidence.

# Practice interaction fixes — 0.3.1

Updated 2026-11-06. [Fix report](docs/quality-roadmap/reports/PRACTICE_FLOW_FIXES.md).

The table now fits beside the HUD at actual window sizes; controls keep readable
native sizing. Power, spin, menus, shooting, undo and scratch recovery have a
keyboard path with visible focus. The audio system schedules distinct ball
contacts without the global 16 ms gate and routes them through a limited contact bus.

Verified: 200 routed input/layout checks at 1100×700, 1600×900 and 1920×1080;
950 simulation/rules assertions; aim controls, 42 practice-flow, 39 recovery,
24 stroke-contact and 5 spin-precision checks; two simultaneous physical impact
events and a 100-event audio-delivery batch. Native Metal captures of small/default,
lounge, focus, menu and placement states were inspected.

The earlier audit's minimum-window wording is corrected: native 0.3.0 scaled a
fixed design canvas; its overlap was reproduced in a true 1100×700 subviewport.
0.3.1 handles both sizes directly. These bounded checks do not certify the complete
quality catalog, calibrated physics, audio naturalness, true-peak or device latency.

# New acceptance bar

[Quality-bar-1](docs/quality-roadmap/QUALITY_TARGETS.md) defines 140 new/strengthened acceptance obligations. All start UNVERIFIED; the historical checks below retain only their original scope. New numerical, calibrated and perceptual targets need separate evidence.

# QA status — local 0.3.0 candidate

Updated 2026-10-31. Current evidence: [continuation report](docs/quality-roadmap/reports/continuation-progress.md), [test results](docs/quality-roadmap/reports/continuation-checks/results.json), [source/artifact hashes](docs/quality-roadmap/reports/candidate-manifest.json).

Original four quality targets pass. The source regression suite passes 950 assertions; focused controls, recovery and geometry checks pass. A 90-entry pocket matrix, 20 short break seeds and 3 exact replays pass. A source-rendered contact-to-motion check is 1 frame. Local macOS export/signature and packaged startup pass.

Open gates: calibrated physical response; production solver precision (prototype staged only); full 1000/10000 stress; listening and competitor/owner review; exported frame pacing; native/installed interaction; aim-test teardown resource warning. No commercial-quality signoff.

## Previous0.2.0 record

# QA status — Mac preview 0.2.0

Updated 2026-10-28.

Verified on Apple M4 macOS using Godot 4.7.2 Standard:

- 949 headless physics/rules assertions; 41 practice-flow assertions.
- 4,869 native experiment checks.
- Exported universal app starts without runtime script errors.
- Actual release UI: fresh rack, power slider followed by keyboard shot, break
  dispersion, Undo and Camera/V shortcuts work.
- Source-rendered overhead/lounge views reviewed at 1600×900 with 4× MSAA.
- Official export template archive SHA-512 verified; Mac app signature verifies.
- DMG created successfully; app is approximately 162 MB, compressed installer 64 MB.

Not established: physical table calibration, full pocket rattles/shelves, many-thousand
break stability, hardware thermal/battery results, accessibility completeness, or
Android/Linux/iOS builds. The isolated rules model is not yet a playable match mode.
Some headless flow-test shutdowns report retained GDScript resources; release startup
and the actual release interaction run have no corresponding runtime error. This
needs a longer lifecycle/leak investigation before a release candidate.
