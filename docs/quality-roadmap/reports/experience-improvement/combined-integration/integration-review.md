# Automatic merge semantic review

Reviewed local `9be66f4..8973ad4` against incoming `9be66f4..015292d` and the pending merged source. Read-only production review; only this report was written. No commit, abort, source edit, or broad test run. Lead owns affected-suite execution.

## Finding: P2 — restore the actual I1 marker, not just its unused resource

In merged `scripts/presentation/table_presentation.gd`, `set_aim` resets `_ghost_ball.visible = false`, then `_draw_aim_geometry` renders `_add_contact_ring` on `_aim_material`. `set_outgoing_guide` also renders that ribbon ring. Neither path restores the torus position or visibility. `_aim_material.no_depth_test = true`, so the displayed marker also loses the target-occlusion behavior accepted locally. The cached torus and its depth-tested material still exist, which makes the topology/material checks misleading unless actual marker visibility and location are checked too.

This conflicts with the local I1 brief's explicit requirement to preserve `_ghost_ball` visibility semantics and its report's depth-tested cyan marker intent. `tests/i1_geometry.gd` already asserts a visible marker at `.3 - 2R`; these expectations are legitimate integration coverage. Incoming proportional-guide intent requires a hollow marker at the registered collision center; it does not require disabling marker depth testing. Preserve both intents by using the cached hollow marker for fallback first-hit contact and the completed replay's `prediction.contact` for outgoing contact, while retaining incoming/outgoing ribbons, proportional geometry and shared obstruction scaling. Avoid drawing both ring representations simultaneously. Retain the separately cached placement sphere.

## Fixture compatibility

The incoming ribbon renderer requires an attached viewport and production camera for projection. The isolated `tests/i1_geometry.gd` fixture constructs table/rails/aim directly and currently has neither. Minimal faithful setup before the aim assertions: `root.add_child(view)` and `view._build_camera()` before `_build_aim_and_cue()`/`set_aim`. Do not call full `build(table)`, which would duplicate already constructed geometry and change fixture indexing. This is a fixture initialization adaptation, not a production null-camera workaround: `GameController._ready` already calls `build(table)` (camera before aim) before any aim refresh. Fixing fixture initialization alone does not address the marker finding above.

## Areas without additional established regressions

- Placement still changes the shared ghost node to the cached translucent sphere, with valid/invalid colors. `_placing` calls `set_aim(..., false)` before setting placement, including with guides disabled. Ordinary aim restores the cached torus mesh; visibility must be repaired as described above.
- Guide lifecycle clears stored paths and momentum geometry on fresh aim; controller invalidates for layout/authored physics/table settings, suppresses guides during motion/pending delivery, and advances replay incrementally while idle. Camera/resize redraws reuse replay rather than restarting simulation. HUD guide-length signal, settings, prediction text and controller calls match.
- Controller, HUD, audio, project version and export preset are identical to incoming `015292d`; local I1 only overlaps presentation. Existing `play_contact(kind, speed)` and enabled APIs remain compatible. All 16 referenced recording variants and import sidecars exist. Audio randomness uses a separate RNG. No new cross-branch audio regression established.
- New script/shader/test UID sidecars have no duplicate UID among scripts/tests/assets. OutgoingGuide is a declared global class with its UID; import/global-class cache refresh belongs to normal Godot import, as already diagnosed by the lead.
- macOS preset versions/path agree at 0.3.3; `all_resources` includes local wood shader and runtime recordings; exclusions do not remove those runtime paths; explicit CREDITS.txt inclusion retains packaged attribution. Test UIDs/resources remain excluded with tests. No export-setting collision established.

## Verification boundary

This is source/commit semantic review, not renewed physics calibration, human perception acceptance, native audio latency testing, or exported build validation. Existing independent physical and perceptual limitations remain as recorded; they do not block this narrowly scoped merge review. Verdict: one marker integration correction and one fixture initialization adaptation required before scoped clean sign-off. Lead should rerun I1 geometry plus affected outgoing/proportional/aim/stroke/practice/audio suites after correction.
