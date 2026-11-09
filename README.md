# Long Rail

An original, offline pool game in development. The current Mac preview concentrates
on practice-table quality and expressive stroke control rather than a complete match system.

## Try the Mac preview

Build output: `build/Long Rail-0.3.2-mac.dmg`. Open it and drag **Long Rail** into
**Applications**, then open the app. This local preview uses an ad-hoc signature;
Developer ID notarization is not configured.

Click and drag on the cloth to aim; release to retain your line. Choose power and
tip position, then click **Take Shot** or press **Space**. Zero power does not fire; the low end supports delicate taps. Left/right arrows
fine-tune aim; hold Shift for finer steps. Shift-drag horizontally on the cloth
for fine mouse aiming. Shift-drag the tip pad for small
adjustments; double-click it to center the tip.
For keyboard play, **P** selects power and **S** selects tip position. Use arrow
keys in the focused control, **Shift** for fine tip adjustments and **Home** to
center the tip. **Tab/Shift-Tab** moves between controls; **Enter** activates a
focused button. **Escape** leaves a control and returns arrows to table aim;
press it again to open the menu. Focus has a visible gold outline.
**U** restores the last shot exactly. **V** switches between overhead and lounge
cameras. After a scratch, click clear cloth to place the cue ball, or use arrows
to move its preview (**Shift** for fine movement) and **Enter** to confirm.
The last settled table saves automatically.

With Path guide enabled, an isolated first hit previews two outgoing paths: ivory
for the cue ball and dashed cyan for the object ball. The hollow ring marks contact.
Paths include the current spin/cloth model and stop before the next interaction,
or at 0.8 seconds / 0.45 meters. The readout shows estimated planar speeds at the
first-contact simulation tick; it is not a momentum percentage. Ambiguous clusters,
bank-first shots and predictions beyond the bounded horizon omit outgoing paths.

The preview includes original procedural table/ball materials and contact sounds,
soft-to-hard stroke control, follow/draw/english, collision and friction models,
ball-in-hand recovery, shot undo, and aim-assistance and sound toggles.

The initial-path guide includes launch deflection and first contact; it does not predict
throw, later spin, or rebounds. Cue contact now triggers the strike, and pocket shelves
share their geometry with the rendered slate.

Full match flow, AI, advanced jump/masse behavior, and final pocket calibration remain
in development. The independent WPA-oriented rules model and native C++ experiment
are not connected as gameplay modes.

## Build and run

```sh
bash tools/godot.sh --editor --path .
bash tools/build_mac.sh
```

The bootstrap pins Godot 4.7.2 and verifies the official editor archive SHA-256.
The Mac export bootstrap verifies the official template archive SHA-512 and installs
only its Mac template. Rebuilding the Mac app requires the Apple command-line tools
for local code signing and DMG creation. Set `GODOT` to use an existing editor.

## Checks

```sh
bash tools/godot.sh --headless --path . --script tests/run.gd
bash tools/godot.sh --headless --path . --script tests/practice_flow.gd
bash tools/run_native_tests.sh
bash tools/godot.sh --headless --path . --script tests/stroke_power.gd
bash tools/godot.sh --headless --path . --script tests/stroke_contact.gd
bash tools/godot.sh --headless --path . --script tests/save_recovery.gd
bash tools/godot.sh --headless --path . --script tests/table_geometry.gd
bash tools/godot.sh --headless --path . --script tests/pocket_support.gd
bash tools/godot.sh --headless --path . --script tests/aim_controls.gd
bash tools/godot.sh --headless --path . --script tests/practice_input_flow.gd
bash tools/godot.sh --headless --path . --script tests/audio_contacts.gd
bash tools/godot.sh --headless --path . --script tests/outgoing_guides.gd
```

See [Project state](PROJECT_STATE.md), [Physics validation](PHYSICS_VALIDATION.md),
[QA status](QA_STATUS.md), [Performance](PERFORMANCE.md), and
[Third-party notices](THIRD_PARTY_NOTICES.md). No project source license has been
selected; public visibility does not itself grant reuse rights.

## Quality targets for implementation

Read the [high-fidelity contract](docs/quality-roadmap/QUALITY_TARGETS.md), its domain target pages and [test protocols](docs/quality-roadmap/TEST_PROTOCOLS.md) before further quality work. The 140 target IDs are acceptance obligations, not a statement that the current preview meets them.
