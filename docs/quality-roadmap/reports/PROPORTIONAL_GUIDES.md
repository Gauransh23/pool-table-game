# Proportional momentum guides — bounded source checkpoint

2026-11-08. **PASS for the implemented source/UI slice; full quality catalog remains UNVERIFIED.** Source baseline `c2a048700cb0972419a55bae4eddc496bb7a87d1`, original checkout on `main`. Independent review, exported app verification and packaging belong to the lead. No physics algorithm/coefficient, save/undo, stroke delivery or fine-aim edits were made. The experimental impact stepper remains outside gameplay.

## Exact display meaning

The default outgoing branches are **relative instantaneous planar momentum at first impact**, using the active replay's post-pair velocities, including the pair's tangential impulse. Equal ball mass means momentum magnitude ratios equal speed ratios. They are not stopping distances, scalar conservation percentages or energy percentages. At an ideal 30° cut the cue/target speed ratio is `sin(30°)/cos(30°)=0.57735`; energy ratios would instead square the speed factors.

The replay observer overrides `_resolve_ball_pair` with the exact active signature, calls `super` once, snapshots input velocities cheaply, and records post-pair velocities only for the newly registered first event. Registered centers, immediate velocities, and existing tick-end speeds/trajectory samples remain separate fields. Historical `cue_speed`, `object_speed`, `cue_path` and `object_path` retain their old meanings and their existing tests. No collision formula is copied into the observer.

The renderer uses the shared `momentum_geometry.paths` as its actual ribbon/arrow centerlines. Each outgoing magnitude divided by `max(incoming speed at impact, both outgoing magnitudes, 1e-9)` encodes a fraction of `25% × available play width × length multiplier` in projected screen units. Direction comes from each projected velocity. Conversion through the current orthographic camera corrects lounge foreshortening. Both branches then receive one common obstruction factor. Finite shared rail/jaw segments, rounded endpoints, pocket fall edges and unrelated ball center clearance (2R) limit both together. The separating cue/target pair is ignored as a blocker. A 2 mm inset keeps endpoints before the obstruction; the readout says “limited by obstacle” when the common factor is below 0.995. Arrow glyphs do not define the encoded centerline length; zero vectors are omitted and no minimum length floor is added.

Menu → Guide length supplies a keyboard-focusable 0.25–3.00x slider, default 1.50x, 0.05x steps. The visible focus outline and trapped modal Tab traversal include the slider and Back. A dedicated `user://guide-settings.cfg` ConfigFile persists cosmetic length; `GameHUD.guide_settings_path` is overrideable before readiness. Finite loaded values clamp/snap to the slider quantum; malformed/nonfinite values retain the default. All automated editing fixtures use an isolated `/tmp` preference path. Length edits and resize/camera redraws reuse the cached prediction. The compact HUD labels the mode “Relative momentum at impact”; the old rendered 0.8 s / 0.45 m promise is removed. Follow/draw's later curvature is explicitly stated.

## Reference limits

The lead's recorded official Miniclip guest observation in [the plan](../plans/PROPORTIONAL_GUIDES.md) describes unequal branch extents and the hollow contact marker. No controlled competitor formula, cue-stat or power sweep was measured. This implementation does not claim exact Miniclip numerical parity. The conceptual speed/line-length reference is [Alciatore's ball travel-distance discussion](https://drdavepoolinfo.com/faq/speed/ball-travel-distance/); the implementation's oracle is the active solver plus independent ideal sin/cos identities. No new physical calibration is claimed.

## Requirement evidence

| Requirement | Bounded result | Actual evidence and limits |
|---|---|---|
| AIM-001 | PASS, settings interaction slice | Actual Viewport keyboard events open menu, Tab to Guide length, Enter, Right, Back and Escape; retained aim/power/stroke count and pending state unchanged. Existing aim and input-flow suites pass. Native user acquisition trials remain outside this slice. |
| AIM-005 | PASS, declared momentum diagram scope | Ideal cuts 0/15/30/45/60/75° with e=1 and zero ball/cloth friction; independent sin/cos speed and vector momentum identities. Actual shared rendered geometry projected into both cameras at 0.25/1.50/3.00x matches velocity ratios within 0.0002 absolute ratio. Historical registered centers and active trajectory parity remain green. This is not a new calibration or all-domain geometric certification. |
| AIM-006 | PASS, qualification/zero/clipping slice | Zero branch omitted, near-zero branch measured 0.00229 pixels with no floor; unrelated balls, rail and open side-pocket fall edge shorten both by one factor. Ambiguous/contact-invalid omissions remain tested by outgoing suite. Blinded identity recognition is NOT_RUN. |
| AIM-008 | PASS, existing transition and cache slice | Existing aim/input/stroke transition suites pass. New length and resize tests retain the same replay object; camera tests reuse cache. Existing guide-off and placement behavior remains green. |
| AIM-009 | PASS, guide-settings keyboard slice | Real modal focus traversal, visible outline, actual Right adjustment by 0.05x, Back and Escape, isolated persistence and malformed-value handling. Does not replace the full keyboard-only practice acceptance task. |
| VIS-007/008/009 | PASS only for captured source presentation and projected relative-strength slice | 11 source GUI PNGs reviewed at 1100×700: head-on, 30°, thin at short/default/long; lounge and settings. Ivory/cyan identity, hollow marker, visibly unequal branches, shared limiting and compact controls present. No blinded perception, native timing, audio, long-session or exported acceptance implied. |

## Commands and results

Every command ran in `/Users/gt/Documents/My Public repos/Pool table game`. Runtime: Godot `4.7.2.stable.official.ed1daf0bf`. Source/profile and capture SHA-256 identities, suite exit codes and baseline are in [manifest.json](proportional-guides-evidence/manifest.json). Raw outputs are retained separately from this summary.

```sh
bash tools/godot.sh --headless --path . --script tests/proportional_guides.gd
bash tools/godot.sh --headless --path . --script tests/outgoing_guides.gd
bash tools/godot.sh --headless --path . --script tests/aim_controls.gd
bash tools/godot.sh --headless --path . --script tests/practice_input_flow.gd
bash tools/godot.sh --headless --path . --script tests/stroke_contact.gd
bash tools/godot.sh --headless --path . --script tests/practice_flow.gd
bash tools/godot.sh --headless --path . --script tests/save_recovery.gd
```

| Suite | Result | Raw output |
|---|---|---|
| proportional_guides | 106 checks, 0 failures, exit 0 | [raw](proportional-guides-evidence/proportional_guides.txt) |
| outgoing_guides | 878 checks, 0 failures, exit 0 | [raw](proportional-guides-evidence/outgoing_guides.txt) |
| aim_controls | 0 failures, exit 0 | [raw](proportional-guides-evidence/aim_controls.txt) |
| practice_input_flow | 200 checks, 0 failures, exit 0 | [raw](proportional-guides-evidence/practice_input_flow.txt) |
| stroke_contact | 24 checks, 0 failures, exit 0 | [raw](proportional-guides-evidence/stroke_contact.txt) |
| practice_flow | 42 checks, 0 failures, exit 0 | [raw](proportional-guides-evidence/practice_flow.txt) |
| save_recovery | 39 checks, 0 failures, exit 0 | [raw](proportional-guides-evidence/save_recovery.txt) |

The focused default-friction signed-spin cases match a separately implemented active-stepper post-pair observer within `1e-7 m/s`. Their maximum pre-tangential versus post-pair difference is **0.470310 m/s**. The near-contact zero-spin case has a target post-pair versus tick-end difference of **0.00194165 m/s**, distinguishing the sample timing. Cue velocity alone can remain unchanged over that remainder; both velocities are checked. These are source numerical checks, not measured-table validation.

The preserved red historical case at ideal 30° and 8 m/s cue speed yields old paths **0.449999989 m / 0.449999994 m**, display ratio ~1 despite true momentum ratio **0.577350214**. [The failure record](proportional-guides-evidence/preserved-old-equal-cap-failure.json) stays FAIL. New rendering passes while retaining those historical path samples. `initial-focused-failures.txt` and `fixture-development-*.txt` preserve harness development failures: wrong Tab count, an initially insufficient cue-only timing discriminator and an invalid nonplanar high-spin fixture. These are explicitly superseded by the corrected final fixture, not erased or used as green evidence.

Capture command family (executed for each cut `0,30,75` and length `0.25,1.5,3.0`):

```sh
bash tools/godot.sh --path . --script tests/capture_proportional_guides.gd -- --small --cut=30 --length=1.5 --output=/absolute/path/30deg-default.png
# Also executed with --lounge and --settings at --small --cut=30 --length=3.
```

All 11 capture commands exited 0 using Metal Forward+ on Apple M4. Every PNG was inspected. [30° default](proportional-guides-evidence/30deg-default.png), [30° long](proportional-guides-evidence/30deg-long.png), [thin long](proportional-guides-evidence/thin-long.png), [lounge](proportional-guides-evidence/lounge.png), and [settings](proportional-guides-evidence/settings.png) show the main distinctions. Full head/30/thin short/default/long matrix and exact capture output/geometry are in the evidence directory. Source capture is not exported GUI evidence.

## Self-review and residual limits

Reviewed observer timing and single `super` call, existing field preservation, shared projected geometry and clipping, zero branches, dashed last endpoint, cache behavior, preference isolation, modal focus/Back/Escape, and diff scope. Production PhysicsStepper/PhysicsConfig/TableSpec are unchanged. `git diff --check` passes. Source labels contain no old travel promise. Independent lead review remains required.

The renderer relies on the two current orthographic cameras. Extreme subpixel vectors can be numerically represented but not perceptually resolved; no artificial length is substituted. Obstruction clipping is a schematic bound, not a bank/stop forecast. Subsequent cloth/spin motion can diverge from the shown instantaneous direction. The replay still computes the historical travel data, preserving existing coverage and cost; no new export/performance claim is made. The outgoing regression's observed maximum slice was 2882 µs under concurrent suite execution: the budget is checked after an indivisible tick, and this is not a native latency benchmark.

### Cleanup warnings, separate from assertion results

The aim suite exits 0 but retains its existing exit cleanup warnings: 2 ObjectDB instances and 1 resource still in use. The recurring shell startup `/Users/gt/.zshenv:3` parse warning occurs outside Godot. Neither is hidden; no unrelated cleanup change was made. Other raw engine/audio warnings remain in their respective outputs. No assertion failure is classified as a cleanup warning.
