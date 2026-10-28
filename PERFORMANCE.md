# Performance record

Last updated: 2026-10-27

## Measurement status

Repeatable headless GDScript and standalone C++ physics microbenchmarks are recorded
below. This is not a full frame-time, memory, package-size, loading, battery, or
thermal profile. Godot was launched in its editor/debug build; an exported release
build has not been measured.

### 16-ball break microbenchmark

Command: `bash tools/godot.sh --headless --path . --script res://tests/benchmark_breaks.gd`

Setup: 16-ball 8-ball rack, 7.5 m/s center cue strike, four seconds simulated at a
1/480 s fixed step, 60 Hz time chunks, Godot 4.7.2 stable, Apple M4 host, headless.

| Run | Wall time |
|---:|---:|
| 1 | 289.9 ms |
| 2 | 288.4 ms |
| 3 | 291.6 ms |

The current GDScript core advances about 13.8 simulated seconds per wall second in
this scenario. The result excludes rendering and is not representative of every
position. An earlier pre-cache run took 620–626 ms; cache and physics changes landed
between those runs, so the difference cannot be attributed to caching alone.

An AI budget of 300 candidates × 8 execution samples × 4 seconds would be 9,600
simulated seconds. Linear projection from this microbenchmark is about 12 minutes per
decision on this host. That is an estimate, not an AI benchmark, and makes native
simulation and smarter search/pruning a high-priority experiment.

### Standalone C++ core comparison

Command: `bash tools/run_native_tests.sh --benchmark`

Setup: same 16-ball rack, foot spot, 7.5 m/s center cue strike, four seconds
simulated at a 1/480 s fixed step, and 60 Hz time chunks. The standalone core was
compiled with the system C++ compiler using `-O3`, `-ffp-contract=off`, and
`-fno-fast-math`. It is not loaded by Godot, and its state output has not been checked
for parity with GDScript.

| Run | Wall time |
|---:|---:|
| 1 | 6.19 ms |
| 2 | 4.56 ms |
| 3 | 4.25 ms |
| 4 | 4.20 ms |
| 5 | 4.30 ms |
| 6 | 3.85 ms |
| 7 | 3.76 ms |

Median: 4.25 ms, about 68× faster than the latest GDScript measurement in this
workload. The compiler/build modes differ (optimized standalone C++ versus Godot
editor/debug GDScript), so this is a direction-setting comparison rather than an
apples-to-apples runtime claim. A 300-candidate × 8-sample × 4-second workload would
linearly extrapolate to roughly 10 seconds in this C++ microbenchmark, before AI,
wrapper, allocation, and scheduling overhead. This is not an AI benchmark.

## Initial macOS targets

These are targets to test, not results:

- Stable 60 fps in the default table view, with frame time at or below 16.67 ms.
- Typical 16-ball simulation work below 2 ms per rendered frame at 60 fps.
- No sustained 100% GPU use while the table is idle; cap idle rendering where
  platform behavior permits.
- Cold menu-to-practice load under 5 seconds on supported Mac hardware.
- Resident memory below 512 MB for the first macOS quality tier.
- Release package below 250 MB before optional language or replay content.

## Native-core investigation

The standalone double-precision C++ experiment now has a 1,601-point cut-angle
regression and ball/cushion time-of-impact estimates. Its measured speed makes native
integration promising. Before adding AI search, compare canonical state and event
outputs against GDScript, build a thin GDExtension bridge, and verify macOS first plus
Android, Linux, and iOS build feasibility. Do not mark a native migration complete
until physics output and target builds are verified.

## Required scenarios

Measure empty table, ordinary shot, full break, clustered contacts, pocket jaw
interaction, airborne shots, rack reset, and sustained play. Record device class,
Godot version, build mode, renderer, resolution, test duration, CPU/GPU frame time,
simulation step time, memory, and observed thermal or power state when available.

## Mac preview 0.2.0 — 2026-10-28

The playable GDScript TOI-normal/event version takes 308.8, 308.5, and 309.5 ms for
the same four-second headless break workload. This supersedes the previous GDScript
numbers. Event/snapshot work adds cost. Idle aim geometry now rebuilds only when its
inputs change; the app caps rendering at 60 fps. Full GPU/frame pacing and thermal
profiling is still open. Universal app: approximately 162 MB; DMG: 64 MB.
