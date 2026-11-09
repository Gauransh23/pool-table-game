# I1 short-span fold correction

Baseline `ccf61f2`. Read AGENTS, QUALITY_TARGETS, GEO/VIS target sections, TEST_PROTOCOLS, task-i1-fix-review and task-i1-report before editing. Scope: retained P2 green spans4a/4b/5a/5b; source/test/evidence only. No subagents, branches, worktrees, pushes or physical/profile changes.

## Correction and oracle

`_cushion_mesh` now accepts a fractional interval of a complete mouth-to-back jaw loft. `_build_rails` computes authored fall fraction once and uses [0,fall] for green and [fall,1] for brown. Every cut vertex interpolates the same full-jaw endpoint sections. Mouth/back cross-sections, physical nose and fall transition remain fixed. Deck, liner, support, collision, camera, coefficients, materials/culling and guide/placement code are untouched.

The existing test now inspects all twelve actual built green/brown pairs, including all four 6.184mm production counterexamples. It checks every face for outwardness and nonzero area; paired directed edges for a closed oriented manifold; all endpoints and shared cut vertices against full-loft interpolation within0.2µm; every side triangle's vertices and centroid against the original full-jaw triangle surface within0.2µm; and every vertex behind the physical jaw nose half-plane within0.2µm. Together these convex loft/topology/surface/half-plane checks establish no newly introduced fold or cavity intrusion in the authored production pairs. Existing full/reversed/recessed checks and archived counterexamples remain intact. This is bounded authored-geometry coverage, not arbitrary nonconvex mesh certification.

The strict tests read `surface_get_arrays(0)[Mesh.ARRAY_VERTEX]`, the actual rendering positions. Godot's `get_faces()` triangle-cache positions showed approximately60µm quantization during harness development, which is unsuitable for exact shared-section checks. No production compression change was retained. Earlier nose sampling still uses its preexisting50µm bound; no requirement was relaxed.

## Exact checks and results

Engine `/Users/codex/Applications/Godot-4.7.2.app/Contents/MacOS/Godot`, 4.7.2 official `ed1daf0bf`, Apple M4; graphical captures Forward+/Metal4. Commands run from repo root. Evidence directory `docs/quality-roadmap/reports/experience-improvement/i1/fold-fix/`.

```
/Users/codex/Applications/Godot-4.7.2.app/Contents/MacOS/Godot --headless --path . --script tests/i1_geometry.gd
/Users/codex/Applications/Godot-4.7.2.app/Contents/MacOS/Godot --headless --path . --script tests/visual_geometry.gd
/Users/codex/Applications/Godot-4.7.2.app/Contents/MacOS/Godot --headless --path . --script tests/table_geometry.gd
/Users/codex/Applications/Godot-4.7.2.app/Contents/MacOS/Godot --headless --path . --script tests/pocket_support.gd
git diff --check
```

Final test against baseline source (`git show ccf61f2:scripts/presentation/table_presentation.gd`, temporarily loaded and restored in a Python try/finally before any captures): **4530 checks,216 failures,exit1**, raw `red.log`. Same final test against corrected source: **4530 checks,0 failures,exit0**, raw `i1_geometry.log`. Visual157/0; support49/0; table_geometry all assertions pass; all exit0. `git diff --check` exit0. Initial harness parse error is preserved in `invalid-parse.log` and excluded from valid evidence. Baseline216 failures include the40 production short-span outwardness failures plus split-section/full-surface violations; the historical standalone probes are unchanged archives and still describe the superseded independent-subspan construction.

## Captures and inspection

Eight fresh originals and pose/engine/source JSON sidecars are committed under `fold-fix/captures/`: `pocket{4,5}-{1100,1600}-{overhead,lounge}.png`. `capture-commands.json` contains all eight exact argument arrays and exit0 results; corresponding logs are beside it. Example:

```
/Users/codex/Applications/Godot-4.7.2.app/Contents/MacOS/Godot --path . --script tests/i1_capture.gd -- --pocket --pocket=4 --small --lounge --output=/Users/codex/Documents/My\ Public\ Repos/pool-table-game/docs/quality-roadmap/reports/experience-improvement/i1/fold-fix/captures/pocket4-1100-lounge.png
```

All eight source and fixture SHA256 sidecar identities match final source; capture logs contain no script/engine errors. `manifest.json` hashes all evidence, relevant source/test/geometry files, and matching prior winding-fix originals. Inspected all eight fresh images and all eight matching prior originals from `/Users/codex/Documents/My Public Repos/pool-table-game-i1-evidence/winding-fix/`. Pocket openings, nose silhouettes and selected A/v5 palette remain coherent in both views/sizes; the small side-pocket lips are more continuous. Dark recesses and tiny facets remain limited still-image evidence; world-space topology is the fold oracle. No redesigned cavity or hidden disk.

## Requirement ledger and limits

- GEO-006: PASS for this retained production short-span fold fixture and all twelve authored split pairs; exact shared sections, outward normals and closed topology checked. No claim to every catalog geometry/LOD obligation.
- GEO-002/003/008: bounded preservation PASS through unchanged physical source, exact full-loft endpoints/nose, cavity-side exclusion and relevant shared geometry/support regressions. Whole-domain acceptance remains open.
- VIS-006: matched static inspection PASS for these eight views; temporal entry/rejection, all-LOD diagnostics and human evaluation NOT_RUN.
- Human recognition/material panels, native OS/DPI transforms, temporal artifacts, packaged artifact and frame-time budgets remain NOT_RUN. No unrelated atlas or broad simulation reruns.

Lead-owned ORCHESTRATION_STATUS.md, WINDING_REVIEW_AND_REMAINING_FOLDS.md and five measurement/power UID sidecars were preserved and excluded from the scoped commit. Source/test/evidence/report are the only owned changes.
