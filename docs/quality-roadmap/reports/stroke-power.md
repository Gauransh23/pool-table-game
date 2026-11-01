# Stroke power mapping checkpoint

Date: 2026-10-31
Status: simulated control checkpoint; not a human precision or physical calibration result.

## Mapping

The slider now spans `0.000` to `1.000` in `0.005` increments. Zero maps to no cue motion and cannot submit a shot. For positive input, cue speed is:

```text
cue_speed(p) = 0.075 + 7.925 * clamp(p, 0, 1)^2 m/s
```

Non-finite and negative inputs map to zero. Values above one clamp to the existing maximum of 8 m/s. The quadratic curve concentrates selectable travel changes near the low end while preserving full-power cue speed. The 0.5% value is displayed as `0.5%` rather than rounded to an integer.

## Probe and results

The baseline probe was run before edits with Godot 4.7.2, the default `PhysicsConfig`, a centered cue ball, zero tip offset, and `CueStrikeModel` followed by `PhysicsStepper` until its default settled condition. On the prior 1% minimum and affine mapping (`.25 + .01 * 7.75`), measured center-ball travel was **0.399041623 m** over **2.575 s** (1,236 fixed ticks).

The new sweep used the same strike and physics path, with a one-ball table fixture whose half-size was set to 10,000 m so the shot could stop without reaching a cushion even at full power. It measured zero, the 20 half-percent values from 0.5% through 10%, and 5-point anchors through 100%: **39 distinct settings** total. All shots reached the solver's settled condition. The test records cue speed, initial ball speed, stopping distance, settle time, tick count, and settled state in [stroke-power.csv](stroke-power.csv).

| Input | Cue speed | Initial ball speed | Travel | Settle time |
|---:|---:|---:|---:|---:|
| 0.0% | 0 m/s | 0 m/s | 0 m | 0 s |
| 0.5% | 0.075198 m/s | 0.095702 m/s | **0.021070395 m** | 0.579167 s |
| 1.0% | 0.075792 m/s | 0.096458 m/s | 0.021396115 m | 0.583333 s |
| 5.0% | 0.094812 m/s | 0.120664 m/s | 0.033344980 m | 0.733333 s |
| 10.0% | 0.154250 m/s | 0.196308 m/s | 0.088515289 m | 1.204167 s |
| 50.0% | 2.056250 m/s | 2.616907 m/s | 15.740303993 m | 16.262500 s |
| 100.0% | 8.000000 m/s | 10.181278 m/s | 238.321853638 m | 63.331250 s |

The minimum nonzero slider step travels **2.107 cm**, inside the requested 2–10 cm window. Distance increased strictly at every sampled positive setting. Within the dense 0.5% to 10% low-end sequence, the smallest adjacent measured travel change was about **0.326 mm**; none of those steps was lost to the sleep threshold. The old minimum travelled 39.9 cm, so this mapping makes the first selectable touch about 19 times shorter in this fixture.

## Verification

`godot --headless --path . --script tests/stroke_power.gd` passed. The script checks zero, negative and non-finite mapping inputs, full-speed preservation, clamping above one, slider range and step, exact half-percent readouts, zero-power non-fire behavior, monotone simulated travel, settling, and dense low-end step response. It also writes the measurement CSV.

These are results from the current playable strike and solver models on an isolated, oversized empty fixture. They do not establish human selectability, measured cloth behavior, rail/pocket outcomes, or real-table precision. Full-power distance is reported to show the retained maximum-speed behavior; it is not a practical unimpeded travel claim for the normal table.
