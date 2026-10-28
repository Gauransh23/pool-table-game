# Performance record

Last updated: 2026-10-27

## Measurement status

No representative frame-time, physics-time, memory, package-size, loading, battery,
or thermal measurement has been recorded. The project has only been import-checked,
headlessly smoke-run, and visually opened on the current Apple Silicon macOS host.

## Initial macOS targets

These are targets to test, not results:

- Stable 60 fps in the default table view, with frame time at or below 16.67 ms.
- Typical 16-ball simulation work below 2 ms per rendered frame at 60 fps.
- No sustained 100% GPU use while the table is idle; cap idle rendering where
  platform behavior permits.
- Cold menu-to-practice load under 5 seconds on supported Mac hardware.
- Resident memory below 512 MB for the first macOS quality tier.
- Release package below 250 MB before optional language or replay content.

## Required scenarios

Measure empty table, ordinary shot, full break, clustered contacts, pocket jaw
interaction, airborne shots, rack reset, and sustained play. Record device class,
Godot version, build mode, renderer, resolution, test duration, CPU/GPU frame time,
simulation step time, memory, and observed thermal or power state when available.
