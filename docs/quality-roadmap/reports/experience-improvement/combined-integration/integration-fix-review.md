# Integration correction review

Verdict: PASS for the scoped marker/fixture merge correction. Original P2 is resolved; no new actionable visibility lifecycle regression established. This review does not expand prior physical, perceptual or packaged-release acceptance.

Reviewed `merge-marker-fix.diff` and actual working-tree `table_presentation.gd`, `i1_geometry.gd`, and `outgoing_guides.gd`. The worker report file was not yet present at review time; test results below were relayed by the lead. No production/test source was edited, no merge action taken, and no routine suites rerun. `git diff --check` passes.

- Fallback first-contact aim calls `_show_contact_marker` only after the existing hit-before-rail decision. It restores the cached torus, cyan aim color, visibility and unchanged fallback contact center/height.
- Completed outgoing prediction calls the same helper with `prediction.contact`, retaining registered solver-center semantics. The old ribbon ring is removed, so only the depth-tested hollow marker renders; incoming and outgoing momentum ribbons and proportional scaling remain intact.
- Fresh aim clears replay/geometry and hides the marker before any early return. No-target aim and disabled/moving/pending states therefore cannot retain a stale visible marker. Guide-off controller refresh clears replay before hiding, so later camera refresh cannot resurrect it. Placement still switches to the cached sphere with placement colors; subsequent hit aim restores torus and cyan material. Camera-only redraw preserves either the fallback marker or the completed registered marker without new resource allocation or solver replay.
- Fixture attaches `view` to `root` and calls production `_build_camera` before aim construction. Geometry ordering/mesh indexing stays intact and full table build is not repeated. Synchronous setup completes before a process frame, so there is no newly introduced null-camera process window.
- New assertions cover actual visibility, actual registered center, marker depth test, camera refresh, placement-to-aim restoration, guide-off and cached resource identity. They directly address the integration failure rather than simply weakening old assertions.

Lead-reported post-fix results: I1 geometry 4534/0 failures; outgoing guides 883/0; proportional guides 106/0; practice input 200/0; aim controls zero failures; rules 950 pass. These are accepted as execution evidence supplied by the lead, not independently rerun here. No counterexample justified additional routine reruns.

The original broader source review found no additional controller/HUD/audio/export/UID cross-branch incompatibility. That bounded verdict remains unchanged. Merge may proceed on the scoped integration review.
