# Shared finite pocket geometry checkpoint

Date: 2026-10-31
Status: deterministic geometry contract implemented; rendering and collision integration remain parent-owned.

## Geometry contract

`TableSpec.pocket_definitions()` now returns six cached pocket dictionaries, one per existing pocket id. Each includes mouth endpoints and center, a unit outward axis, fall and finite back endpoints, a four-point opening polygon, and three shelf support boundary edges. A shared geometry signature covers the table dimensions, mouth widths, pocket depth, shelf depths, and cut angles, so the definitions, outline, and collision segments rebuild together when any of those inputs change.

The existing nine-foot playing dimensions, mouth widths, pocket depth, and cushion nose height are unchanged: 2.54 × 1.27 m surface, 0.116 m corner mouth, 0.129 m side mouth, and 0.13 m pocket depth. The provisional shelf depths are 0.035 m at corners and 0.006 m at sides. The provisional cut angles are 142° at corners and 104° at sides. They are within the WPA's published corner shelf range of 0.0254–0.05715 m and side shelf range of 0–0.009525 m; these values are not calibrated to a physical table.

WPA specifies equal horizontal pocket cut angles of 142° (+1°) for corner pockets and 104° (+1°) for side pockets. The corner jaws therefore deviate 7° from the outward pocket axis, and side jaws 14°; the paired jaw vectors mirror about each pocket's outward axis. Jaws now run as two finite segments from their mouth lips to separate back endpoints at `pocket_depth`; they no longer converge at a single throat point. Source: [WPA Recommended Equipment Specifications, §9](https://wpapool.com/wp-content/uploads/2024/01/RECOMMENDED-EQUIPMENT-SPECIFICATIONS.pdf).

`cloth_outline()` returns one counterclockwise polygon around the slate and shelf extensions. It omits the removed corner triangles and side openings, and includes each finite fall edge. `is_supported()` includes that boundary within a 1 μm geometric tolerance. `pocket_at()` identifies the mouth-through-back pocket volume without subtracting a ball radius; shelf support remains a separate query. `outside_table()` treats a point inside the finite pocket volume as in-table lifecycle until it passes the back edge.

## Verification

- `tests/table_geometry.gd`: **154 assertions pass**, including all six IDs and widths, unit outward axes, exact shelf/back projections, 7°/14° jaw deflections, mirrored endpoints, finite jaw pairs, polygon triangulation, supported fall edges, unsupported opening regions, pocket volume bounds, and cache invalidation after shelf/table-size changes.
- `tests/pocket_support.gd`: **49 checks pass** with the parent physics integration, including supported shelves, gravity-only support loss, delayed scoring, and recovery from a shelf.
- `tests/run.gd`: **947 of 949 assertions pass**. Its two remaining failures are the legacy `_test_side_pocket_is_a_drop_event_not_a_trigger_teleport` expectations. That test expects the ball to enter FALLING after 20 ms while its center has moved only to `half_z - 0.028575 m + 0.016 m`, still short of the new mouth plane. The following capture assertion depends on the same premature entry. This test needs to start at or beyond the new mouth boundary and allow time to descend.

The geometry itself is a provisional planar support/opening model. This checkpoint does not make a claim about rail response, vertical pocket walls, ball/shelf collision, or calibrated acceptance boundaries; those stay with the physics and presentation integration and later physical reference work.

Parent integration follow-up: the two legacy early-drop assertions were replaced with a pre-edge support assertion and post-edge descent/capture checks. The full current suite passes950 assertions; no early-capture expectation was preserved as an oracle. See continuation-progress.md for integrated scope.
