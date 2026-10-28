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
