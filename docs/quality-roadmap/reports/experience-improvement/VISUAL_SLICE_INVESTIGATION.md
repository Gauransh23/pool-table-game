# Task I — pocket and three-ball visual investigation

Research baseline: `98287008b8d5286d78a4e0e6bb68d56b3f5b7d5e`, 2026-11-06. Read AGENTS.md, QUALITY_TARGETS.md, generated controls/presentation targets, geometry GEO targets and POC-008, and F-VISUAL/F-PERCEPTION protocols. This is an implementation-ready visual diagnosis, not an implemented art pass or an acceptance result.

## Recommendation

Build **one corner pocket (ID 1, negative x/negative z) with cue ball, 8 and 14**, in the current original walnut/green visual language, before extending the treatment to the other pockets. Prioritize joined construction, readable resin form and honest identification. More texture alone will leave the largest defects intact. Overhead remains the primary play camera. Keep lounge a presentation view until near-rail/hidden-cap recognition and visibility tasks pass there.

Select the restrained walnut/teal alternative below for lead review. This is the investigator's recommendation; lead/owner art approval and the required three rendered matched alternatives have **NOT_RUN** status. No full-table redesign is justified by the evidence.

## Evidence and isolation

Inspected source: TablePresentation, BallVisual, all three surface/reflection shaders, TableSpec, BallState, GameController, marking generator, project display settings and capture harness. Inspected existing `captures/shared-geometry-overhead.png`, `captures/reflections-lounge.png` and `captures/quality-small.png`; those are historical examples without a verified source/hash manifest and are not current acceptance evidence.

Current captures ran the actual Godot **4.7.2 stable official ed1daf0bf**, Forward+ / Metal 4.0, Apple M4 renderer. Copied `assets`, `scripts`, `scenes`, `tests`, `.godot` and `project.godot` into `/var/folders/tx/vjn4y65n68l2rkvyqlcnf8fw0000gp/T/longrail-task-i-80xmvlh8`. Only the temporary project's application custom-user-directory setting was changed; capture harness also assigns a private session path before adding GameController to the tree. No production practice save or export was opened or overwritten. The temporary harness disables controller processing and authors fixture positions/orientation solely in memory; it does not alter active gameplay source, coefficients or physical orientation policy.

Commands (run serially; quoted absolute executable/project paths):

```sh
GODOT='/Users/codex/Applications/Godot-4.7.2.app/Contents/MacOS/Godot'
CAPTURE_PROJECT='/var/folders/tx/vjn4y65n68l2rkvyqlcnf8fw0000gp/T/longrail-task-i-80xmvlh8'
"$GODOT" --path "$CAPTURE_PROJECT" --script tests/capture_preview.gd -- --spread --output=/tmp/task-i-overhead-1600.png
"$GODOT" --path "$CAPTURE_PROJECT" --script tests/capture_preview.gd -- --spread --small --lounge --output=/tmp/task-i-lounge-1100.png
"$GODOT" --path "$CAPTURE_PROJECT" --script tests/task_i_capture.gd -- --small
"$GODOT" --path "$CAPTURE_PROJECT" --script tests/task_i_capture.gd --
"$GODOT" --path "$CAPTURE_PROJECT" --script tests/task_i_capture.gd -- --lounge
"$GODOT" --path "$CAPTURE_PROJECT" --script tests/task_i_capture.gd -- --small --lounge
"$GODOT" --path "$CAPTURE_PROJECT" --script tests/task_i_capture.gd -- --full
```

All seven capture commands exited 0. PNG dimensions equal the requested window-sized render textures; viewport sizes match. Design size remains 1600×900. These are graphical source-engine framebuffer captures, **not OS-composited desktop screenshots, installed-release evidence, OS pixel-ratio measurements or latency/performance evidence**. No claim about Retina OS logical units follows from them. A diagnostic crop attempt was abandoned because Pillow is unavailable; no crop is included or counted as evidence.

The slice contains cue at `(-0.94,-0.40)`, 8 at `(-1.20,-0.37)`, 14 at `(-1.05,-0.52)`, all at radius height. Cue and 8 orientation identity; 14 quaternion `(0.707107,0,0,0.707107)` turns its physical number cap away. The guide is aimed toward 14. This is a visibility fixture, not a validated executable shot or pocket-entry fixture.

| Source framebuffer | Camera | Projected ball diameter | Play area |
|---|---|---:|---|
|1100×700|overhead|14.15 px|742×564|
|1100×700|lounge|14.15 px|742×564|
|1600×900|overhead|24.00 px|1242×740|
|1600×900|lounge|22.36 px|1242×740|
|1920×1080|overhead|30.31 px|1562×920|

Diameters are camera-projected world-radius endpoints in camera-right direction, not manually estimated bright-pixel bounding boxes. At minimum size width limits both cameras, explaining equal diameters; lounge still compresses table depth and increases rail occlusion. Print precision is not perceptual accuracy. Native desktop scaling and human recognition remain unmeasured.

Inspected new images: `/tmp/task-i-overhead-1600.png`, `/tmp/task-i-lounge-1100.png`, `/tmp/task-i-slice-1100-overhead.png`, `/tmp/task-i-slice-1600-lounge.png`, `/tmp/task-i-slice-1920-overhead.png`, `/tmp/task-i-slice-1100-lounge.png`. The 1600 overhead slice was generated with metadata but not separately visually inspected. `/tmp` is temporary review evidence, not a durable release archive; lead should preserve selected originals plus hashes in its acceptance package before temporary cleanup.

## Observed defects and their exact causes

| Finding | Direct visual/source evidence | Consequence / confidence |
|---|---|---|
|Pocket reads as a black polygon; lounge exposes disconnected strips|Current captures show angular dark corner/side openings and projecting green strips. `_pocket_liner_mesh()` builds only three vertical quads, from +2R to −0.18 m, with a flat bottom; `_cushion_mesh()` is a sharp three-point prism; `_build_rails()` independently boxes every jaw/rail.|Observed construction weakness. Missing lining thickness, stitched/rounded lip and material joins are source facts. Screenshot alone cannot certify collision misalignment.|
|Wood/cloth/cushion are too similar in form and value|Current overhead shows broad flat brown rail bands and green facings blending into bed. Cloth has subtle albedo-only weave, rubber one flat roughness value, wood a sine albedo pattern and uniform response.|Observed limited separation; exact perceptual material scores remain NOT_RUN. Keep cloth restrained; solve form and response before adding grain.|
|14 loses both group and number cues in legal orientation|Quarter-turned fixture shows a nearly white disc with a thin green edge; at 1920 it still resembles another cue ball. Shader stripe is local `abs(p.y)` band; number exists only on two `abs(p.z)>0.83` caps. BallVisual initial local sphere rotation puts caps overhead only at initial orientation.|Observed counterexample to assuming overhead caps solve ongoing identity. Number recovery cannot be guaranteed by brighter lighting or larger artwork when the marking is physically hidden.|
|Dark balls have weak body cues next to dark rails|8 is black with a small warm cap; dark silhouette is readable in this fixture but resin shading is weak. Base 8 is `#121718`; narrow bright reflection and green ambient favor dark body merging.|Readability risk, not measured recognition failure. Must add 6/7/8 against every rail and pocket lining before assigning a VIS-002 result.|
|Guide uses the same visual family as real light balls|Filled cream ghost uses alpha .24 and no depth test; cue/14/ghost form three pale circles in fixture. Main line also has no depth test.|Observed confusing grouping. Source permits drawing over intervening balls; clusters must establish actual masking severity. No blinded accuracy collected.|
|Apparent ball scale is the limiting budget|Minimum-size diameter is only 14.15 framebuffer px; number cap spans only a fraction of that. `_fit_camera()` includes outer rails, wells, apron, feet and y −.79 to +.10 bounds in both views.|Measured projected scale. All-table legs are useful for presentation but consume play area in lounge. Increasing ball mesh radius would violate scale/contact agreement.|
|Material light response can obscure numbers|Shader uses roughness .16, clearcoat .65/.12; static ceiling reflection is a bright narrow softbox; three warm spots plus sun illuminate a small object.|Small glossy balls observed; highlight competition is plausible source-derived risk, not a demonstrated clipped-white-patch statistic. Need fixed-exposure white/cap deck.|
|Shadow/fall continuity is insufficiently characterized|BallVisual adds a 3.4R plane, fixed alpha .48, height-based scale, on top of shadow-casting sphere; `is_on_table()` includes airborne but excludes falling. Ball hides when center height<=−.08 although well bottom is −.18.|Source-confirmed discontinuities and possible double-grounding. Existing stills do not establish a visible temporal pop; falling/airborne clips are required.|
|Wood can crawl and has wrong local grain axis on some pieces|`_wood()` uses local VERTEX.z frequencies 280/830 with no derivative fade; rail length is local x. Cloth already attenuates its fine weave with fwidth.|Source-confirmed aliasing risk and crosswise repeated grain. Temporal failure not established; 60s real-time deck required.|

There is no evidence here to change ball radius, cloth support polygon, shelf, pocket mouths, jaw angles, power or solver. The existing geometry contract is the boundary for art.

## Three feasible original directions, matched to the same slice

| Alternative | Concrete treatment | Strength / cost / risk |
|---|---|---|
|A — restrained walnut and teal (recommended)|Keep emerald/teal cloth, medium warm walnut, subdued warm sights; use dark brown recessed lining, a narrow mid-value facing/lip, ivory resin, broad soft highlights. Replace disconnected jaw boxes with joined transitions.|Fits existing typography and palette, reuses original procedural work, most effort goes to geometry/identity. Requires dark-ball rim/form separation without an artificial emissive halo.|
|B — pale ash and slate blue|Same physical meshes, pale neutral ash rails, cool blue cloth, graphite lining, less brass; neutral studio lighting and ivory balls.|Makes dark balls/lining easier to separate from rail but requires UI/background palette review and all colored-ball contrast checks. Blue 2/10 may merge with cloth; increased full-product art scope.|
|C — graphite tournament table and muted blue-green|Same physical meshes, satin charcoal rail, muted blue-green cloth, sparse warm metal/sights, brighter neutral cloth illumination.|Restrained modern silhouette, smallest wood-texture burden; hardest black-ball/rail contrast and pocket-depth separation. Avoid solving this with exaggerated outlines/high exposure.|

These are original parameterized art proposals, not third-party references or generated imagery. Implement all three as **material/light presets over identical fixture geometry** and render the same pocket/balls, exposure/camera/size. No unrelated whole-table concepts are needed. Lead should compare form, each material and identity separately; choose A provisionally because B/C increase palette risk without fixing the source construction defects. Rendered three-keyframe comparison and human material ratings remain NOT_RUN.

## Executable pocket/three-ball slice

Bounded owners: `scripts/presentation/table_presentation.gd`, `scripts/presentation/ball_visual.gd`, `assets/shaders/ball_surface.gdshader`, `assets/shaders/cloth_surface.gdshader`; factor the inline `_wood()` shader into a named presentation shader only if useful to the presets. Presentation fixtures/capture harness are the verification owner. Do not modify sim/gameplay owners for this slice.

1. **Freeze geometry input and fixture.** Read pocket 1's `mouth_a/b`, `fall_a/b`, `back_a/b`, `outward`, `opening` from TableSpec, and the exact adjacent rail segments. Keep TableSpec untouched. Source capture must serialize full position/height/orientation/phase, camera, guide and lighting parameters, source/asset hashes and framebuffer/OS transform metadata. Add a separate pocket-1 near-jaw fixture; the existing three-ball fixture is not at the mouth.
2. **Join pocket construction in `_build_pockets()`, `_pocket_liner_mesh()`, `_build_rails()` and `_cushion_mesh()`.** Retain the opening and nose-contact vertices exactly. GEO-002 limits visible/contact discrepancy to <=0.25 mm world space; GEO-006 requires outward render normals and intended contacting seam gaps <=0.05 mm. Verify these from mesh/world coordinates, not pixel inspection. Add visual thickness to the outer/back side of liner walls, a shallow recessed inside return and facing strip tied to the same endpoints; keep the front fall edge open. Round only non-contact silhouette edges away from the legal ball envelope. Start with a 2–3 mm outer lip/facing bevel and 1–2 mm wood edge transition as authoring trials, never new physical acceptance tolerances. A 2 mm bevel projects to <1 px at normal play, so judge its light response and joint continuity, not enlarged beauty crops. Prevent lip geometry filling the cutout or moving the apparent contact edge. Resolve jaw/rail termination by explicit trimmed joins, not intersecting full boxes. Confirm unlit/topology/collision overlay before materials. Limit treatment to pocket 1 and adjacent spans until reviewed.
3. **Separate materials in `_build_lighting()`, `_wood()`, cloth shader and `_mat()` call sites.** Preserve a single fixed exposure across alternatives. Trial resin body roughness .20–.26 and coat .15–.22, broad lower-intensity neutral softbox; matte cloth .88–.95; cushion/facing .70–.85 with its own slightly different hue/value; satin wood .35–.45 with coherent longitudinal grain; dark lining .85–.95 with a visible lip and darker recess. These are trial art parameters requiring review, not measured real-material constants or quality-contract changes. Keep cloth high frequencies derivative-filtered, add equivalent wood filtering, avoid deep albedo grooves or oversized fiber normals. Use one coherent broad key/reflection and enough neutral fill for 8/7/6 body cues. Do not raise all ambient values until the recess becomes flat.
4. **Keep physical markings in `BallVisual.configure()/sync_from()` and ball shader.** Keep `quaternion=state.orientation` and local authored cap orientation. Improve numeral antialiasing/contrast only within visible physical caps; retain 6/9 distinguishing mark. Add a declared optional separate screen-space identity aid through TablePresentation's ball projection owner: a small externally anchored number/group badge, visually distinct from resin and guide, shown on deliberate inspection or a declared readable mode. Never billboard physical caps, move stripe texture with camera, or alter state orientation. Cluster layout must reserve badge space/leader lines and test what happens when every badge is shown; hidden caps cannot be solved by texture alone.
5. **Give guide its own grammar in `set_aim()` / `_build_aim_and_cue()`.** Trial hollow/dashed contact ring with explicit first-contact meaning, no filled cream sphere resembling a real ball. Depth-aware drawing or a controlled occlusion mask must keep target edge/contact visible. Audit a 1–2 OS-logical-unit overhead stroke with <=.5 variation through DPI/zoom instead of assuming PRIMITIVE_LINES supplies a portable width. Keep first-contact distance/direction algorithm unchanged; no outgoing ray is justified by this art work.
6. **Resolve grounding in `BallVisual.sync_from()`.** Decide one contact-shadow system; avoid a second fixed blob under dynamic shadow. Fade/contact-size must use actual support/height, keep airborne shadow on cloth and transition consistently at shelf/fall; do not switch physical phase to make art simpler. Review the −.08 visual hide cutoff against six well camera occlusions before changing presentation-only visibility. Physical capture/pocket state and physical orientation remain authoritative.
7. **Camera in `_fit_camera()` / `set_overhead()`.** Primary overhead should fit needed playable surface/rails with cue/aim context at minimum window. Consider a presentation-specific bound including feet only for lounge; do not enlarge balls or shrink physical table. Lounge gets a clearly indicated presentation role unless the complete recognition/near-rail matrix passes. Preserve picking/aim across any framing change; existing camera tween does not establish native continuity by itself.

Candidate slice budget proposal for lead to freeze: no new external raster/environment dependency; no new per-frame shader/material creation; static pocket meshes/materials reused; no extra dynamic shadow-casting lights; <=5% unexplained matched frame-work regression triggers investigation under existing protocol. Record triangle/material/draw-call deltas and shader cost rather than claiming this budget already passes. No benchmark was run here.

## Required acceptance capture matrix

Every static row: actual 1100×700,1600×900,1920×1080 framebuffers; overhead and lounge; supported Retina/native OS modes additionally measured, not simulated by resizing a screenshot. Capture final exposure and unlit/topology, roughness and collision-overlay diagnostics where relevant. Include guide on/off. Keep camera transforms, fixture and image hashes. Lead owns geometry/material review; presentation implementer owns immutable fixtures; independent human reviewer owns recognition/material trials.

| Fixture | Specific counterexample / evidence | Requirement mapping |
|---|---|---|
|Rack plus all-15 spread|All identities at actual gameplay pixels; crop only as secondary diagnostic|VIS-001/002/003/009|
|Each of pockets 0–5, mouth center and both jaws|Support shelf, open fall edge, facing/liner depth; no intersecting corner or detached strip in either view|VIS-006, GEO-002/003/006/008|
|6/7/8 at each rail and beside liner|Body silhouette survives dark neighbor/highlight; aid on/off|VIS-002/003|
|9–15 stripe caps turned away at several legal quaternions|Number/group recovered only through declared aid; cue remains distinct|VIS-002/005|
|Dense cluster under contact guide and cue crossing|Ball/ghost classification, contact edge not hidden; line-width audit in OS logical units|VIS-007, AIM-006|
|Cue ball under highlight; 8 highlight on/off cap|No washed-out white cap; recognizable resin form, material ratings per class|VIS-002/003|
|Slow entry, jaw rejection and falling at all six pockets|Frame sequence + normal-speed review, shelf/liner coherent; shadow/hide continuity|VIS-005/006, POC-008|
|60s real-time adversarial deck|Slow diagonal roll, pure rotation, moving cluster, break, rattle, camera/zoom, guide toggle, undo/reset; no crawl/pop/seams|VIS-004/005, FEL-005|
|Native window/DPI/zoom changes|Record OS logical coordinate→framebuffer transform and 1–2-unit guide width; apparent ball size retained|VIS-007/008/009, AIM-003|
|Matched visual-option replay|Identical trajectory/event/full-state hashes; renderer cannot change physics|VIS-010/005|

Complete F-PERCEPTION recognition deck: final >=20 independent people (>=10 per expertise group), 15 identities×10 presentations×2 views per person, balanced difficult contexts, 2s exposure/3s response timeout, misses incorrect, frozen primary stratum counts and participant-clustered uncertainty. >=95% per required identity/view/expertise and difficult-context/view/expertise descriptive sample strata, plus separate actual/ghost deck. Pilot of 8 can select directions/find defects; it cannot certify final recognition. Rate cloth, wood, cushion/facing, resin, lining and cue individually; each median>=4/5. These thresholds are unchanged. Neither screenshots nor source constants pass them.

Status: VIS-001 implementation/three matched keyframes/lead review NOT_RUN; VIS-002 human recognition NOT_RUN with hidden-cap counterexample retained; VIS-003 panel NOT_RUN; VIS-004 real-time deck NOT_RUN; VIS-005 fall/orientation continuity NOT_RUN; VIS-006 complete six-pocket acceptance NOT_RUN (observed construction issues retained); VIS-007 OS-width/human tasks NOT_RUN; VIS-009 full task occlusion NOT_RUN; VIS-010 state-hash comparison NOT_RUN. No requirement closed by this research.

## Provenance, changes and artifacts

Existing shaders/procedural meshes are authored in repository. `tools/generate_ball_markings.gd` documents original number composition with Godot `ThemeDB.fallback_font`; this is source evidence of generation method, **not a completed license inventory**. Before publishing assets, record the exact Godot font source/license and engine third-party notices, generator/PNG hashes and author/date; record shader/mesh authorship and any future borrowed texture/environment license. No new external art was downloaded or generated here.

Only repository file authored by this investigation: this report. Existing exports, gameplay/source files, saves and thresholds are preserved. Concurrent teammates may create untracked `tests/fixtures/` and `tests/measurement/`; they are not this task's changes. Temporary copy/config/harness, PNGs and JSON metadata are the only other writes. No branch/worktree/commit/subagent created.

Artifact hashes (SHA-256):

- `/Users/codex/Documents/My Public Repos/pool-table-game/scripts/presentation/table_presentation.gd` — `140a2a81c4cc090b892edb23d5dcb078ea3da004fc8b6b68a10c5eda3a52bfa7`
- `/Users/codex/Documents/My Public Repos/pool-table-game/scripts/presentation/ball_visual.gd` — `e4915e3b0651106ead7319d42e056fed6845c0b7c2fc300536307730c6756a90`
- `/Users/codex/Documents/My Public Repos/pool-table-game/assets/shaders/ball_surface.gdshader` — `d005527f9c72f1a361c0b475a3d93a5f24c0a94ac6ea3e3676a647c68a539238`
- `/Users/codex/Documents/My Public Repos/pool-table-game/assets/shaders/cloth_surface.gdshader` — `46357b268dd1f91ddfe388e78602d083f07e678d526bfca4f7d3804bc73a24cc`
- `/Users/codex/Documents/My Public Repos/pool-table-game/assets/shaders/room_reflections.gdshader` — `f84d09a560b56f5d0624da694e9ec49b8e837da1da5da99e126393102dbc25fa`
- `/var/folders/tx/vjn4y65n68l2rkvyqlcnf8fw0000gp/T/longrail-task-i-80xmvlh8/tests/task_i_capture.gd` — `f720c346951a4c1c2e4ebb4e1d58283a51b37ffb181d06ef850d5faf240deb85`
- `/tmp/task-i-lounge-1100.png` — `2254cf89cca4431d91cc2e095599f3250659ec01b28b0a3a700dcb7ee861a91b`
- `/tmp/task-i-overhead-1600.png` — `ee7d01f7124fa52f06e6cecbf4c602087ac67305be41f00d43b03f56d87142f2`
- `/tmp/task-i-slice-1100-lounge.png` — `463f7cfba20b6cb988206f2ee277253ed6fa3b1f7d706b5280565be878fbdbe2`
- `/tmp/task-i-slice-1100-overhead.png` — `ccc5be63f126d83ef3b5260a167dfebe8556aa124d0f749e628deede0ae9b373`
- `/tmp/task-i-slice-1600-lounge.png` — `3166759d3e8e40f9a50ac9eb29b76881c0aaa135187f11150a73050fa34bd7e3`
- `/tmp/task-i-slice-1600-overhead.png` — `638023a6c07ae44719c490b721c9565866ce0e0207e60411e04dd04aebea0750`
- `/tmp/task-i-slice-1920-overhead.png` — `ded48b37446ef223f157dd54f0976b677b860e6ce63e131660881c1fdad9584b`
