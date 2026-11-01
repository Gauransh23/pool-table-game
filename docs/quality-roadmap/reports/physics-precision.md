# Physics precision and pocket support scout

Date: 2026-10-31. Scope: measure the checked-in GDScript solver at fixed steps and probe the checked-in pocket capture rule. No physics implementation changes were made.

## Result

**CONDITIONAL.** The analytic frictionless fixtures conserve momentum and total energy, pure rolling agrees closely with its independent constant-resistance solution, and mirror pairs agree to floating-point precision. The playable collision cases miss the proposed successive-resolution endpoint bound at 960→1920 Hz. The baseline pocket classifier immediately marks stationary balls as falling at all six mouths while their centers remain about 27.6 mm inside the table-edge planes. The evidence supports a geometry/support redesign before further coefficient tuning.

## Provenance and execution

The valid run used a clean `git archive` of `5788954d8b6c9111177888a04b529400c86ac926`, extracted to `/tmp/pool-table-physics-baseline-20261031`; the harness was copied there and run with Godot `4.7.2.stable.official.ed1daf0bf` after headless editor import. The baseline source hashes are recorded in [runs.json](physics-precision/runs.json) and repeated on every row of [runs.csv](physics-precision/runs.csv). The exact harness used for that run has SHA-256 `7adaead735a73350195dd96e78b231b0d747c1fc65599f09d8a2219057a2fb7d`; the current harness differs only by added source-hash metadata.

During parallel S6a work, a separate worktree rerun called `TableSpec.is_supported()` before that method existed. Its six support rows are invalid and preserved separately as [runs-interrupted-after-s6a-invalid.json](physics-precision/runs-interrupted-after-s6a-invalid.json) and [runs-interrupted-after-s6a-invalid.csv](physics-precision/runs-interrupted-after-s6a-invalid.csv). They are excluded from the result below. The clean-HEAD run is the authoritative measurement here.

Command in the scratch project:

```sh
Godot --headless --editor --path . --import
Godot --headless --path . --script tests/physics_precision.gd
```

The harness contains 48 dynamic runs (240/480/960/1920 Hz), six two-point static support probes, initial configuration and state, terminal state, per-event records, event counts/ticks, linear momentum, and translational/rotational/vertical energy. It reports measured threshold misses but exits successfully so a failed quality target does not discard the data.

## Measurements

The convergence comparisons use each case's final ball positions and planar travel directions. The target is at most 0.5 mm and 0.1° between consecutive resolutions.

| Case | 960→1920 endpoint difference | 960→1920 direction difference | Result |
|---|---:|---:|---|
| Head-on, playable defaults | 0.621 mm | 0° | Fails position |
| Cut, positive and mirrored negative | 0.568 mm | 0.0455° | Fails position |
| Head-on, four impact phase offsets | 0.521 mm each | 0° | Fails position |
| Rail rebound with ±18 rad/s side spin | 0.0503 mm | 0.000064° | Passes this fixture |
| Pure rolling | 0.0108 mm | 0.00046° | Passes this fixture |

Across all 30 adjacent-resolution comparisons, 20 exceed at least one bound. The worst comparison is cut-positive 240→480 Hz at 2.279 mm and 0.1818°. Head-on playable-default output is non-monotone: its endpoint delta is 2.521 mm at 240→480, 0.340 mm at 480→960, then 0.621 mm at 960→1920. The phase-shifted head-on cases place the same impact at 0, 0.25, 0.5, and 0.75 of a 240 Hz step; first-contact event ticks move between 24 and 25. The event tick is a solver observation tick, not a true impact timestamp.

The tested defaults were ball mass 0.168 kg, ball restitution 0.94, ball friction 0.055, cushion restitution 0.84, cushion friction 0.12, sliding friction 0.19, rolling resistance 0.012, and spinning friction 0.0127. Collision cases used 2 m/s; cuts used a 25 mm impact offset. Rail cases used 1.2 m/s and opposite ±18 rad/s vertical-axis spin. Pure rolling started at `(0.5, 0.3) m/s` with angular velocity set for no-slip rolling.

Independent checks were deliberately separated from playable defaults:

- Frictionless equal-mass head-on at 1920 Hz matched the analytic outgoing velocities exactly; linear momentum error and total energy error including rotation were both zero.
- Frictionless cut at 1920 Hz matched analytic outgoing velocities within `6e-8 m/s`; momentum error was zero and total energy including rotation differed by `1.74e-8 J` from 0.336 J.
- Constant rolling resistance predicts 0.742208 m travel over 1.5 s; the solver gave 0.742137 m (0.071 mm, 0.0095%). Terminal speed error was `9.34e-6 m/s`. Translational and rotational terminal energies were 0.013881 J and 0.005552 J.
- Cut mirror pairs were exactly reflected in measured position, velocity, spin and event counts. Rail-spin mirror endpoint discrepancy was `2.4e-8 m`; velocity and spin discrepancies were zero.

These checks establish implementation consistency on clean fixtures, not real-table accuracy. The analytic collisions intentionally disable friction and use restitution 1. The rolling check assumes constant deceleration and exact initial rolling. The solver and harness share the same Godot vector/state conventions, so they are not independent evidence for contact modeling outside those closed-form cases.

## Pocket support evidence

For all six pockets, a stationary center only 1 mm inside the current `pocket_at()` threshold remains `IN_PLAY`; moving it 1 mm beyond that threshold, while still within the rectangular table bounds, immediately sets `FALLING` and injects `-0.28 m/s` vertical speed on the first 480 Hz step. Each of the six trigger samples records one pocket event on tick 1. The full per-pocket coordinates and event records are in `runs.json`.

At corner mouths, the trigger sample is at `x=±1.242425 m`, `z=±0.607425 m`: 27.575 mm inside both rectangular edge planes. At side mouths, it is at `x=0`, `z=±0.607425 m`: 27.575 mm inside the end plane. These are based on the source's half dimensions `(1.27, 0.635) m` and ball radius `0.028575 m`. The handoff's prior 27.58 mm observation is reproduced. This probe exposes the classification rule; it does not establish where a physical shelf edge belongs.

The source model uses rectangular `outside_table()` bounds plus center-region `pocket_at()` tests. Those tests cannot encode cloth support, an aperture contour, finite jaws, a shelf, or irreversible descent. Moving the thresholds to make a smaller rectangle would trade false capture for unsupported cloth near the mouth. The visual/render path and the physical support path must share actual pocket openings.

## Next safe step

Freeze a source-backed table and pocket coordinate specification before changing solver coefficients. Represent the bed as a surface with six explicit apertures, plus finite jaw/facing geometry, shelf/support surfaces, and below-slate drop volumes. Generate the cloth mesh/cutouts and collision/support queries from that same geometry data. Keep the rest of the table surface continuous; do not approximate six openings by shrinking the whole bed rectangle. Add a debug view that overlays rendered cloth boundaries, collision surfaces, support regions and capture volumes at overhead and close-up scales.

Then probe both sides of each measured support boundary: stationary/hanging balls, slow roll-in, jaw-first, shelf rest, grazing miss, and rebound back to cloth. Assert no capture while a supported contact surface remains, and emit the scoring pocket only after irreversible descent below the slate. Use verified table/pocket dimensions or explicitly provisional geometry; do not tune pocket dimensions by eye to clear this numerical report.

Keep the solver convergence work separate: test improved impact-time integration against the same analytic head-on/cut fixtures and phase sweep, retaining the 0.5 mm/0.1° threshold. Preserve rotational energy in every collision/rail comparison. Do not infer physical fidelity from the high-resolution result alone.

## Limits

This is a bounded isolated fixture set, not the full speed/cut/spin matrix, seeded breaks, renderer comparison, WPA geometry validation, or physical-table calibration. It does not validate rail coefficients or pocket acceptance boundaries. No implementation was changed and no visual capture was made during this checkpoint.
