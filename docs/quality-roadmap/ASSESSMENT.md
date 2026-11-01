# Quality assessment — 2026-10-30

## Verdict and limits

Long Rail is a technically promising practice prototype with unresolved foundational quality defects. It is not ready to be called a polished pool game. Missing modes are secondary: ordinary aiming, delicate strokes, pocket entry, and readable presentation must become trustworthy first.

This assessment inspected source at 5788954d8b6c9111177888a04b529400c86ac926, including the existing October 28 review and executable quality contract. No new runtime test, rendered capture, listening session, commercial comparison, or physical measurement was completed. No Godot installation was found in the standard application directories inspected. Earlier numbers below are historical measurements from docs/quality/BASELINE.md, not rerun results. An overall numeric quality score would imply precision we do not have.

## Evidence and severity

| Finding | Evidence | Consequence | Priority |
|---|---|---|---|
| Premature pocket capture | table_spec.gd:pocket_at subtracts radius from boundary; physics_stepper.gd:_classify_exits immediately selects FALLING and injects downward velocity | Unsupported pocket acceptance; shelf/hanging-ball behavior cannot be convincing | P0 |
| Physical and visible mouths differ | table_presentation.gd:_build_pockets draws independent disks; TableSpec creates converging jaw segments | Player cannot trust the visible pocket to predict a shot | P0 |
| Aim is overwritten by pointer travel | game_controller.gd:_unhandled_input handles unpressed motion as aiming | Fine aim is lost while selecting power; feels inaccurate even with correct physics | P0 |
| Weak low-power resolution | game_controller.gd maps stroke to .25+power*7.75; historical minimum shot traveled .3990m | Delicate positional play unavailable | P0 |
| Incomplete collision-time solution | _resolve_ball_pair first requires overlap after integration, then uses predicted normal | Clean departure-angle checks do not prove time-of-impact, cluster or final-position accuracy | P1 |
| Uncalibrated coefficients | physics_config.gd labels starting coefficients as calibration inputs | Plausible equations do not establish believable speed, cushions or spin | P1 |
| Prototype visual construction | BallVisual uses 3×5 digit patterns; pockets are disks; procedural materials and simplified lighting | Likely weak identity/readability and depth; magnitude needs fresh captures | P1 |
| Render samples simulation directly | BallVisual.sync_from uses current state; controller advances then syncs | No explicit interpolation in inspected path; visible judder is a hypothesis requiring measurement, not a proven defect | P1 investigation |
| Unbounded catch-up loop | PhysicsStepper.advance consumes accumulated elapsed time without a work budget | Frame stalls can trigger expensive catch-up; profile before choosing a policy | P1 investigation |
| Save lifecycle defect | Existing quality contract injects velocity into an IN_PLAY save | Historical result is frozen moving state; must reproduce and repair | P1 |
| Native validation not gameplay validation | README identifies C++ as isolated experiment | Thousands of native checks cannot certify playable GDScript engine | Process blocker |

## What is already worth keeping

There is a fixed-step simulation, adaptive subdivisions, translational and angular state, sliding/rolling/spinning friction, impulse response, cue strike modeling, undo, recovery, and separate rules logic. These are useful foundations. A blanket rewrite before finding the earliest numerical divergence would throw away working evidence and expand risk.

## Physics diagnosis

The principal demonstrated problem is model coverage and calibration, not simply low tick rate. The runtime already uses 480 Hz. Increasing it cannot add a missing shelf, create coherent pocket geometry, or fix a power curve. Likewise changing rolling resistance to make the minimum stroke shorter would damage every other shot.

For pockets, model support, jaw contact, shelf traversal and irreversible capture as distinct conditions. A ball must not disappear merely because its center crossed an arbitrary rectangle. Falling currently skips ordinary collision resolution, so the capture boundary decides much of the apparent physics. Research the boundary before tuning pocket generosity.

For collisions, distinguish a correct impact normal from correct event timing. The current predicted normal is applied after a full substep; the engine does not advance exactly to contact and integrate the remaining interval. Measure convergence, grazing contacts and cluster sensitivity before deciding whether a local correction, continuous collision approach, or native engine migration is justified. The native path must earn migration through shared fixtures, state/event parity and packaging evidence.

## Visual diagnosis

Source inspection supports a prototype asset diagnosis, but cannot establish how severe every issue looks on screen. Earlier committed notes report flat cloth, coarse pockets, weak material separation and small rotating numbers. Those observations require current captures before being called current visual measurements.

Prioritize table silhouette and pocket depth, then ball separation and identity at actual gameplay size, then lighting/material response, then decorative detail. A better shader cannot repair incorrect jaw geometry. Keep surface detail subtle enough that it does not shimmer while balls move. Separate physical ball rotation from optional identification aids so readability does not require falsifying rotation.

## Recommended next milestone

One excellent practice table: deliberate aiming, delicate and powerful strokes, believable contacts and pocket entry, coherent materials, readable balls, synchronized impact audio, smooth presentation, reliable undo/recovery. Defer new modes until this loop passes physical, perceptual and usability gates. This is a quality gate, not a permanent rejection of match play.

## Existing evidence to preserve

Read docs/quality/BASELINE.md and docs/quality/SOL_HANDOFF.md alongside this report. Their measurements and proposed contracts remain historical inputs. tests/quality_contract.gd intentionally fails the old baseline; do not delete it, loosen its checks, or blend its results into the regression count. Reconcile old handoff requirements explicitly before editing. This roadmap is the canonical sequencing document for the new phase; old documents remain provenance.
