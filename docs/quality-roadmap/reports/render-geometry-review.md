# Render and geometry consistency review

Date: 2026-10-31
Scope: read-only audit of the current `TablePresentation` renderer against `TableSpec`; no art-parity or physical-calibration claim.

## Findings

### P2 — Called-pocket markers use positions that disagree with the shared definitions

`TablePresentation.pocket_positions()` still places the four corner markers at `(±(half_x−0.028), ±(half_z−0.028))` and side markers at `(0, ±(half_z−0.028))` ([table_presentation.gd:503](../../../scripts/presentation/table_presentation.gd:503)). The shared pocket centers are `(±(half_x−corner_mouth/(2√2)), ±(half_z−corner_mouth/(2√2)))` for corners and `(0, ±half_z)` for sides. With current defaults, each corner marker is displaced about 13 mm outward along both axes from its definition center; each side marker is 28 mm inside the mouth plane. When the called-pocket indicator is shown, its ring is therefore not centered on the same geometry used by the cloth, well, and collision jaw. Build marker positions from `pocket_definitions()` or another shared definition field.

### P2 — The configured minimum window aspect is not represented by the small capture

The current `quality-small.png` capture is **1100×618**, while `project.godot` declares a minimum of **1100×700** ([project.godot:26](../../../project.godot:26)). At 1100×618 the visible table nearly meets the right HUD panel, leaving roughly 19 px between the rail and panel. The camera keeps a fixed orthographic size of 2.15 and the HUD panel is anchored with a fixed 286 design-unit width ([table_presentation.gd:332](../../../scripts/presentation/table_presentation.gd:332), [game_hud.gd:57](../../../scripts/ui/game_hud.gd:57)). A capture at the declared 1100×700 minimum is needed to establish whether the taller viewport expands the table into the panel. Treat this as an unverified clipping risk; adjust the camera/table viewport reservation if an exact-minimum capture confirms overlap.

## Consistency checks that passed

- Cloth and slate use the same `TableSpec.cloth_outline()` polygon. The cloth is rendered at `y=0`, and the slate mesh draws only side walls, so it does not add a horizontal cap behind the holes. The current `tests/visual_geometry.gd` checks upward cloth normals, matching support height, and that generated slate triangles stay inside `is_supported()`.
- Pocket liner walls and floors both use the `opening` polygon from each pocket definition. Its fall edge matches the outer cloth boundary, and its back edge matches the finite jaw endpoints.
- Cushion nose vertices start at the same `a/b` world-space points used by `rail_segments()`, at `cushion_nose_height`. The cushion body extends along `-inward`; the wood rail is offset to that same outside side. In the overhead and lounge captures, the finite jaws meet the visible pocket openings without an obvious detached segment.
- The 1600×900 overhead and lounge stills show all six openings and the table perimeter in frame. The number caps face upward in these initial states; the ball node then applies the simulation quaternion. The captures do not establish how labels read during rolling because they are static images.

## Evidence limits

Reviewed `captures/shared-geometry-overhead.png` and `captures/reflections-lounge.png` at 1600×900, plus `captures/quality-small.png` at 1100×618. No exact 1100×700 capture or rolling clip was available for this pass. Source agreement and still captures support geometry consistency only; they do not establish material quality, motion quality, or parity with a commercial reference.

Parent follow-up: called-pocket marker positions now come directly from `pocket_definitions().mouth_center`. The small capture records window/design/viewport/image dimensions separately; a fixed-aspect canvas can produce a 1100×618 render inside a taller window without expanding the table into the HUD. This explains why a render-texture capture alone is not a full-window screenshot. Minimum-size readability remains a perceptual review item.
