# Physics requirements review

**Status: CONDITIONAL.** Reviewed `QUALITY_REQUIREMENTS.json` against the forwarded high-target brief. The physics bar is appropriately demanding and most requirements point in the right direction. A few acceptance statements still admit incompatible interpretations or cannot be established with the measurement precisions listed elsewhere. Define these before `TEST_PROTOCOLS.md` is frozen. Keep the numeric ambition; tighten its oracle and scope.

The requirements and targets remain **UNVERIFIED**. `QUALITY_TARGETS.md` and `TEST_PROTOCOLS.md` were not present at review time, so this review covers the JSON catalog only.

## Corrections to carry into the protocols

1. **Define energy budgets and normalization.** `CUE-001`, `BAL-001`, and `BAL-002` use “1e-6 relative or 1e-9 J absolute” without saying which scale or how to combine them. Specify a single acceptance formula, for example `error <= max(abs_tolerance, rel_tolerance * reference_energy)`, and name the reference energy for each fixture. For an elastic pair, compare total pre/post kinetic energy including translation and rotation. For dissipative contacts, test nonincrease after accounting for external work. For a cue strike, include the cue’s modeled work/recoil or define the strike model’s energy input; comparing ball output directly with an unspecified “supplied cue energy” is not executable. For the system ledger, define gravitational potential datum, cue work, projection work, and the energy disposition of captured/off-table balls.

2. **Separate orientation phase from orientation modulo 360°.** `CLT-003`’s 0.25° error over 1 m requires an unwrapped marked-ball phase (or a signed accumulated rotation oracle). A quaternion comparison can alias complete turns and report a small angular difference after a visibly wrong amount of rolling. State the path length, initial orientation, roll axis, handedness, and phase-unwrapping method.

3. **Define near-zero direction and relative-error rules.** Direction is undefined at zero speed; percent speed error is unstable near zero; a `2 µm / normal_speed` contact-time allowance diverges as normal speed tends to zero. `BAL-003` appropriately sends grazing cases to a closest-approach/boundary error, but specify the minimum normal speed for its timing formula and the transition rule. For `CAL-004`/`RAI-002`, state a minimum speed below which vector velocity error and absolute angular error replace relative speed/direction percentiles. Keep zero-speed/zero-spin tests as explicit no-motion invariants.

4. **Keep world-space and pixel acceptance separate.** `POC-008` requires the visible descent to agree with physics within 0.25 mm and also calls for frame-by-frame screenshots. At a typical gameplay scale, 0.25 mm can be a fraction of a pixel, so image tracking cannot establish that bound without a documented projection, scale, and uncertainty budget. Test the ball node/mesh transform against the physics state in world space to 0.25 mm; use image-space tests for visible pop-through, occlusion order, continuity, and pixel error. Apply the same distinction when interpreting `GEO-002` and `AIM-003`.

5. **Make convergence horizons exact and report two kinds of convergence.** `NUM-001` correctly demands matched initial states and horizons. The protocol should choose a common physical sample time divisible by the fixed-step schedules or interpolate recorded states to that time; never compare runs after different numbers of ticks as if they shared a horizon. Report fixed-time trajectory/contact convergence separately from settled endpoint convergence. For event-driven contacts, retain event-time/contact-normal error alongside post-event position and direction. A plateau should mean at least two consecutive refinements satisfy the bound, not only that the finest pair looks close. Discontinuous pot/reject outcomes need boundary/outcome sensitivity checks rather than smooth endpoint norms.

6. **Scope the “arbitrarily thin” contact demand to resolvable cases.** `BAL-004` asks for correct contact on arbitrarily thin legal hits while `NUM-003` allows a 2 µm contact tolerance and the engine uses finite-precision coordinates. No finite-precision solver can distinguish arbitrarily small positive clearance from contact. Define the declared contact band: test clearances and overlaps at both sides of a sourced/derived tolerance, including explicit 2, 10, and 50 µm cases; report the boundary uncertainty. Require correct behavior outside that band and classify inside it as tolerance-limited rather than claiming arbitrary resolution.

7. **Define what constitutes a unique multi-contact oracle.** `BAL-006`’s converged impulses for frozen/3–4-ball chains can be underdetermined or dependent on the chosen rigid-contact formulation. Preserve the high bar for bounded penetration, no artificial energy, stable event identities, and storage-order sensitivity. For impulse-vector comparison, state the complementarity/regularization model and when a solution is non-unique; otherwise compare invariant outcomes and a declared solver solution class instead of an unspecified unique vector.

8. **Specify penetration sampling point and contact identities.** `BAL-007` gives isolated, transient-cluster, and settled overlap maxima but should define whether each is measured before or after positional correction and whether the permitted contact slop is included. Record pre-correction penetration and post-correction residual separately at every substep. `BAL-008` should define the tolerance window for events considered simultaneous, how a continuous contact becomes a new impact after separation, and how iterative solver passes are excluded from physical event counts.

9. **Separate the geometry boundary from the measured pocket transition.** `GEO-008`’s 0.01 mm support-query agreement and `POC-005`’s 2 mm/0.25° physical transition-location bound measure different things. Say so explicitly: geometry/query consistency is verified against the same exported polygons/mesh; the measured pot/reject transition is compared with independent physical trials and carries measurement and shot-to-shot uncertainty. Define the transition band from that uncertainty and report a confusion matrix outside it. Do not use the looser physical bound to excuse an inaccurate shared-geometry query.

10. **Preserve the domain limit on the cushion oracle.** `RAI-005` is directionally correct to restrict Mathavan et al. (2010) to its rigid-cushion assumptions. The paper reports that the rigid-cushion assumption is valid only below a limiting **normal** velocity of about 2.5 m/s; its fitted restitution/friction values are not a universal pool-table preset.[Mathavan, Jackson & Parkin, 2010](https://drdavepoolinfo.com/physics_articles/Mathavan_IMechE_2010.pdf) The protocol must record normal and tangential incident velocity, spin, cushion/nose profile, and material. Do not use total speed alone to decide whether a case is in-domain, and do not extrapolate the model above its reported normal-speed limit without separate evidence.

11. **Use the right instrument for each time tolerance.** `CAL-002` allows 1 ms timing uncertainty; `BAL-003` targets analytic contact timing at roughly 10 µs plus a speed-scaled spatial term, and `CUE-005` targets contact/visible-motion timing within a rendered frame. These are not contradictory if scoped separately: analytic collision timing can be checked against a closed-form oracle; 1 ms physical video timing cannot validate a 10 µs claim; a 60 Hz visual frame bound is about 16.7 ms and should be measured as a render/display outcome. Label the oracle and uncertainty for every timing result.

## Mirror rule review

`NUM-006` states the correct general law: angular velocity is an axial vector, so under an orthogonal reflection matrix `M`, transform it as `det(M) * M * ω`. Keep this rule. For 3D coordinates `(x,y,z)` where the table plane is `(x,z)`:

- Mirror table-length coordinate `x`: polar positions/velocities use `diag(-1,1,1)`; spin uses `diag(1,-1,-1)`.
- Mirror table-width coordinate `z`: polar positions/velocities use `diag(1,1,-1)`; spin uses `diag(-1,-1,1)`.
- Rotate 180° about vertical `y`: determinant is positive; spin transforms as `diag(-1,1,-1)`.

The tests must transform contact offsets, rail/jaw normals, event positions, and pocket IDs consistently with the scene symmetry. Do not mirror spin like position/velocity. Compare semantic event sequences, not raw ID ordering.

## High-bar requirements worth preserving

- Independent analytic or sourced oracles, held-out measured families, retained failures, and explicit dirty-source identity are essential; differential agreement by itself is not validation.
- `NUM-010`’s 1,000-development/10,000-release seeded breaks is a substantial but executable batch gate. Keep its actual-rest requirement and report the sample count; do not substitute a small scout batch.
- `PWR-001` correctly separates UI displacement, authored power, cue speed, impulse, and ball speed. Keep that chain and prohibit claims that a percentage is newtons.
- `POC-003`/`POC-004` correctly prohibit early scoring after mouth entry. Define `supported` as actual sphere/surface contact in 3D, not merely a center-point polygon flag, so “projects under supported bed” catches slate tunneling without confusing a below-slate body with a physically supported ball.
- `CAL-005`/`CAL-008` appropriately require held-out shot families and independent reproduction. A competitor highlight or edited GIF cannot set friction, restitution, speed, spin, or pocket-boundary coefficients.

## Required disposition

**CONDITIONAL until these definitions are reflected in `TEST_PROTOCOLS.md`.** No target values need to be lowered to resolve the issues above. Most are fixes to units, oracle identity, edge-case handling, or what can honestly be measured. The external research for this review was limited to the primary cushion-impact paper cited above; the target/protocol drafts were not yet available.
