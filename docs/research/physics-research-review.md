# Independent physics explanation review

Reviewed 2026-11-04 against the requested research-only explanation: spin/translation partition, cue strength, sliding/rolling, offsets, cut angles, distance, speed vocabulary and game dimensions. This is the fresh-context reviewer half of doubt-driven development. No production code was changed. Cross-model skipped: non-interactive reviewer context.

## Blocking corrections

None found in the central physics or numerical examples. The report adequately answers the stated questions. It separates impulse, momentum and energy; names the percentage denominators; distinguishes cue speed from ball speed; and keeps analytical examples separate from measured calibration.

## Small corrections and useful additions

1. **Clarify the startup camera observation (report section 11).** `_build_camera()` constructs a tilted camera, but `GameController._ready()` immediately calls `set_overhead(true)`, which animates to the overhead view in 0.45 s. Say this rather than implying the settled initial gameplay view remains tilted. The conditional screen-scale calculations are unaffected.
2. **State the full-hit assumptions locally (section 7).** The stop/draw/follow construction assumes an elastic equal-mass collision with negligible tangential ball-ball impulse and table impulse during impact. These assumptions are supplied elsewhere in the report, but repeating them beside the full-hit claim avoids reading "identical balls" as sufficient for exact velocity transfer.
3. **Optional high-value example: inverse stop-shot setup.** The existing explanation predicts what happens at a fixed low offset; a reader may also want the offset required for a chosen travel and actual launch speed. In the same constant-sliding model, `v_contact = sqrt(v0^2 - 2 μ_s g d)` while positive forward motion persists, and the needed initial spin is `Rω0 = -(5/2)(v0 - v_contact)` for zero spin at contact. Thus `h/R = -(1 - v_contact/v0)`. Name `d` as cue-center travel, and check the radial miscue limit. This directly exposes why slower or longer stop shots require progressively lower hits, until the chosen speed cannot supply the required spin within the assumed limit. This is derived guidance, not a measured aiming chart.
4. **Optional numerical completion of draw.** Section 7 deliberately gives direction rather than return distance. A follow-up worked example could use retained spin after the ideal full hit and `v_roll_after = 2Rω_contact/7`, then separately account for post-impact sliding and rolling distance. This would show why "draw" does not specify one fixed return distance. It is an enhancement, not a correctness blocker.

## Independent checks performed

- Read the report and the current cue-strike/controller/camera source without editing them.
- Reopened Alciatore A.12 and A.30: their impulse/offset and elastic cue-speed equations match the report's use. Reopened the typical-speed page: the report correctly converts the mph boundaries instead of silently copying the page's inconsistent rounded SI boundaries.
- Reopened Mathavan et al. 2009, B.2 and B.22: experimental snooker versus pool boundaries, stationary spin-down scope, rolling-resistance estimate and illustrative contact times are represented conservatively.
- Recomputed section 6's transition table. For `v0=2 m/s`, `μ_s=0.20`: center hit reaches roll at `0.291247998 s`, `0.499282282 m`; low hit `q0=-1` reaches zero spin at `0.407747197 s`, `0.652395515 m`, and natural roll at `0.582495995 s`, `0.832137136 m`.
- Independently derived and recomputed the natural-roll cut departure angles: `28.1622°, 33.6705°, 29.0546°, 20.6330°` for cuts `15°, 30°, 45°, 60°`. The report correctly identifies eventual post-slide directions rather than instantaneous impact directions.
- Recomputed the 0.10 m center-hit launch speed as `0.208586349 m/s` for `μ_s=0.19`, `a_r=0.012g`.
- Recomputed the spin-resistance unit audit: dimensionless `0.0127` gives `10.90 rad/s²`; a literal `0.0127 m` lever gives `381.4523 rad/s²`. The report's distinction is correct.

Limits: this review does not establish target-table coefficients, actual cue-impact calibration, game runtime correspondence or experimental accuracy for every linked paper. No new measured pool data was created.
