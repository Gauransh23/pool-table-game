# Outgoing guides — paused by owner

Historical checkpoint. The owner explicitly approved resuming on 2026-11-08. See `OUTGOING_GUIDES.md` for subsequent implementation and verification.

The owner requested a safe stop and explicit approval before continuing, 2026-11-06. Do not resume implementation, testing, packaging, commit or push until that approval arrives.

Working directory: `/Users/gt/Documents/My Public repos/Pool table game`, branch `main`, base `23cb30f`. All candidate changes are uncommitted. No branch/worktree was created for this task. Implementation agent `/root/collision_guides` was interrupted.

Candidate: cloned active-solver replay in `scripts/sim/outgoing_guide.gd`; incremental computation; hollow contact ring, ivory cue path and dashed cyan object path with arrowheads; first-contact tick planar-speed readout. Paths bounded to 0.8 s / 0.45 m after contact, ending before another interaction. Ambiguous clusters, mixed contacts and unsupported cases omit outgoing paths. Physics coefficients and active solver remain unchanged. Version/config/README edits prepare 0.3.2, but no new app or installer has been built.

Lead inspected native Metal capture `/tmp/pool-outgoing-guides.png`: both outgoing branches and hollow ring were visible. This temporary image may not persist. The implementing agent reported 709 focused checks passing; primary has not independently reviewed all tests or verified the final regression record. The capture fixture initially had a SceneTree `get_viewport()` parse error, subsequently corrected. Its session path was requested to move before scene attachment to avoid reading the user's save; verify that fix on resume.

Remaining after approval: inspect current diff and test evidence; independent spec/code review; address findings; repeat native capture at minimum window and both cameras; verify guide cancellation/guide-off/spin/cluster behaviour; finish implementation report and documentation; build and launch a versioned GUI candidate; commit/push only once final checks pass and authorization remains applicable.

References inspected: official Miniclip Basic Controls article and its Table.jpg / combined-spin GIF; Dr. Dave TP3.2 and TP A.5. Ideal equal-mass frictionless stun speeds are v*cos(cut angle) and v*sin(cut angle); energy shares are squared speed ratios. Actual preview uses the game's solver, not that idealization. Do not call scalar speed ratios momentum percentages or claim exact real-world prediction.
