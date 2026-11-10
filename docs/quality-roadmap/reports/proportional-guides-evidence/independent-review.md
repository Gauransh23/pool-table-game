# Proportional guides independent final review

2026-11-09. Reviewed `c2a0487..689b2d6`, plan `docs/quality-roadmap/plans/PROPORTIONAL_GUIDES.md`, implementation report, focused test source/raw evidence, and current production source on original checkout `main` at `689b2d6fbfd2517aa736793a119abe45ea0f921c`. Product source was read-only. Packaging/version/docs work outside this commit and the separate audio task were excluded.

## Spec verdict: PASS for the bounded source/UI checkpoint

No important spec deviation found. The replay-only observer captures incoming velocity before the pair call and outgoing velocities immediately after exactly one `super._resolve_ball_pair` call. The base implementation registers the event before tangential impulse, so the new snapshot correctly includes that impulse while retaining registered centers and historical tick-end fields separately. No physics algorithm or coefficient changed.

The renderer uses speed magnitudes with one finite reference denominator and projects each direction through the current orthographic camera. Its resulting centerline paths are consumed directly by the mesh renderer and focused tests. One common obstruction factor scales both paths, using shared rail/jaw/fall-edge geometry and unrelated ball clearance; the separating pair is excluded. Zero branches are omitted and near-zero branches have no fabricated minimum length. Arrow glyphs do not define centerline length.

Menu -> Guide length provides the specified 0.25–3.00x range, 1.50x default, 0.05x step, keyboard traversal and visible focus. Dedicated ConfigFile persistence has an overrideable test path and rejects nonfinite/malformed values. Input gating prevents modal adjustments from rotating aim or shooting. Length/camera/resize redraws reuse cached vectors; aim/guide/placement/stroke state changes retain the existing invalidation route. Display text accurately distinguishes momentum-at-impact diagrams from future travel.

## Code verdict: PASS

No actionable important defect found in the reviewed patch. The implementation is narrow, reuses the active solver and shared geometry, and keeps cosmetic settings separate from shot state. The unchanged physics source and the five reviewed implementation/test file hashes match the evidence manifest.

## Evidence assessed and limits

- Inspected retained focused output: 106 checks, 0 failures; independent ideal sin/cos and vector identities, signed-spin post-pair parity, explicit pre-tangent/tick-end discriminators, both-camera projected centerline ratios, zero/near-zero, magnification, shared rail/pocket/ball clipping, resize/cache and actual Viewport keyboard settings route.
- Read the retained old equal-cap failure: old lengths 0.449999989/0.449999994 m versus speed ratio 0.577350214. It remains preserved as a failure of the historical display.
- Inspected actual 1100x700 `30deg-default.png`, `lounge.png` and `settings.png`: unequal cue/target extents are clear, the lounge shared-limit readout is visible, and the settings slider/focus/card are readable.
- Reviewed the documented affected regression results (outgoing 878/0; input 200/0; stroke 24/0; practice 42/0; recovery 39/0; aim zero failures). Unchanged passing suites were not rerun because source inspection found no concrete new suspicion. Existing aim teardown warning remains a documented limitation.

This closes only the named source/UI slices of AIM-001/005/006/008/009 and captured presentation portions of VIS-007/008/009. It does not certify full quality-contract requirements, calibrated physics, human recognition/readability thresholds, competitor numerical parity, native latency/performance, audio quality, or the separately required exported-app/package acceptance. Lead-owned packaging and final remote/clean-main verification remain separate release work.
