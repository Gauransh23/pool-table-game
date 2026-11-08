# I1 — connected table construction and hollow contact marker

Implemented against clean `9be66f4bce9e5f741872428fef065d222d7b37ff`. Lead selected existing keyframe A (walnut/teal), then accepted v5 silhouette/material direction for this bounded slice. No branch, worktree, subagent, push, controller/HUD, physics/profile/coefficient, guide computation, camera, ball radius or physical orientation changes.

## Result and boundaries

- Replaced separate overlapping rail/jaw boxes with a continuous walnut deck, polygon-subtracted around the full mouth/jaw/back perimeter. Construction sectors are merged into two static material meshes. Full-depth apron is restricted to a 25 mm exterior band, clipped clear of cavities; interior sector boundaries do not become hanging partitions.
- Shared mitered rail/jaw cushion sections retain the exact authored nose. A 2 mm rear cushion bevel stays behind the contact nose. The entire physical jaw remains rendered: green from mouth to fall, brown facing with the **same nose cross-section** from fall to back. Brown vertical liner and narrow solid return remain behind the open fall edge. No black disk or increased acceptance mouth.
- Selected A palette: walnut `#654732`, cloth `#12604f`, cushion `#195448`, lining `#33281f`. Wood roughness .62/specular .22/nonmetallic/coat .05 suppresses the rejected point highlights. Fine wood grain has derivative attenuation. Resin roughness .23/coat .22/.20 coat roughness; physical markings and orientation source untouched. Existing lighting/exposure retained.
- First-contact preview is a hollow, depth-tested cyan torus of outer radius R and 1.2 mm radial thickness. Its center still uses the existing first-hit/rail-distance computation. `_ghost_ball` API/visibility retained. Ball-in-hand switches to a separately cached translucent sphere; aim restores the cached torus. No per-frame mesh/material creation added. Existing single-pixel line drawing remains unchanged.

## Evidence and reproduction

Durable compact originals and metadata: `docs/quality-roadmap/reports/experience-improvement/i1/`. Eight original PNGs retain matched before/after 1600 lounge and 1100 overhead, cluster 1100 lounge, placement 1100 overhead, full rack 1600 overhead, and the limited diagnostic below. `manifest.json` records SHA-256 and lengths of all external evidence, source and fixture hashes, and regression-log hashes. `capture-commands.json` preserves every exact executable/project/script/flag/output command and exit code.

Full native matrix: `/Users/codex/Documents/My Public Repos/pool-table-game-i1-evidence/`. 54 successful Godot graphical captures: before slice/rack × 1100×700/1600×900 × overhead/lounge (8); after slice/rack/cluster/placement-valid/placement-invalid/pockets0–5 × the same sizes/views (44); guide-off and unlit/overlay diagnostics at1600 lounge (2). Existing selected keyframe A and JSON are additionally preserved there. Before/after source archives and capture driver are retained externally. Every final after sidecar was checked against final presentation and fixture SHA-256; all54 commands exit0 without engine/script errors. Full matrix is source-engine framebuffer evidence, not an installed build or OS-composited screenshot. Retina/OS logical-coordinate transforms were **NOT_MEASURED**.

Engine: Godot4.7.2 official `ed1daf0bf001b61586d9930840f2f1394092c079`, Forward+/Metal4, AppleM4. Capture fixture uses a private named session path, disables controller processing and authors poses only in memory; production practice state is not loaded. Primary slice: cue(-.94,-.40),8(-1.20,-.37),14(-1.05,-.52);14 quaternion(.707107,0,0,.707107), cap physically turned away. Pocket fixtures use mouth center minus outward*.17m and tangent offsets(-.075,0,.075)m. Cluster uses cue(-.3,0),8(0,0),14(.045,.038), aim+x. Sidecars retain camera transform/size, viewport, play area, ball position/height/phase/velocity/angular velocity/orientation, shader/source hashes and projected radius-derived diameter. No fixture is a validated pocket-entry shot.

Example final command (full exact matrix in registry):

```sh
/Users/codex/Applications/Godot-4.7.2.app/Contents/MacOS/Godot --path . --script tests/i1_capture.gd -- --small --lounge --cluster --output=/absolute/output.png
```

Actual inspected images: before1600overhead; final slice both sizes/both views; final rack1600lounge; cluster1600overhead and1100lounge; placement1100overhead and invalid1100lounge; all six pocket1600lounge and all six1100overhead; guide-off and unlit/overlay1600lounge. Table-wide shape is joined, previous large wood spikes and hanging fascia partitions are gone; the hollow contact marker is visually distinct in the inspected cluster. Small transition facets/seams and dark pocket regions remain visible; no human readability/material score follows from this review. Turned14 still loses its number/group cap, as expected without the deferred identity aid. The all-neutral unlit diagnostic is **uninformative for surface separation** because it also neutralizes the room; retain it as limited overlay evidence, not a topology/material acceptance pass. World-space tests are the useful geometry oracle here.

## Checks and measured deltas

Executed with the exact engine above, each as `--headless --path . --script tests/NAME.gd`; raw logs are in the durable report directory:

| Script | Result |
|---|---|
|i1_geometry|617 checks,0 failures|
|visual_geometry|157 checks,0 failures|
|table_geometry|all assertions pass,exit0|
|pocket_support|49 checks,0 failures|
|aim_controls|0 failures|
|stroke_contact|24 checks,0 failures|
|practice_input_flow|200 checks,0 failures|
|practice_flow|42 checks,0 failures|

New focused geometry checks: exact authored nose endpoints; shared miter cross-sections<=.05mm; three physical liner walls; no fall-edge front cap; actual deck triangle winding and sampled triangle centers outside all six physical openings; built full rail/jaw nose at7 fractions per segment within .05mm of actual packed mesh edges (Godot packed-mesh quantization is included); hollow topology/depth occlusion; unchanged first-contact position, no-target visibility and sphere↔torus placement transition. These are bounded checks, not exhaustive mesh/physical accuracy certification. Slate/support and guide regressions retain their original independent coverage. `git diff --check` passes.

Matched render counters: 1600lounge three-ball slice245→229 draw calls(-16),35240→34792 rendered primitives(-448). 1600overhead rack280→264 draw calls(-16),116242→114994 primitives(-1248). These are renderer-frame counters, not standalone mesh-triangle counts or a frame-time benchmark. Two merged deck/fascia materials, one shared named wood shader,12 recessed facing instances and one cached placement sphere are introduced; separate rail boxes/apron boxes are removed. No new dynamic lights, external raster/environment dependency or per-frame material allocation. Matched frame-work<=5% budget is **NOT_RUN**; counters alone do not certify it. Projected slice diameters unchanged:1100 both views≈14.15px;1600overhead≈24.00px/lounge≈22.36px.

## Requirement ledger and remaining limits

| IDs | This slice's evidence / status |
|---|---|
|GEO-002/003/006/008|Bounded nose/seam/cavity/support checks PASS in stated samples; catalog-wide obligations remain open (no screenshot/subpixel claim). Physics geometry source unchanged.|
|VIS-001|Selected existing A and lead direction review completed; bounded construction/palette implemented. Full reference/provenance/performance acceptance still open.|
|VIS-006|Six-pocket static matrix captured and selected views inspected; sampled open-boundary/winding checks PASS. Temporal entry/rejection and complete diagnostic/LOD acceptance NOT_RUN.|
|VIS-007/AIM-006|Hollow marker and first-contact/visibility checks PASS; OS logical-width audit and human ball-versus-preview task NOT_RUN. Existing line-width implementation unchanged.|
|VIS-002/003|Human recognition and per-material ratings **NOT_RUN**. Hidden-cap14 counterexample retained; identity aid is deferred.|
|VIS-004/005/010|60s temporal deck, falling/grounding continuity and trajectory/event state-hash replay NOT_RUN. Ball rotation mapping/physics source unchanged; static pose captures do not close these.|

No broad visual or quality gate is closed by screenshot appearance or regression totals. Remaining work includes human recognition/material panels, native DPI audit, real-time stability/fall deck, all-rail dark-ball matrix, full unlit/roughness diagnostics and frame-time profiling. Independent review starts from baseline9be66f4 and raw evidence. No new borrowed art/font/texture assets; new procedural shader/meshes are authored in this change. Existing font provenance inventory remains outside this slice.

## Review correction — directed facing winding (after 8df0ed5)

Independent review found the brown one-sided fall-to-back facings had downward/inward upper normals on every a-side; the earlier nose-edge test could not detect backface culling. Corrected `_cushion_mesh()` side winding using `(b-a).cross(inward)` and corrected both end-cap orientations. Only triangle order changes; section coordinates, miter calculations, nose positions, materials, collision/profile, guides, camera and ball state remain unchanged. No two-sided workaround was applied to the brown facing.

`tests/i1_geometry.gd` now checks actual packed upper-face normals and geometric outwardness of every triangle/end cap for each full jaw and recessed fall-to-back solid, in both directed orders:48 meshes,624 added assertions. The exact revised test against8df0ed5 returns **1241 checks,312 failures,exit1**; corrected source returns **1241 checks,0 failures,exit0**. `visual_geometry.gd` returns **157 checks,0 failures,exit0**. Raw red/green/visual logs and exact commands are retained in `docs/quality-roadmap/reports/experience-improvement/i1/winding-fix/`. This is the reviewed brown-facing/full-jaw test domain, **not all built cushion solids**.

A wider exploratory test included the short green mouth-to-fall portions and exposed an additional unresolved I1 limitation. Its exact test/result are retained separately as `winding-fix/exploratory-all-intervals.gd` and `.log`:1241 checks,88 failures,exit1 on corrected source. The smaller `winding-fix/short-green-span-probe.gd` emits every physical green interval, actual bad triangle normals and signed outwardness; `.log` records **40 failing faces**,10 on each of the four intervals below. Corners0–3 have zero failures in this production-direction probe.

| Pocket/side | Mouth (x,z)m | Fall (x,z)m |
|---|---|---|
|4a|(.0645,.635)|(.063004,.641)|
|4b|(-.0645,.635)|(-.063004,.641)|
|5a|(-.0645,-.635)|(-.063004,-.641)|
|5b|(.0645,-.635)|(.063004,-.641)|

These6.184mm green side-pocket spans retain the existing29mm rear section/shared miter and contain folded non-contact rear triangles. In particular, upper triangle1 has geometric normal.y≈−.878151; this is not merely an edge-presence or screenshot finding. Green remains two-sided, but that does not correct outward normals or establish a valid solid. **GEO-006 is FAIL for this retained short-green-span fixture; I1 has an unresolved geometry limitation pending independent severity triage.** Per lead direction this correction does not redraw those vertices or alter physical nose/shelf boundaries. No target, failed row or counterexample was removed to make the scoped facing check green.

Reproduce either retained failing fixture with the same engine:

```sh
/Users/codex/Applications/Godot-4.7.2.app/Contents/MacOS/Godot --headless --path . --script docs/quality-roadmap/reports/experience-improvement/i1/winding-fix/short-green-span-probe.gd
```

Fresh affected evidence:24 native pocket captures, all six pockets×1100×700/1600×900×overhead/lounge, in `/Users/codex/Documents/My Public Repos/pool-table-game-i1-evidence/winding-fix/`. All24 completed exit0, and every sidecar's source/fixture hash matches corrected source. Inspected all six1600lounge and all six1100overhead originals, plus1600overhead pockets0/4. The connected silhouette/palette is retained; facings render without the reviewed a-side culling omission. Small transition facets remain and do not override the retained failing geometry probe. Four representative original PNGs plus JSON are committed in the new report subdirectory. `capture-commands.json`, per-image source/pose/engine metadata and a separate SHA-256/byte-count `manifest.json` identify the correction independently of the preserved initial54-capture manifest. An initial pocket0/1600lounge acquisition exceeded30s and was killed; it is recorded as invalid in `invalid-timeout.txt`, then the entire24-row matrix was rerun serially successfully. No timed-out row is counted as evidence. All prior before/after records remain intact.

Included source UID sidecars generated by lead export: `assets/shaders/wood_surface.gdshader.uid`, `tests/i1_capture.gd.uid`, `tests/i1_geometry.gd.uid`. The five power/measurement UID sidecars remain untouched and untracked for lead ownership: `tests/measurement/power_atlas_fixture.gd.uid`, `run_acquisition.gd.uid`, `shot_fixture.gd.uid`, `trace_stepper.gd.uid`, and `tests/power_response_atlas.gd.uid`. No push. Human/OS-DPI/temporal/frame-time/recognition/material gates retain their earlier NOT_RUN status.
