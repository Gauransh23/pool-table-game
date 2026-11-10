# Merge contact marker correction

Pending merge: local HEAD `8973ad4`, incoming MERGE_HEAD `015292d`. No commit, push, abort, index update or unrelated staged-file edit performed.

Read `integration-review.md`, the local I1 brief, merged presentation/tests, QUALITY_TARGETS, relevant controls/presentation target branch and TEST_PROTOCOLS. Bounded requirement evidence: AIM-005 first-contact geometry and AIM-006 / VIS-007 hollow marker identity and guide lifecycle. These machine checks establish this integration behavior only; they do not complete the full physical corpus, perceptual recognition, contrast, native interaction or export requirements.

## Cause and change

The merged renderer kept the cached depth-tested torus resource but hid its node in every `set_aim`; its contact ring was instead included in no-depth-test ribbon triangles. Both fallback and completed prediction therefore bypassed the local hollow marker's accepted depth semantics.

`_show_contact_marker` reuses the cached torus, restores cyan aim color after placement, places it at ball-center height R+0.002 and shows it. Fallback calls it at the unchanged first-hit center; completed replay calls it at `prediction.contact` (registered cue center, not tick-end center or event surface point). The duplicate ribbon contact ring implementation and both calls are removed. All incoming/outgoing/proportional ribbon generation, obstruction scaling and controls stay unchanged. The separately cached placement sphere remains unchanged.

I1 isolated fixture now attaches its view to the SceneTree and constructs the real camera before aim projection, without duplicating table construction or changing mesh-index checks. Lifecycle checks cover cached marker restoration/color, no target, hidden guides, fallback camera refresh, registered prediction location, both camera redraws, guide-off camera refresh and placement while guides are hidden. Existing rail/jaw assertions remain intact.

## Red/green evidence

Before production edits, with corrected fixture initialization and new lifecycle assertions:

- I1: 4532 checks, 3 expected failures (hidden first-contact marker, wrong location, hidden restored placement marker).
- Outgoing: 883 checks, 4 expected failures (hidden cached prediction marker, wrong registered center, both camera redraw marker checks).

Raw baseline logs: `merge-marker-evidence/i1-red.log` and `outgoing-red.log`. Additional cache/color/refresh checks were then added before final verification.

Every final command used the pinned Godot 4.7.2 `ed1daf0bf` via:

```sh
bash tools/godot.sh --headless --path . --script tests/<name>.gd
```

| Name | Final result | Exit |
|---|---|---|
| i1_geometry | 4534 checks, 0 failures | 0 |
| outgoing_guides | 883 checks, 0 failures | 0 |
| proportional_guides | 106 checks, 0 failures | 0 |
| practice_input_flow | 200 checks, 0 failures | 0 |
| aim_controls | 0 failures | 0 |
| run | 950 simulation/rules assertions pass | 0 |

Raw final output is stored in `merge-marker-evidence/<name>.log`. Outgoing camera widths remain 1.4999961853 and 1.5 viewport units; resize width 1.5. Outgoing max slice 2711 us / max total 26246 us are observed run diagnostics, not a native performance acceptance claim. Registered hard-cut parity and old equal-cap counterexamples remain exercised.

`aim_controls` emits cleanup diagnostics despite passing assertions: 2 leaked ObjectDB instances and 1 resource still in use. The same diagnostics already appear in incoming `docs/quality-roadmap/reports/proportional-guides-evidence/aim_controls.txt` lines 56–59 and `outgoing-guides-evidence/aim_controls.txt` lines 31–34. Retained as a known verification limitation; no unrelated cleanup attempted. Other final runs emit no engine errors/warnings. Proportional log's `PRESERVED OLD EQUAL-CAP FAILURE` is an intentional retained counterexample, with 0 failed assertions.

`git diff --check` passes. Current production/test SHA-256:

- `scripts/presentation/table_presentation.gd`: `27d1cf34b92c1891310cc6b13d3293370cae8c03171dd995b80afe32efd38d29`
- `tests/i1_geometry.gd`: `31ece397851d5a9cc3d60046fa2eac5094375b87360fe6756892f481295b772f`
- `tests/outgoing_guides.gd`: `87facfce1943d96750b1f66582e241c742307a3575e68a8bd2c10bff421a767b`

## Limits and handoff

No native screenshot/perceptual review, audio retest or exported build was performed by this bounded fix. Material flag checks verify depth testing configuration; headless checks do not establish rendered occlusion quality. Lead owns broader merge validation and commit. The only tracked unstaged implementation diff is in the three files listed above; report/evidence live beside this packet.
