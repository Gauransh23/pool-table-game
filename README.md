# Long Rail

An original, offline pool game in development. The current Mac preview concentrates
on a polished practice room and a precise stroke rather than a complete match system.

## Try the Mac preview

Build output: `build/Long Rail-0.2.0-mac.dmg`. Open it and drag **Long Rail** into
**Applications**, then open the app. This local preview uses an ad-hoc signature;
Developer ID notarization is not configured.

Aim with the pointer, choose power and tip position, then click **Take Shot** or
press **Space**. Left/right arrows fine-tune aim; hold Shift for finer steps.
**U** restores the last shot exactly. **V** switches between overhead and lounge
cameras. **Escape** opens the menu. After a scratch, click a clear place on the cloth
to put the cue ball back in play. The last settled table saves automatically.

The preview includes original procedural table/ball materials and contact sounds,
soft-to-hard stroke control, follow/draw/english, collision and friction models,
ball-in-hand recovery, shot undo, and aim-assistance and sound toggles.

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
```

See [Project state](PROJECT_STATE.md), [Physics validation](PHYSICS_VALIDATION.md),
[QA status](QA_STATUS.md), [Performance](PERFORMANCE.md), and
[Third-party notices](THIRD_PARTY_NOTICES.md). No project source license has been
selected; public visibility does not itself grant reuse rights.
