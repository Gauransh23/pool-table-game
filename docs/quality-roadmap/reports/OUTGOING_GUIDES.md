# Two-ball outgoing guides — bounded implementation

2026-11-08. Baseline `23cb30fd26085b678ad9dd9d73058b7c065a4dd4`, original checkout `/Users/gt/Documents/My Public repos/Pool table game`, `main`. Owner resumed after the explicit pause; no branch/worktree was created. This report covers only outgoing guides, not the separate presentation rebuild. No engine/coefficient, strike/power mapping, save format or undo changes.

## Design and physical meaning

`OutgoingGuide` clones every `BallState`, applies a separate `CueStrikeModel` with the current shot direction, `StrokePower.cue_speed`, tip offset and active `PhysicsConfig`, then replays **the active PhysicsStepper** with its authored fixed step and the same table. The experimental impact stepper is not used. Cloth friction, rotational evolution, throw, restitution, squirt and the active model's small vertical responses come from that replay, not a duplicated ideal collision formula. Live ball canonical states are checked unchanged.

Incoming samples end at the first-contact tick endpoint. Outgoing paths begin at each ball's distinct center at that endpoint. Cue is solid ivory, object is dashed pale cyan; compact arrowheads indicate motion. A hollow ball-radius contact ring replaces the filled aiming ghost; the filled placement preview remains separate. Fine screen-space ribbons use a 1.5 logical-pixel inner line and a 2-pixel total dark edge, reprojected on camera movement and resize without restarting prediction. Initial geometric launch/contact guides receive the same redraw handling.

The readout exposes estimated **planar speeds in m/s at the endpoint of the first-contact fixed tick**. These are not exact instantaneous impact speeds, momentum percentages or energy shares. Momentum is a vector; no scalar percentages or fake sum-to-100 division are displayed. Ideal stationary equal-mass frictionless stun gives object speed `v*cos(cut)` and cue speed `v*sin(cut)`, with translational-energy ratios `cos²`/`sin²`; actual coefficients, spin, friction and cloth evolution differ. The right-angle rule is not imposed on follow/draw.

Reference grounding supplied and inspected by the lead: [Dr. Dave 90-degree rule](https://drdavepoolinfo.com/faq/stun/90-degree-rule/), [TP3.2](https://drdavepoolinfo.com/technical_proofs/TP_3-2.pdf), [TP A.5](https://drdavepoolinfo.com/technical_proofs/new/TP_A-5.pdf). Visual inspiration: the official Miniclip table/control images and [combined-spin gameplay GIF](https://support.miniclip.com/hc/article_attachments/41975201180817) inspected by the lead: fine light guides with dark edge and a hollow contact ring. No commercial or exact visual/physical parity is claimed; no third-party image or code is included.

## Bounds, caching and uncertainty

- Search before first contact: at most 2.5 simulated seconds. After contact: at most 0.8 seconds and 0.45 m per outgoing path, also bounded by 1920 total ticks. The final length-cap endpoint interpolates along its actual last replay segment.
- Each ball's path ends before the tick containing its next ball/cushion/pocket/off-table event, or when cloth support is lost. No reflected or second-collision leg is drawn.
- Multiple/mixed first-contact events and near-frozen neighbours within `diameter + 3 mm` omit outgoing prediction. A rack does not receive a confident isolated-ball forecast. Moving layouts, airborne/falling initial layouts, invalid/zero strokes and rail/pocket-before-ball cases are qualified/omitted. No-hit/timeout cases retain only the visibly qualified geometric guide.
- Ordinary active-model sub-mm hops on cut shots are projected to the guide plane. Paths stop for height above `R + 2 mm` or vertical speed above 0.2 m/s. These conservative preview limits do not change physical behavior or claim intentional jump/masse coverage.
- Work is incremental: at most 32 ticks per frame, checking a **soft** 2500 µs budget after each tick. A single tick can overrun that budget; it is not a preemptive time guarantee. Results remain cached until aim, power, spin, canonical ball layout, public authored table/config parameters or readiness/guide state changes. Changed setup clears old outgoing paths immediately; guide-off hides paths/readout. Camera redraw reuses cached world paths.
- Runtime estimates match the current engine; they are not calibrated real-table predictions. Tick sampling does not establish the contract's full 0.25 mm / 0.02° contact accuracy across its named corpus. Horizon endpoints/arrowheads are previews, not promised landing positions.

## Requirement ledger

| ID | Current evidence | Result within this checkpoint / remaining acceptance |
|---|---|---|
| AIM-005 | Independent frictionless 0/30/45/60° speed references; active-replay sample parity and declared scope | PASS for bounded tested consistency; full final geometric/angular corpus INCONCLUSIVE / not established |
| AIM-006 | Cluster/mixed/unsupported omission; hollow marker; separate placement ghost; guide-off/stale-cache checks | PASS for tested categorical behavior; blinded >=95% identity study NOT_RUN |
| VIS-007 | Projected 1.5-pixel inner ribbon checks after both camera transitions and resize; 2-pixel dark outer width by construction; native small-window captures | PASS for tested inner-width/reprojection; DPI sweep, difficult-ball deck and human legibility NOT_RUN |
| AIM-001/008/009 | Existing actual Viewport-routing aim/practice/stroke suites | PASS for those existing tested gestures; native input latency/perceptual trials NOT_RUN |
| PER-002/003 | Predictor CPU slices recorded, finite tick bounds | No exported frame-pacing claim; final release protocols NOT_RUN |

## Commands and retained evidence

Run from the original checkout with Godot `4.7.2.stable.official.ed1daf0bf` (native captures: Apple M4, Metal). Raw stdout/stderr and exit codes are retained in [outgoing-guides-evidence](outgoing-guides-evidence/). For every named source suite:

```sh
bash tools/godot.sh --headless --path . --script tests/SUITE.gd
```

Suites: `outgoing_guides`, `run`, `aim_controls`, `practice_input_flow`, `practice_flow`, `stroke_contact`, `spin_precision`, `save_recovery`, `audio_contacts`.

Final source results:

- `outgoing_guides`: OUTGOING GUIDES: 742 checks, 0 failures; max slice 3536 us, max total 47085 us; exit 0.
- `run`: PASS: 950 simulation and rules assertions; exit 0.
- `aim_controls`: AIM CONTROLS: 0 failure(s); exit 0.
- `practice_input_flow`: PRACTICE INPUT FLOW: 200 checks, 0 failure(s); exit 0.
- `practice_flow`: PRACTICE FLOW: 42 checks, 0 failures; exit 0.
- `stroke_contact`: STROKE CONTACT: 24 checks, 0 failures; exit 0.
- `spin_precision`: SPIN PRECISION: 5 checks, 0 failures; exit 0.
- `save_recovery`: SAVE RECOVERY: 39 checks, 0 failures; exit 0.
- `audio_contacts`: AUDIO CONTACTS: 0 failure(s); tests event delivery, not acoustic fidelity; exit 0.

See `manifest.json` for source/physics/evidence SHA-256 identity. Predictor CPU measurements exclude final guide mesh generation and native display latency.

Focused checks cover head-on/cut/signed follow/draw/side spin, independent ideal sin/cos speed references (0.2 mm/s tolerance), vector momentum (1 micro N·s tolerance), exact retained active-replay samples (0.1 µm tolerance, final capped endpoint on the actual last segment), no-hit/zero power, rail-before-hit, cluster rejection, next-rail truncation, clone nonmutation, finite tick/slice caps, cached completion, layout/config invalidation, guide-off, placement ghost, camera transitions and resize. Assertion totals vary because a check runs per timing-budgeted slice. This is not additional physical calibration.

Native capture commands:

```sh
bash tools/godot.sh --path . --script tests/capture_outgoing_guides.gd -- --small --output=/tmp/pool-outgoing-small.png
bash tools/godot.sh --path . --script tests/capture_outgoing_guides.gd -- --small --lounge --output=/tmp/pool-outgoing-small-lounge.png
```

The fixture assigns a fresh isolated session path **before** scene attachment, waits for camera settling and completed prediction, and fails on prediction/PNG-write errors. `--small` selects 1100×700; omit it for the default size. Both small-window camera captures were inspected: hollow ring, distinct branches/arrows, scope/speeds and all sidebar controls were visible without overflow. Screenshots do not establish native timing, full difficult-context legibility or listening quality.

## Preserved failures and rulings

1. First 0.45 m cap implementation yielded two parity failures because the former all-samples-equal oracle rejected the intentional final interpolated point. Retained rule: interior samples remain exact; only the final capped endpoint may lie on the actual last tick segment. No engine tolerance/target changed.
2. Blanket rejection of every AIRBORNE post-contact state erased ordinary cut cue paths (two failures: cut sampled path/parity duration). Observed active-model hops: about 0.04–0.12 mm height and 0.017–0.056 m/s vertical speed. Ruling: retain ordinary small responses, omit substantial flight using explicit preview bounds above; do not modify the active engine.
3. Capture fixture initially failed because SceneTree lacks `get_viewport()` and an untyped Array could not assign typed `game.balls`. Corrected to root texture access and `Array[BallState]`. Session-path isolation was then moved before scene attachment. Failed captures were not treated as successful evidence.
4. Initial camera-width tests using `ImmediateMesh.get_faces()` reported widths 1.917 and 15.945 pixels after redraw. That API returned a stale cached triangulation. Current tests inspect the active `surface_get_arrays(0)[Mesh.ARRAY_VERTEX]` buffer instead; observed inner widths are approximately 1.500 pixels in both views and after resize. The actual camera invalidation defect was independently fixed by rendering-only reprojection.
5. `aim_controls` assertions pass/exit 0 but Godot reports 2 ObjectDB instances and 1 resource still in use at shutdown in the recorded run. This cleanup warning is retained separately from assertion results; no warning is silently counted as an acceptance pass.

## Residual limits / handoff

Full contract gates remain open: dense sweep contact-error quantification, calibrated physical data, difficult/occluded identity trials, full DPI/zoom/native interaction, release frame pacing and independent review. CPU soft-budget overshoot and conservative cluster omission are explicit tradeoffs. The 3 mm neighbour guard can omit otherwise usable isolated predictions; the bounded guide intentionally stops early. No solver promotion, coefficient adjustment, art rebuild, packaging or push is part of this implementation checkpoint. Primary owns independent review and release actions.
