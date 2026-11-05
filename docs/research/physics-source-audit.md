# Billiards physics: primary-source audit

Research checked 2026-11-04. Scope: cue impact, spin/energy, cloth motion, shot state, decay, and calibration ranges. This note does not change production physics or claim experimental validation of the game.

## Finding

Use a rigid-sphere impulse model followed by distinct sliding, rolling, and vertical-spin resistance models. Keep cue speed, ball speed, angular speed, and impact state separate. Published constants support starting calibration values; they do not establish a universal table. The equations below explicitly identify their idealizations and the numerical examples are calculations, not measurements.

## Source map

Page numbers are one-based PDF pages; journal page numbers are added where useful. The legacy `billiards.colostate.edu` material is now available on the author's `drdavepoolinfo.com` domain.

| ID | Primary source and inspected location | Evidence type / use |
|---|---|---|
| S1 | Alciatore, [TP A.12](https://drdavepoolinfo.com/technical_proofs/new/TP_A-12.pdf), pp. 1–2, Eqs. 1–3 | Impulse derivation; spin/offset; practical offset recommendation; author video observations |
| S2 | Alciatore, [TP A.30](https://drdavepoolinfo.com/technical_proofs/new/TP_A-30.pdf), pp. 1–6, Eqs. 1–9, 15–23 | Cue/ball energy and momentum; elastic versus inefficient impact |
| S3 | Alciatore, [TP A.4](https://drdavepoolinfo.com/technical_proofs/new/TP_A-4.pdf), pp. 2–3, Eqs. 1–13 | Vector cloth-slip model and transition |
| S4 | Alciatore, [TP A.18](https://drdavepoolinfo.com/technical_proofs/new/TP_A-18.pdf), pp. 1–2, Eqs. 1–6 | Stun/roll times and distances |
| S5 | Alciatore, [TP B.2](https://drdavepoolinfo.com/technical_proofs/new/TP_B-2.pdf), pp. 1–4, Eqs. 2–5, 17–18 | Author rolling and stationary spin-down tests; phenomenological resistance |
| S6 | Alciatore, [TP B.8](https://drdavepoolinfo.com/technical_proofs/new/TP_B-8.pdf), pp. 1–5 | Straight-draw model, explicitly ideal balls initially; later impact losses |
| S7 | Alciatore, [TP B.6](https://drdavepoolinfo.com/technical_proofs/new/TP_B-6.pdf), pp. 1–2 | Rolling stopping distance; illustrative older speed categories |
| S8 | Mathavan, Jackson & Parkin (2009), [original AJP paper](https://drdavepoolinfo.com/physics_articles/ajp_09_hsv_article.pdf), pp. 1–4 (journal 788–791), especially §III A/B | Direct snooker table tracking experiments; friction and speed ranges; DOI 10.1119/1.3157159 |
| S9 | Alciatore, [Typical Pool Ball Speeds](https://drdavepoolinfo.com/faq/speed/typical/), heading and speed list | Current author teaching estimates, not a statistical player sample |
| S10 | Alciatore, [Pool Ball Slide and Roll With Sidespin](https://drdavepoolinfo.com/faq/sidespin/slide-roll/), first three paragraphs | Explanation and linked demonstrations; rolling may coexist with sidespin |
| S11 | Cross (2023 online; journal volume 2025), [Impact of a cue with a billiard ball](https://journals.sagepub.com/doi/10.1177/17543371231184011), abstract | Original experiment on varying vertical impact point; abstract inspected, full data not accessed |
| S12 | Cross (2012), [Rolling motion of a ball spinning about a near-vertical axis](https://www.physics.usyd.edu.au/~cross/PUBLICATIONS/55.%20RollingBall.pdf), author manuscript pp. 1–4 | Counterexample on golf ball/carpet; do not transfer its numerical constants to pool |

## 1. Offset determines impulse torque, not an independent spin bonus

**Analytical idealization.** Initially stationary homogeneous sphere, radius `R`, mass `m`, moment `I = 2mR²/5`; level impulse `J` with perpendicular offset `b`:

```text
mv = J                    Iω = bJ
s = Rω/v = (5/2)(b/R)      ω = 5bv/(2R²)
```

Here `s` is dimensionless; `ω` is rad/s, not revolutions/s. Divide by `2π` for rev/s. A top offset `b=0.4R` produces immediate natural roll (`s=1`); `b=0.5R` gives `s=1.25`. The author's practical recommendation is approximately `|b|≤0.5R`, not the geometric edge `R`; this is an approximate miscue boundary, not a universal sharp material limit. [S1, Eq. 3 and pp. 1–2](https://drdavepoolinfo.com/technical_proofs/new/TP_A-12.pdf).

**Own energy calculation from those impulses:**

```text
Kt = mv²/2                 Kr = Iω²/2
Kr/Kt = (2/5)s² = (5/2)(b/R)²
Kr/(Kt+Kr) = [(5/2)(b/R)²] / [1+(5/2)(b/R)²]
```

Thus natural roll has 28.57% rotational energy; `|b|=0.5R` has 38.46%, not 50%. Combined horizontal/vertical offsets use the total perpendicular offset for total rotational energy in this ideal level-impulse construction. [S1, Eqs. 1–3](https://drdavepoolinfo.com/technical_proofs/new/TP_A-12.pdf).

## 2. “Same power” needs a specified physical quantity

**Analytical idealization.** For cue mass `M`, incoming cue speed `V`, initially resting ball, and perfectly elastic impact, the author's energy/momentum model gives:

```text
v = 2V / [1 + m/M + (5/2)(b/R)²]
ω = 5bv/(2R²)
```

At `m/M=1/3`, center-ball `v=1.5V`; at `b=0.5R`, `v=1.02128V`, 68.09% of the center-hit speed. More offset reduces translation **at fixed cue speed in this model**; it does not preserve a fixed total ball energy. Specifying final ball speed instead changes the comparison. Ball translational speed and spin both scale with `V`; energies scale with `V²`. [S2, pp. 1–2, Eqs. 1–9](https://drdavepoolinfo.com/technical_proofs/new/TP_A-30.pdf).

**Measured-versus-assumed boundary.** The author reports leather-tip restitution around `e=0.73` from his high-speed work and uses collision efficiency `η=0.87` for examples. `η` and `e` are different quantities. His Eq. 19 is an inefficient-impact alternative; the ideal formula above is not a measured universal launch law. Offset/speed dependence of restitution remains unquantified there. [S2, pp. 3–5, Eqs. 15–23](https://drdavepoolinfo.com/technical_proofs/new/TP_A-30.pdf).

## 3. Sliding is determined by contact-point velocity

**Analytical idealization.** On a level plane with upward unit normal `n`, let `r=-Rn` from center to cloth contact:

```text
u = v + ω × r
F = -μs mg u/|u|
dv/dt = F/m
dω/dt = (r × F)/I
du/dt = -(7/2)μs g u/|u|
tr = 2|u0|/(7μs g)
vr = v0 - (2/7)u0
```

These expressions apply until `u=0`; do not continue sliding friction past that event. With constant `μs`, slip direction stays fixed, velocity changes linearly, and the sliding trajectory is parabolic. Vertical-axis sidespin does not appear in `u` for a mathematical point contact. [S3, pp. 2–3, Eqs. 3–13; `vr` is direct integration](https://drdavepoolinfo.com/technical_proofs/new/TP_A-4.pdf).

This model neglects cloth deformation, rolling resistance during sliding, finite contact-patch spin torque, and airborne motion. Hence its mathematical zero vertical-spin decay is not a prediction that a real ball spins forever. [S3, contact-point construction](https://drdavepoolinfo.com/technical_proofs/new/TP_A-4.pdf), [S5, p. 4](https://drdavepoolinfo.com/technical_proofs/new/TP_B-2.pdf).

## 4. Numerical transition examples

**Own calculations**, using `R=0.028575 m` (2.25-inch diameter), `g=9.81 m/s²`, `μs=0.20`, initial **ball speed** `v0=2.00 m/s`; signed `ω>0` denotes forward roll. This comparison fixes ball speed, not cue speed.

| Initial vertical offset/model state | `Rω0/v0` | Time to roll | Distance to roll | Speed at roll |
|---|---:|---:|---:|---:|
| Center hit, zero initial top/bottom spin | 0 | 0.29125 s | 0.49928 m | 1.42857 m/s |
| `+0.4R`, natural roll | 1 | 0 | 0 | 2.00000 m/s |
| `+0.5R`, overspin | 1.25 | 0.07281 s | 0.15082 m | 2.14286 m/s |
| `-0.5R`, backspin | −1.25 | 0.65531 s | 0.88935 m | 0.71429 m/s |

For backspin, `ω0=−87.489 rad/s`; zero spin occurs earlier at `ts=−2Rω0/(5μs g)=0.50968 s`, distance `0.76453 m`, speed `1.000 m/s`. That is the stun location; afterward it gains topspin and eventually rolls. Values computed from [S4, Eqs. 1–6](https://drdavepoolinfo.com/technical_proofs/new/TP_A-18.pdf); overspin distance uses the acceleration sign from [S3, Eq. 7](https://drdavepoolinfo.com/technical_proofs/new/TP_A-4.pdf).

## 5. Draw, follow and stun describe the state at object-ball contact

**Analytical idealization.** In a straight, equal-mass, elastic, frictionless ball collision, the cue ball transfers its translational velocity and retains its spin. Subsequent cloth friction converts remaining backspin into backward velocity (draw), or forward spin into forward velocity (follow). Zero top/bottom spin at impact gives the ideal stop shot. These are ideal initial conditions, not immediate real-world velocity assignment rules. [S6, p. 1 and pp. 4–5](https://drdavepoolinfo.com/technical_proofs/new/TP_B-8.pdf).

With signed spin `ωc` retained after that ideal full hit, the ensuing rolling velocity is `2Rωc/7`; draw therefore depends on **remaining** backspin at collision, not merely a low contact point at launch. For cut shots, initial tangent motion and subsequent cloth acceleration must be kept distinct. [S6, p. 4, `vskid` formula](https://drdavepoolinfo.com/technical_proofs/new/TP_B-8.pdf), [S3, trajectory diagram and equations](https://drdavepoolinfo.com/technical_proofs/new/TP_A-4.pdf).

**Verified explanation:** a ball can roll without slipping while also retaining sidespin. “Sliding” broadly means nonzero cloth slip; the narrower instructor shorthand sometimes calls only zero-topspin stun “sliding.” Do not use the narrow shorthand as the simulator's state predicate. [S10, definition question and first explanatory paragraphs](https://drdavepoolinfo.com/faq/sidespin/slide-roll/).

## 6. Resistance values and dimensions

**Direct experiment:** Mathavan et al. measured snooker-ball rolling deceleration `0.124–0.126 m/s²`, equivalent to effective `μr=a/g=0.0127–0.0129`; sliding deceleration `1.75–2.40 m/s²`, equivalent to `μs=0.178–0.245`. Their tracked cushion-incident speeds were `0.28–3.5 m/s`, with prior rolling and no sidespin. These are conditions for one experimental setup, not universal pool tolerances. The reported pool range `0.011–0.024` is their citation to Marlow, **not their own measured range**. [S8, journal pp. 790–791, §III A/B](https://drdavepoolinfo.com/physics_articles/ajp_09_hsv_article.pdf).

**Author experiments:** Alciatore reports typical-cloth effective `μr≈0.01`, estimated using `μr=2L/(gT²)` for distance `L` and time `T` to stop. Stationary vertical-spin video tests give approximately `αz≈10 rad/s²`; he explicitly assumes approximately the same torque magnitude while rolling. This is evidence for a starting value, not proof that stationary and moving spin decay are identical. [S5, p. 2 Eqs. 4–5; p. 4 Eqs. 17–18 and following assumptions](https://drdavepoolinfo.com/technical_proofs/new/TP_B-2.pdf).

**Own dimensional audit:** choose one documented spin convention:

```text
Dimensionless c:    τz = c mgR       |dωz/dt| = 5cg/(2R)
Lever length ℓ [m]: τz = ℓ mg        |dωz/dt| = 5ℓg/(2R²)
Conversion: ℓ = cR
```

At the example radius, `αz=10 rad/s²` means `c=0.0116514` or `ℓ=0.000332938 m`. A value `0.0127` used in the first equation implies `10.90 rad/s²`; interpreting it as metres in the second implies approximately `381.5 rad/s²`. A parameter documented in metres cannot be used in the dimensionless equation. These are unit/algebra checks of `τ=Iα`, not new measurements. [S5, Eq. 18](https://drdavepoolinfo.com/technical_proofs/new/TP_B-2.pdf).

**Rolling model:** if `μr` is defined as observed center-of-mass deceleration divided by `g`, then `dv/dt=−μr g` and `dstop=v²/(2μr g)`. Do not insert an additional `5/7` unless adopting a different force/torque coefficient definition and deriving that relationship. [S7, pp. 1–2](https://drdavepoolinfo.com/technical_proofs/new/TP_B-6.pdf).

## 7. Speed ranges: teaching labels conflict across sources

Current author estimates, with **own exact SI conversions** (`1 mph=0.44704 m/s`): [S9, speed list](https://drdavepoolinfo.com/faq/speed/typical/).

| Label | mph | m/s |
|---|---:|---:|
| Soft touch | <1 | <0.44704 |
| Slow | 1–2 | 0.44704–0.89408 |
| Medium | 2–4 | 0.89408–1.78816 |
| Fast | 4–7 | 1.78816–3.12928 |
| Power | 7–10 | 3.12928–4.47040 |
| Powerful break | 25–30 | 11.176–13.4112 |

The page rounds some SI values differently; mph is the basis above. Older TP B.6 labels medium `7 mph`, fast `12 mph`, power `20 mph`; TP B.8 uses still higher labels specifically for draw examples. Treat labels as teaching/calculation choices, not standardized measurements or a single consistent dataset. The direct experimental ordinary-speed coverage above is narrower than the quoted break range. [S7, p. 1](https://drdavepoolinfo.com/technical_proofs/new/TP_B-6.pdf), [S6, p. 2](https://drdavepoolinfo.com/technical_proofs/new/TP_B-8.pdf), [S8, journal p. 791](https://drdavepoolinfo.com/physics_articles/ajp_09_hsv_article.pdf).

## 8. Proposed game calibration — recommendations, not verified constants

- Begin with `μs=0.20`, effective `μr=0.01`, and `αz≈10 rad/s²`; independently tune them against slide distance, rolling stop time, and spin-down time. The reference setups do not justify coupling all three into a single “cloth friction.” [S4](https://drdavepoolinfo.com/technical_proofs/new/TP_A-18.pdf), [S5](https://drdavepoolinfo.com/technical_proofs/new/TP_B-2.pdf).
- Define UI shot strength in a named quantity: preferably cue speed with an impact model, or explicitly ball launch speed with an acknowledged simplification. Keep the displayed spin control as a contact offset; apply a radial combined-offset boundary rather than allowing each axis independently to reach its maximum. This follows the perpendicular-impulse geometry; it is a proposed game choice. [S1](https://drdavepoolinfo.com/technical_proofs/new/TP_A-12.pdf), [S2](https://drdavepoolinfo.com/technical_proofs/new/TP_A-30.pdf).
- Verify center-hit `5/7` speed at rolling transition, immediate roll at `+0.4R`, overspin acceleration, and backspin's distinct stun/roll locations using the numerical cases above. Then validate collisions and rail responses separately; cloth-only verification does not establish either contact model.
- Stop/clamp friction at its relevant zero-crossing. Avoid using a ball's translational rest threshold to erase continuing vertical spin; also avoid allowing tiny residual slip to generate numerical reversals.

## Highest-risk misconceptions to correct

1. **“Half-radius offset sends half the energy into spin.”** The ideal ball-energy fraction is 38.46%; which energy is held fixed matters.
2. **“A low hit guarantees draw.”** The ball must still have backspin when it meets the object ball. Launch state and collision state differ.
3. **“All sliding balls have zero spin.”** Sliding means nonzero contact slip; backspin and overspin both qualify.
4. **“Sidespin automatically curves a level shot.”** Vertical-axis spin has no contact-point contribution in the ideal point-contact model. Real squirt, tilted-axis swerve, and finite-contact effects need their own models. Cross's near-vertical-spin carpet experiment exhibits drift, but its golf-ball/carpet constants are not pool calibration evidence. [S12, pp. 1–4](https://www.physics.usyd.edu.au/~cross/PUBLICATIONS/55.%20RollingBall.pdf).
5. **“Spin friction 0.0127 is unambiguous.”** Its dimensions must match the torque law; the same numeral can represent radically different decay.
6. **“The source says typical, therefore it is measured and universal.”** Separate author teaching estimates, experiments on a specified table, ideal derivations, and game calibration.

Additional limitation: off-center cue impact is not captured exactly by a fixed horizontal impulse. Cross's original experimental paper compares measured speed/spin against a simple impact model with normal and tangential forces. Only its abstract was accessible in this audit; no numerical correction or fit is claimed from it. [S11, abstract](https://journals.sagepub.com/doi/10.1177/17543371231184011).

Verification performed: inspected source equations and units; recomputed all numerical transition values and unit conversions with an isolated arithmetic script. No production-code edits or game runtime validation were performed.
