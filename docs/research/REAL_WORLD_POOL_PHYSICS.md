# Real pool physics: a learning guide and a physical vocabulary for Long Rail

Research date: 2026-11-04. Scope: research and numerical analysis; no game implementation changes.

For additional primary sources in experiments, cue coaching, real-table calibration, simulation research and audiovisual feedback, see the [expanded research scout](SCOUT_EXPANSION.md).

Reading routes: [sources](#2-rich-sources-and-how-to-learn-from-them) · [energy split](#4-where-the-initial-spin-comes-from) · [skid and roll](#6-how-sliding-becomes-rolling) · [draw/stop/follow](#7-why-the-same-low-hit-can-draw-stop-or-follow) · [angles](#8-what-changes-with-shot-angle) · [strength](#9-translate-casual-strength-into-physical-speed) · [distance](#10-translate-short-medium-and-long-into-table-distance) · [screen mapping](#11-convert-physical-motion-to-screen-motion) · [calibration](#14-research-to-simulator-calibration-contract-before-implementation).

## 1. What this investigation establishes

There is enough good public material to build a much stronger physical foundation. Start with Ron Shepard's free monograph, then use David Alciatore's technical proofs and high-speed demonstrations for specific questions. Use measured experiments to calibrate the model, rather than treating an elegant derivation or another simulator's defaults as proof of realism. The reading map below identifies the relevant chapters, equations, and limitations.

The central correction is that **linear momentum does not turn into angular momentum in a fixed percentage**. A cue impact supplies both linear impulse and angular impulse; cloth contact subsequently supplies an external force and torque. Translational and rotational *energy* can be compared as percentages, but some energy is dissipated. It matters whether we hold cue speed, ball launch speed, impulse, or input energy constant. These are different experiments. See the derivations in sections 4–6, grounded in [TP A.12, equations 1–3](https://drdavepoolinfo.com/technical_proofs/new/TP_A-12.pdf#page=1) and [TP A.30, equations 1–9](https://drdavepoolinfo.com/technical_proofs/new/TP_A-30.pdf#page=1).

**Evidence labels used here:**

- **Measured:** an author reports an experiment; retain its equipment and conditions.
- **Analytical:** an idealized physical result with stated assumptions.
- **Calculated here:** arithmetic or a derivation for this report; not a new real-table measurement.
- **Proposed:** a vocabulary, product choice, or future measurement target; not a sporting standard.
- **Repository observation:** a read-only observation of the current source.

## 2. Rich sources, and how to learn from them

| Source | What to read or watch | Why it is useful; boundary |
|---|---|---|
| [Ron Shepard, *Amateur Physics for the Amateur Pool Player*, third edition, 1997](https://drdavepoolinfo.com/physics_articles/Shepard_apapp.pdf) | Sections 1–3 for equipment, friction, natural roll and cue impact; later collision and rail sections; work the included problems | A free, 109-PDF-page, connected treatment linking player language to equations. Best starting text for this question. An authored analytical monograph, not a modern calibration dataset. PDF pages 5–12 cover friction; pages 15–22 develop natural roll and spin effects. |
| [David Alciatore, technical proof collection](https://drdavepoolinfo.com/technical-proof/) | A.12 → 4.1 → A.18 → A.30 → 3.2 → A.16 → A.14 → B.8 → B.2 | Particularly valuable because each narrow playing question has a worked mathematical answer. Read each proof's assumptions; numerical examples are not universal equipment constants. |
| [Alciatore's physics resource library](https://drdavepoolinfo.com/physics/) and [high-speed video index](https://drdavepoolinfo.com/high-speed-video/) | Use the linked super-slow-motion demonstrations alongside the proofs, especially stroke, draw/follow, throw and cushion impacts | The visual counterpart to the algebra. Includes a bibliography of books by Marlow, Coriolis and others. Those books are further reading; this report does not pretend to have read inaccessible full texts. |
| [Mathavan, Jackson & Parkin, *Application of high-speed imaging to determine the dynamics of billiards*, AJP 77, 788–794 (2009)](https://drdavepoolinfo.com/physics_articles/ajp_09_hsv_article.pdf) | Sections II–III, speed-time plots and friction measurements, particularly printed page 790 | Primary experiment on a 10 × 5 ft snooker table using 52.4 mm balls. Shows how to distinguish sliding and rolling from trajectories. The paper explicitly identifies adding spin tracking as further work: do not treat it as a full measured angular-velocity dataset for American pool. |
| [Mathavan, Jackson & Parkin, *A theoretical analysis of billiard ball dynamics under cushion impacts* (2010)](https://drdavepoolinfo.com/physics_articles/Mathavan_IMechE_2010.pdf) | Section 2 and rebound plots; read the abstract's validation limit first | A 3D frictional cushion-impact model, compared with experiments. Its rigid-cushion approximation is limited to normal impact velocities below about 2.5 m/s in the studied setup. Its parameters should not be copied to every rail or break-speed impact. |
| [Rod Cross, *Cue and ball deflection (or “squirt”) in billiards*, AJP 76, 205–212 (2008)](https://www.physics.usyd.edu.au/~cross/PUBLICATIONS/39.%20squirt.pdf) | Experimental methods, chalked versus unchalked contact, and the measured/modelled deflection | Primary experimental and theoretical work on why sidespin changes the launch direction. Useful antidote to a game that lets side spin affect only the next cushion. |
| [Hyeong-Chan Kim, *Motions of a billiard ball after a cue stroke* (2021 preprint; published 2022)](https://arxiv.org/abs/2104.11232) | Impact analysis and discussion of cue flexibility | A more advanced check on cue-impact assumptions and squirt. A theoretical model, not a universal measured stroke-to-spin lookup table. |
| [Kim, *Collision of two spinning billiard balls and the role of table* (2024)](https://arxiv.org/html/2402.13258v1) | Sections 2–5 | Examines departures from ideal equal-mass collisions, including ball friction and table interaction during impact. Useful for investigating small effects that basic diagrams omit. |
| [Antonio Doménech-Carbó, *Independent friction-restitution description of billiard ball collisions* (2023)](https://doi.org/10.1016/j.mechrescom.2023.104149) | Stick/slip regimes and postimpact versus subsequent rolling motion | A complementary original collision model. Helps distinguish a collision impulse from the later cloth-driven trajectory. This research pass verified its abstract and scope, not every equation in the full article. |
| [WPA Recommended Equipment Specifications](https://wpapool.com/wp-content/uploads/2024/01/RECOMMENDED-EQUIPMENT-SPECIFICATIONS.pdf) | Sections 5–9 and 16 | The geometric reference: playing surface, balls, cushions, pockets and shelves. It does not define a universal “medium shot” or a numeric stroke force. |

**Suggested learning exercise:** choose one question, predict it with a proof, watch its linked high-speed example, then identify what must be measured to compare our game with that shot. An equation, an observed phenomenon, and a fitted coefficient provide different kinds of evidence.

## 3. Quantities that must have unambiguous meanings

For this report, use a homogeneous solid sphere, mass `m`, radius `R`, moment of inertia `I = 2mR²/5`. Let `v` be forward center speed, and let `ω` be the signed rotation about the horizontal axis that produces forward roll: positive means forward rotation, negative means backspin. Vertical-axis sidespin is a separate component. These are the conventions behind [TP 4.1](https://drdavepoolinfo.com/technical_proofs/TP_4-1.pdf#page=1); our engine's axes differ, so a future implementation must map signs explicitly.

| Quantity | Meaning | Unit |
|---|---|---|
| `U` | Cue speed immediately before tip contact | m/s |
| `v₀` | Cue-ball center speed immediately after tip separation | m/s |
| `v_impact` | Cue-ball speed just before its next collision | m/s |
| `ω`, `ω_side` | Angular velocity components | rad/s, optionally rpm for display |
| `h/R`, `s/R` | Vertical and lateral tip offsets divided by ball radius | dimensionless |
| `J = ∫F dt` | Impulse delivered during contact | N·s = kg·m/s |
| `p = mv` | Linear momentum | kg·m/s |
| `L_spin = Iω` | Spin angular momentum about the center | kg·m²/s |
| `K_t = mv²/2`, `K_r = I|ω⃗|²/2` | Translational and rotational kinetic energy | joules |
| `q = Rω/v` | Forward spin relative to the rate required for natural roll | dimensionless; undefined at `v = 0` |
| `u = v − Rω` | Cloth contact slip in a straight shot | m/s |

“Power” has a precise physical unit, watts, but a game slider normally means selected stroke strength. **Proposed:** keep that player label if useful, but define its contract as cue speed or as a reference center-ball launch speed. Record the resulting launch speed and spin separately. A percentage on a slider is not a measured percentage of energy.

## 4. Where the initial spin comes from

For a horizontal impulse parallel to the intended shot direction, with negligible cloth impulse during the brief tip contact:

`mv₀ = J`

`Iω₀ = hJ`

Therefore:

`ω₀ = 5hv₀/(2R²)` and `q₀ = Rω₀/v₀ = 2.5h/R`.

These are analytical impulse relations; the reference is [TP A.12, equations 1–3](https://drdavepoolinfo.com/technical_proofs/new/TP_A-12.pdf#page=1). At a high offset, finite tip geometry, squirt and cue elevation can alter the simple relationship between a screen marker and the effective impulse arm.

**Calculated here: energy split immediately after a purely vertical-offset strike.** The denominator is the *ball's* kinetic energy after contact, not the cue's initial energy:

`K_r/K_t = (2/5)q₀² = 2.5(h/R)²`.

`rotational fraction = [2.5(h/R)²] / [1 + 2.5(h/R)²]`.

| Vertical offset | Initial `q₀` | Translational share | Rotational share | Initial forward motion |
|---:|---:|---:|---:|---|
| `0` | `0` | 100% | 0% | Sliding, no initial forward/back rotation |
| `+0.20R` | `+0.50` | 90.91% | 9.09% | Forward rotation slower than natural roll |
| `+0.25R` | `+0.625` | 86.49% | 13.51% | Still sliding despite topspin |
| `+0.40R` | `+1.00` | 71.43% | 28.57% | Natural roll immediately in this idealization |
| `+0.50R` | `+1.25` | 61.54% | 38.46% | Overspin; contact slips backward |
| `−0.40R` | `−1.00` | 71.43% | 28.57% | Backspin while translating forward |
| `−0.50R` | `−1.25` | 61.54% | 38.46% | More backspin; still translating forward |

The two opposite signs have equal rotational *energy*, but profoundly different trajectories. Lateral offset adds rotation about the vertical axis: for an ideal horizontal impulse, substitute `(h²+s²)/R²` for `(h/R)²` in the energy ratio. Only the forward-roll component belongs in `q`. Maximum offsets form a radial limit, not independent maximum horizontal and vertical offsets; [TP A.12](https://drdavepoolinfo.com/technical_proofs/new/TP_A-12.pdf#page=2) uses roughly `0.5R` as a typical recommended limit, rather than a universal miscue law.

For our `R = 28.575 mm`, `0.4R = 11.43 mm` above center. Its height above the cloth is `R + 0.4R = 40.005 mm`, or 70% of the ball diameter. **“70% height” does not mean 70% of radius above center.** Calculated here from the physical geometry.

### Holding ball speed fixed is different from holding stroke strength fixed

The energy table compares launch states. To produce the same `v₀` with a larger offset, the cue generally must supply more ball energy. For the *same cue speed*, the ball usually launches more slowly as offset grows; cue mass, contact loss, tip properties and flexibility matter. [TP A.30, equations 7 and 19–23](https://drdavepoolinfo.com/technical_proofs/new/TP_A-30.pdf#page=2) treats the simplified cue-mass and energy-loss problem; [Cross's experiments](https://www.physics.usyd.edu.au/~cross/PUBLICATIONS/39.%20squirt.pdf) examine actual contact and deflection.

As an analytical reference, a perfectly elastic axial impulse model with cue mass `M`, no cue rotation and offset magnitude `b` gives:

`v₀ = 2U / [1 + m/M + 2.5(b/R)²]`.

For `M = 3m`, calculated launch multipliers are `1.500U` at center, `1.154U` at `0.4R`, and `1.021U` at `0.5R`. This is a limiting model, not a measured cue calibration. A real cue-impact model must distinguish restitution from retained kinetic-energy efficiency. For example, **87% retained cue-plus-ball energy does not mean 87% of the cue's energy went into the ball**: the cue can retain substantial energy after contact.

## 5. Skid, roll and spin are overlapping properties

In the straight-shot convention above:

| State | Condition | What cloth friction does in the ideal sliding model |
|---|---|---|
| Draw/backspin | `ω < 0`, `v > 0` | Slows forward translation and reduces backspin, then builds forward rotation |
| Stun/no forward-roll spin | `ω = 0`, `v > 0` | Slows translation and starts forward rotation |
| Underspin | `0 < Rω < v` | Slows translation and increases forward rotation |
| Natural roll | `Rω = v` | No forward slip; rolling resistance subsequently slows the ball |
| Overspin | `Rω > v` | Reduces rotation and can **increase center speed** until natural roll |
| Sidespin | `ω_side ≠ 0` | Can coexist with all of the above; needs a separate spin-resistance model |

A ball can rotate and skid at the same time. The condition is about the contact patch's relative velocity, not whether the painted number is rotating. In full 3D, use `u⃗ = v⃗ + ω⃗ × (−Rn̂)` at the bottom point, projected onto the cloth. [TP A.4, equations 3–14](https://drdavepoolinfo.com/technical_proofs/new/TP_A-4.pdf#page=2) provides this vector treatment. Vertical-axis sidespin does not contribute to slip at the ideal bottom *point*; a real finite contact patch still resists that spin.

“Skid” also has a second player meaning: an abnormal ball–ball friction event called cling or kick. That is distinct from ordinary ball–cloth sliding; [TP A.14, final pages](https://drdavepoolinfo.com/technical_proofs/new/TP_A-14.pdf#page=16) treats the higher-friction collision case.

## 6. How sliding becomes rolling

For a level table, isotropic constant sliding coefficient `μ_s`, and no intervening collision, approximate the sliding force by:

`F = −μ_s mg sign(u)`.

Its force and torque give:

`dv/dt = −μ_s g sign(u)`

`dω/dt = +(5μ_s g/2R) sign(u)`

`du/dt = −(7/2)μ_s g sign(u)`.

The sliding phase ends at:

`t_roll = 2|v₀ − Rω₀|/(7μ_s g)`.

`v_roll = (5v₀ + 2Rω₀)/7`.

For straight shots before any reversal or impact:

`x_roll = v₀t_roll − 0.5μ_s g sign(v₀−Rω₀)t_roll²`.

These equations follow from the impulse relations and Coulomb friction; compare [TP 4.1, PDF pages 1–3](https://drdavepoolinfo.com/technical_proofs/TP_4-1.pdf#page=2) and the independent vector form in [TP A.4, equations 10–13](https://drdavepoolinfo.com/technical_proofs/new/TP_A-4.pdf#page=3). They neglect rolling losses during the sliding interval, cloth speed dependence, hops, and nonuniform cloth.

### A center-ball example answers the “conversion percentage” question

Start with `ω₀ = 0`. Then `v_roll = 5v₀/7`. Calculated energy accounting, expressed as percentages of the ball's *initial translational energy*, is:

| Destination at the start of natural roll | Share |
|---|---:|
| Remaining translational kinetic energy | `25/49 = 51.02%` |
| Newly acquired rotational kinetic energy | `10/49 = 20.41%` |
| Dissipated energy | `2/7 = 28.57%` |

Thus translation loses 48.98% of its initial energy; only part becomes rotation. At this endpoint, rotation is 28.57% of the *remaining* kinetic energy. Those two percentage statements use different denominators. This calculation is our energy check on the preceding ideal model, not a universal measured loss fraction for all strokes.

Momentum of the ball alone is not conserved during this interval: the cloth supplies an external impulse. For overspin, friction can move energy from rotation into translation while total kinetic energy still decreases. Merely subtracting speed every frame cannot reproduce both situations.

Rolling is a different regime: do not keep applying the sliding force after contact slip vanishes. In ideal rigid rolling on a stationary plane, static contact is not itself a source of sliding energy loss; real cloth/ball deformation and contact-patch effects require a rolling-resistance description. [TP B.2, PDF pages 1–2](https://drdavepoolinfo.com/technical_proofs/new/TP_B-2.pdf#page=1) develops a model with the cloth's normal force shifted ahead of the ball center. This is why a table can have strong sliding drag and much weaker rolling resistance.

### Numerical examples: when does the transition happen?

**Calculated here**, using `μ_s = 0.20`, `g = 9.81 m/s²`. The coefficient is an illustrative choice, not a new measurement. It is near the measured sliding range `0.178–0.245` in [Mathavan et al. 2009, printed page 790](https://drdavepoolinfo.com/physics_articles/ajp_09_hsv_article.pdf#page=3), whose equipment was snooker, not our pool table.

| Actual ball launch speed | Center hit: time to roll | Center hit: distance to roll | `h = −0.4R`: distance until backspin reaches zero | Same low hit: distance to natural roll |
|---:|---:|---:|---:|---:|
| 0.5 m/s | 0.073 s | 0.031 m | 0.041 m | 0.052 m |
| 1.0 m/s | 0.146 s | 0.125 m | 0.163 m | 0.208 m |
| 2.0 m/s | 0.291 s | 0.499 m | 0.652 m | 0.832 m |
| 4.0 m/s | 0.582 s | 1.997 m | 2.610 m | 3.329 m |

Distances in the last row can exceed the available straight path on our table: a rail or ball may interrupt the predicted transition. Comparing offsets at equal *launch speed* also requires different cue speeds, as discussed above.

For physical scale, the [2009 tracking experiment, printed page 790](https://drdavepoolinfo.com/physics_articles/ajp_09_hsv_article.pdf#page=3) measured sliding deceleration around `1.75–2.40 m/s²`, versus rolling deceleration around `0.124–0.126 m/s²`. The latter corresponds to effective `a_r/g ≈ 0.0127–0.0129`. Those measurements explain the need for distinct regimes; they do not make the studied snooker table's exact coefficients mandatory for our pool table. Also distinguish an *observed deceleration ratio* `a_r/g` from a rolling force or torque coefficient defined differently.

For a fixed initial spin ratio, transition time scales with speed and transition distance with **speed squared**. Double speed can quadruple the distance over which draw survives. Increasing sliding friction shortens both times and distances. In this ideal model it does not change the eventual `v_roll` for fixed initial state. These consequences are calculations from the equations, not additional coefficient measurements.

## 7. Why the same low hit can draw, stop, or follow

For an initially backspinning ball, the zero-backspin time is:

`t_stun = −2Rω₀/(5μ_s g)`.

If `h = −0.4R`, then `Rω₀ = −v₀`. The table above gives where this happens. At `v₀ = 2 m/s`, it happens after about 0.408 s and 0.652 m of *cue-center travel*. This is the transient no-forward-spin state, not the onset of natural roll; the ball is still sliding. The offset-dependent derivation is in [TP A.18, equations 1–5](https://drdavepoolinfo.com/technical_proofs/new/TP_A-18.pdf#page=1).

For a full straight collision with an identical stationary object ball, assume perfectly elastic contact and negligible tangential ball–ball impulse and table impulse during impact. Then the ideal normal impulse transfers away the cue ball's forward velocity while retaining its existing spin. Consequently:

- Reach the object ball while backspin remains: cloth friction subsequently drives the cue ball backward—draw.
- Reach it just as backspin reaches zero: an ideal stop shot.
- Reach it after forward rotation develops: cloth friction subsequently drives the cue ball forward—follow.

For the `2 m/s`, `−0.4R` example, placing the contact after 0.30 m of cue-center travel gives draw; near 0.652 m gives a stop; beyond that gives follow, provided the ball reaches the collision without another event. These are ideal direction predictions, not promised return distances. A source that develops the full dependence on offset, cue speed, travel distance and losses is [TP B.8, especially PDF pages 4–8 and its concluding observations](https://drdavepoolinfo.com/technical_proofs/new/TP_B-8.pdf#page=4).

If positions are measured center-to-center before the shot, add one diameter to get these setups: contact travel of 0.652 m means initial center separation about `0.652 + 0.05715 = 0.709 m` for a full hit. Mixing surface gaps and center separations would corrupt a test.

**Inverse question: how low must I hit for a stop at a chosen distance?** Calculated from the same sliding equations, with actual launch speed `v₀` and cue-center travel `d`:

`v_contact = √(v₀² − 2μ_s gd)`

`h/R = −(1 − v_contact/v₀)`.

This chooses zero forward-roll spin at contact. It requires a real positive contact speed and an offset within the permitted radial limit; do not use it after an intervening rail or during a different motion regime. At `v₀ = 2 m/s`, `μ_s = 0.20`, stopping at `d = 0.50 m` needs approximately `h = −0.286R`; at `d = 0.652 m` it needs about `−0.400R`. At `d = 1.00 m` it would need about `−0.862R`, outside the assumed `0.5R` practical bound. The response is to change launch speed or shot plan. Because these examples hold ball speed fixed, changing the offset also requires changing cue speed in a physical strike model. This inverse calculation is derived from [TP A.18's spin and travel relations](https://drdavepoolinfo.com/technical_proofs/new/TP_A-18.pdf#page=1), not a measured aiming chart.

Ordinary backspin does **not** mean the unobstructed ball will eventually reverse on its own. The formula gives reversal only if `Rω₀ < −2.5v₀`; an ideal horizontal stroke within `0.5R` supplies only about `Rω₀ ≥ −1.25v₀`. Calculated here: such a free ball normally loses draw and rolls forward. A collision that removes translation changes that conclusion.

## 8. What changes with shot angle?

### Ideal two-ball collision: use this as a reference, not the entire game

Define cut angle `φ` between the incoming cue-ball direction and the line joining the centers **at contact**. For identical balls, stationary object ball, perfectly elastic normal contact and no tangential ball–ball impulse:

`v_OB = v_in cos φ`, `v_CB = v_in sin φ`.

The outgoing velocity directions are perpendicular when both velocities are nonzero. [TP 3.2, PDF pages 1–2](https://drdavepoolinfo.com/technical_proofs/TP_3-2.pdf#page=1) gives the speed and ball-hit-fraction relationships.

**Calculated here:** fractions below are of incoming *translational* energy. For a spinning incoming ball, they are not fractions of its total energy.

| Cut | Object speed / incoming speed | Cue speed / incoming speed | Object translational energy | Cue translational energy |
|---:|---:|---:|---:|---:|
| 0° | 1.000 | 0.000 | 100% | 0% |
| 15° | 0.966 | 0.259 | 93.3% | 6.7% |
| 30° | 0.866 | 0.500 | 75% | 25% |
| 45° | 0.707 | 0.707 | 50% | 50% |
| 60° | 0.500 | 0.866 | 25% | 75% |
| 75° | 0.259 | 0.966 | 6.7% | 93.3% |

A half-ball hit means about a 30° cut in this geometry; it does not mean half the energy goes to each ball. The 45° cut gives equal immediate translational energies. A thin hit transfers little speed to the object ball, so a long thin pot can require substantial incoming cue-ball speed even when the desired pocket-entry speed is low.

### Separate the instant of contact from the next part of the path

With stun at impact, the cue ball approximately follows the tangent line. With forward roll or draw, the surviving spin is mismatched to its new center velocity, and cloth friction curves the departure away from that initial tangent. A simplified natural-roll collision gives the eventual straight departure angle, measured away from the original incoming direction:

`δ = atan[5 sinφ cosφ / (2 + 5 sin²φ)]`.

Calculated angles: `φ = 15°, 30°, 45°, 60°` gives `δ ≈ 28.2°, 33.7°, 29.1°, 20.6°`. This explains why the player “30° rule” is approximate over a range of ordinary cuts, not an instruction to force every follow collision to 30°. See [TP A.16, PDF pages 1–3](https://drdavepoolinfo.com/technical_proofs/new/TP_A-16.pdf#page=1) and the [author's explanation of the 30° rule](https://drdavepoolinfo.com/faq/30-90-rules/30-degree-rule/). These are eventual directions after the brief curved/sliding segment, before later collisions.

Real impacts also involve restitution, friction, spin transfer and throw. [Kim's 2024 collision paper](https://arxiv.org/html/2402.13258v1) explicitly investigates table and ball friction during the short contact itself. Therefore the ideal angle table is an analytical limit to test, not an empirical pass certificate.

## 9. Translate casual strength into physical speed

The most directly useful teaching reference is [Alciatore's typical pool-ball speeds page](https://drdavepoolinfo.com/faq/speed/typical/). Its categories refer to **cue-ball speed**, not cue speed or hand force. The following m/s conversions are calculated here from the page's mph boundaries using `1 mph = 0.44704 m/s`, avoiding its rounded mixed-unit boundaries.

| Teaching label from that page | Ball speed | Approximate m/s |
|---|---:|---:|
| Soft touch | <1 mph | <0.447 |
| Slow | 1–2 mph | 0.447–0.894 |
| Medium | 2–4 mph | 0.894–1.788 |
| Fast | 4–7 mph | 1.788–3.129 |
| Power shot | 7–10 mph | 3.129–4.470 |
| Powerful break | 25–30 mph | 11.176–13.411 |

The gap between 10 and 25 mph is not forbidden: this is a set of contextual examples, not a complete official classification. Intermediate break speeds exist. The same author uses `slow = 3 mph`, `medium = 7 mph`, `fast = 12 mph` in older [TP A.18 examples](https://drdavepoolinfo.com/technical_proofs/new/TP_A-18.pdf#page=1). Preserve that disagreement: labels vary with purpose and presentation. Do not silently combine the two scales.

**Proposed game vocabulary:** use the current teaching bands as initial calibration anchors; call 3.1–4.5 m/s “firm/power” and reserve an independently calibrated upper range for breaks. Expose much finer control below 0.45 m/s for delicate position play. A strength percentage should map smoothly to a declared reference cue-ball speed, while the actual offset-dependent launch state is calculated from the strike model. The choice to compensate offsets automatically would be an assist and must be explicit.

### What does “strength” mean in newtons?

A cue strike is brief. Impulse is the useful bridge: for a stationary `0.168 kg` ball, `J = mv₀`. Calculated examples:

| Ball launch speed | Linear impulse | Translational energy |
|---:|---:|---:|
| 0.15 m/s | 0.0252 N·s | 0.00189 J |
| 0.50 m/s | 0.084 N·s | 0.021 J |
| 1.50 m/s | 0.252 N·s | 0.189 J |
| 3.00 m/s | 0.504 N·s | 0.756 J |
| 4.50 m/s | 0.756 N·s | 1.701 J |
| 12.0 m/s | 2.016 N·s | 12.096 J |

Average contact force additionally requires contact duration: `F_avg = J/Δt`; peak force additionally requires the force-time profile. [TP B.22, PDF pages 1–2](https://drdavepoolinfo.com/technical_proofs/new/TP_B-22.pdf#page=1) uses illustrative fast-shot durations of 0.8 ms for a phenolic tip and 1.2 ms for leather. If we assume `v₀ = 12 m/s`, `m = 0.168 kg`, `Δt = 1 ms`, our calculation is `F_avg = 2016 N`; a triangular profile has `F_peak = 4032 N`. These are contact-force estimates, not the sustained force of the player's hand, and the same contact duration should not be presumed for all shots.

## 10. Translate short, medium and long into table distance

WPA specifies a nominal 9-foot **playing area** of `2.54 × 1.27 m`, not a playing length of 9 actual feet. It specifies 57.15 mm pool balls and 317.5 mm sight spacing on a 9-foot table. See [WPA sections 5, 6 and 16](https://wpapool.com/wp-content/uploads/2024/01/RECOMMENDED-EQUIPMENT-SPECIFICATIONS.pdf#page=2). Our table and ball dimensions match those nominal values.

I did not find a universal numerical standard for short/medium/long shots. **Proposed descriptive bins for this project**, using travel before first ball contact along the intended cue-center path:

| Label | Table-length fraction `d/2.54` | Physical path | Nominal sight-spacing units |
|---|---:|---:|---:|
| Short | `0 ≤ d/L < 0.25` | <0.635 m | <2 |
| Medium | `0.25 ≤ d/L < 0.50` | 0.635–1.270 m | 2–4 |
| Long | `0.50 ≤ d/L ≤ 1.00` | 1.270–2.540 m | 4–8 |
| Extended/diagonal/multi-rail | `d/L > 1.00` | >2.540 m | >8 |

The full table diagonal is about 2.840 m; the ball-center reachable rectangle is smaller. The diagonal value is a geometric scale, not a legal collision-free path for every layout. A bank route can be much longer than one length even when start and finish are nearby.

Record **cue travel to contact**, **initial CB–OB center separation**, **OB path to pocket**, and **desired post-collision CB path** separately. A 0.2 m cue-ball approach with a 2 m object-ball pot is short in one sense and long in another. Difficulty also depends on cut and pocket approach angle; the label alone is insufficient.

“Pocket speed” needs its own operational meaning: the object ball arrives with just enough speed to complete the pot reliably along the specified route. **Proposed:** record pocket-entry speed separately from launch strength, and determine acceptable entry speeds from geometry and observations. A long or thin cut can require a firm cue strike to produce a gentle arrival. It would be misleading to assign one launch-speed percentage to every pocket-speed shot.

### Stop distance is a different quantity from shot length

For an already naturally rolling ball with constant effective deceleration `a_r`, `d_stop = v²/(2a_r)` and `t_stop = v/a_r`. [TP B.2, equations 2–5](https://drdavepoolinfo.com/technical_proofs/new/TP_B-2.pdf#page=1) describes how to measure deceleration; its author reports a representative `a_r/g ≈ 0.01`, with dependence on cloth and conditions.

**Calculated here, using our current effective rolling setting `a_r/g = 0.012`, no rails or other balls:**

| Desired natural-roll stopping distance | Needed initial rolling speed | Stop time |
|---:|---:|---:|
| 0.05 m | 0.108 m/s | 0.922 s |
| 0.10 m | 0.153 m/s | 1.303 s |
| 0.25 m | 0.243 m/s | 2.061 s |
| 0.50 m | 0.343 m/s | 2.915 s |
| 1.00 m | 0.485 m/s | 4.122 s |
| 2.54 m | 0.773 m/s | 6.569 s |

An initially spinless center hit must first slide and lose energy. Its total unobstructed travel is approximately:

`d_total = 12v₀²/(49μ_s g) + (5v₀/7)²/(2a_r)`.

For our current `μ_s = 0.19`, `a_r/g = 0.012`, a 0.10 m total travel needs about **0.209 m/s** center-hit launch speed, versus 0.153 m/s for natural roll. Calculated from the preceding analytical model. This directly explains why a useful “touch” control must reach much lower than 0.4 m/s.

Do not infer table speed from a single rail-to-rail path without accounting for cushion losses and initial skid. [TP B.6](https://drdavepoolinfo.com/technical_proofs/new/TP_B-6.pdf) treats table-length travel including rebound losses; the flat unbounded stopping formula above does not.

## 11. Convert physical motion to screen motion

**Repository observations:** [table_spec.gd](../../scripts/sim/table_spec.gd#L4) defines `2.54 × 1.27`; [ball_state.gd](../../scripts/sim/ball_state.gd#L4) defines `R = 0.028575` and `m = 0.168`; [project.godot](../../project.godot#L21) starts at a 1600 × 900 viewport. The [camera](../../scripts/presentation/table_presentation.gd#L304) is orthographic and constructed tilted with size 2.15; the [controller](../../scripts/app/game_controller.gd#L33) immediately requests overhead view, reached through a 0.45 s transition. Views and zoom remain adjustable. The viewport width is **not** the displayed playing-surface length.

**Calculated screen mapping:** if the cushion-nose-to-nose long axis is displayed as `W` pixels, a displacement along that projected axis is `d_px = W d_m / 2.54`, and its speed is `v_px/s = W v_m/s / 2.54`.

| Physical quantity along long axis | At 1000 px playing length | At 1200 px playing length |
|---|---:|---:|
| One meter | 393.7 px | 472.4 px |
| One ball diameter | 22.50 px | 27.00 px |
| One sight spacing | 125 px | 150 px |
| Short/medium boundary, 0.635 m | 250 px | 300 px |
| Medium/long boundary, 1.27 m | 500 px | 600 px |
| Motion at 1 m/s | 393.7 px/s | 472.4 px/s |

These are conditional scale examples, **not measurements of the current screenshot**. A tilted view foreshortens the cross-table direction. Use the two projected table-axis vectors to map an arbitrary displacement; do not apply the long-axis scale to every screen direction. For a perspective camera, projection additionally varies with position. This is geometric analysis of the camera model, not a change to physical units.

**Proposed invariant:** the same physical initial state and shot must produce the same meter-space trajectory at every resolution, zoom and camera angle. Render it at the correct projected scale. Changing resolution should never change drag, speed, ball size relative to the physical table, or collision distances.

Changing the *physical* table size is a different experiment. From the equations above, relative skid distance depends on `v₀²/(μ_s gL)` and initial spin ratio. **Calculated consequence:** keeping the same real ball speed and cloth on a smaller table makes skid occupy a larger fraction of the table. Scaling speed by `√L` would preserve that dimensionless skid fraction, but would change the real-world stroke. Therefore a 7-foot and a 9-foot table should not be made to feel identical by silently scaling friction or ball speed; any such normalization is an explicit gameplay assist or variant.

**Perceptual consequence, calculated:** at 1200 px per table length, a 12 m/s ball moves about 94.5 px in one 60 Hz frame—roughly 3.5 displayed ball diameters. A physically correct fast break can look discontinuous without suitable temporal presentation. This does not justify slowing simulated time; it creates a rendering and event-timing requirement.

## 12. Additional questions that a convincing simulator must answer

### Does sidespin make the ball curve like a thrown football?

Not in the ideal level-cue, point-contact, isotropic-cloth model simply because vertical-axis spin exists. Squirt is an *initial launch-angle change*. Swerve is subsequent path curvature, involving the tilted spin state associated with cue elevation and cloth interaction. Throw is a different effect at the ball–ball collision. [Cross 2008](https://www.physics.usyd.edu.au/~cross/PUBLICATIONS/39.%20squirt.pdf) establishes measured squirt; [TP A.19](https://drdavepoolinfo.com/technical_proofs/new/TP_A-19.pdf) develops curved paths and massé. A future aim guide must say which of these effects it predicts or assists.

### Do clean balls always separate along the line of centers?

Only the normal impulse does. Tangential friction can throw the object ball away from that line and transfer spin. [TP A.14](https://drdavepoolinfo.com/technical_proofs/new/TP_A-14.pdf) treats speed, cut and spin effects; [TP A.26](https://drdavepoolinfo.com/technical_proofs/new/TP_A-26.pdf) treats gearing outside spin that reduces contact slip. Slow stun cuts are an important comparison case; a single frictionless angle sweep will miss this behavior. Exact throw depends on contact conditions and cannot be replaced by one fixed extra angle.

### Does equal incidence imply equal reflection at a rail?

That is a geometric baseline, not a complete cloth-covered cushion model. Incidence, normal speed, sidespin, forward spin, cushion friction, restitution and nose geometry affect both outgoing speed and angle. The [Mathavan 2010 cushion paper](https://drdavepoolinfo.com/physics_articles/Mathavan_IMechE_2010.pdf) provides response plots and states its speed limit. “Long” and “short” also describe bank rebound directions relative to an expected route; that usage must be distinguished from shot distance.

### Why can the same ball enter a pocket slowly and rattle out quickly?

Pocket acceptance involves mouth, facing angles, shelf, slate fall edge, approach angle, speed and spin—not just distance from a hole center. [WPA section 9](https://wpapool.com/wp-content/uploads/2024/01/RECOMMENDED-EQUIPMENT-SPECIFICATIONS.pdf#page=3) constrains physical geometry; [TP B.15](https://drdavepoolinfo.com/technical_proofs/new/TP_B-15.pdf) explores pocket geometry. **Proposed:** compare complete acceptance boundaries across angle and speed, including hanging balls and jaw contacts.

### Does rolling automatically mean sidespin has vanished?

No. Forward roll constrains the horizontal components of angular velocity, while vertical-axis spin can remain. [TP B.2, PDF page 4](https://drdavepoolinfo.com/technical_proofs/new/TP_B-2.pdf#page=4) reports spin-down measurements around 10 rad/s² in the author's setup. That observation supports measuring a separate spin-decay law, not applying it universally to every moving or stationary ball.

### What about tiny hops, elevated cues and unequal balls?

Our analytical tables assume on-cloth motion and identical balls. Cue elevation, slate impacts and cushion contact can briefly invalidate those assumptions. [Kim 2024](https://arxiv.org/html/2402.13258v1) examines table interaction in ball collisions. **Proposed:** identify whether a reference recording contains airborne intervals or unequal cue/object balls before fitting planar equations. Do not tune cloth friction to compensate for missing contact with the cloth.

### Can the ball look physically wrong when its positions are right?

Yes as a presentation hypothesis: if simulated orientation, rendered stripe rotation, impact sound or cue contact timing disagrees with the event, the user receives inconsistent evidence. **Proposed:** record orientation alongside trajectories and synchronize sounds with physical contacts. Use measured relative normal speed or impulse as candidate sound-intensity inputs; the precise loudness, timbre and room response require audio references and listening validation. This research has not measured an acoustic transfer function, so an “energy-to-volume” formula is not established here.

## 13. What the current repository tells us, without changing it

| Observation | Consequence | Evidence |
|---|---|---|
| The current Sol branch maps slider power `p` to cue speed `0.075 + 7.925p² m/s`, with zero as no shot and 0.005 UI steps | The physical mapping is defined, but the player-facing readout is still a percentage; “soft/medium/firm” needs its own calibration and user test | [StrokePower](../../scripts/sim/stroke_power.gd), [power mapping measurements](../quality-roadmap/reports/stroke-power.md) |
| With `m = 0.168 kg`, cue mass `M = 0.52 kg`, and the current central-strike model, the calculated launch multiplier is about 1.27266 | **Calculated:** default `p = 0.42` selects cue speed about 1.473 m/s and gives an initial center-hit ball speed about 1.875 m/s. The old `p=0.01` minimum produced 0.399 m travel in the 0.2.0 baseline. The new 0.5% center-hit probe produced about 0.096 m/s and measured 2.107 cm travel in its oversized-table fixture. | [cue strike model](../../scripts/sim/cue_strike_model.gd), [controller default](../../scripts/app/game_controller.gd#L13), [Sol's stroke-power report](../quality-roadmap/reports/stroke-power.md) |
| The new low-end power probe meets its proposed 1–3 cm simulated travel band | This is useful evidence that the control curve now exposes a delicate shot range. It does not yet show that people can select that travel reliably or that a physical table produces the same distance. | [PWR targets](../quality-roadmap/targets/02-controls-and-presentation.md#pwr-power-and-useful-force-levels), [stroke-power report](../quality-roadmap/reports/stroke-power.md) |
| Sliding, rolling and spinning coefficients already exist separately | Their existence does not establish correct calibration. The next evidence needs speed and spin versus time, not another claim that coefficients were implemented | [physics_config.gd](../../scripts/sim/physics_config.gd#L12), [physics_stepper.gd:151](../../scripts/sim/physics_stepper.gd#L151) |
| `PHYSICS_VALIDATION.md` labels spinning friction `0.0127 m`; runtime uses `α = 5cg/(2R)` | Unit convention needs correction before calibration: in that formula `c` must be dimensionless | [documentation:47](../../PHYSICS_VALIDATION.md#L47), [runtime:173](../../scripts/sim/physics_stepper.gd#L173) |
| The latest quality contract explicitly separates analytic consistency, numerical convergence, table calibration and human acceptance | The previously passing unit suite is still only one evidence layer. A test count cannot establish correspondence with a real table. | [physics validation](../../PHYSICS_VALIDATION.md), [quality targets](../quality-roadmap/QUALITY_TARGETS.md) |

**Calculated unit audit:** if spin torque is `τ = cmgR`, `c` is dimensionless and `α = 5cg/(2R)`. If torque is `τ = ℓmg`, `ℓ` has units of meters and `α = 5ℓg/(2R²)`. With our radius, dimensionless `c = 0.0127` gives about 10.90 rad/s²; a literal lever length `ℓ = 0.0127 m` gives about 381.5 rad/s². Equivalent to 10 rad/s² is `c ≈ 0.01165` or `ℓ ≈ 0.000333 m`. These are algebraic conversions, not proof of what coefficient the game should adopt.

## 14. Research-to-simulator calibration contract, before implementation

The important follow-up is a measured reference-table dataset. **Proposed sequence:**

1. Declare one target equipment profile: pool table playing dimensions, ball size/mass, cloth, cushions, cue/tip and conditions. Preserve snooker results as supporting evidence, not exact American-pool targets.
2. Measure naturally rolling speed against time on straight free paths. Fit effective rolling deceleration, repeat in several directions, and report residuals and uncertainty.
3. Measure center, high and low strikes with marked balls so that both translation and spin can be tracked. Fit sliding behavior from the transition as well as deceleration. Hold back some speeds and offsets from fitting.
4. Measure cue speed immediately before contact, ball speed/spin after contact, physical offset and elevation. Fit a stroke model; distinguish a retained-energy parameter from restitution and actual ball-energy transfer.
5. Compare draw/stop/follow using multiple travel distances and speeds, recording the state *at collision*. A correct initial spin ratio is insufficient.
6. Measure cut-angle and rail matrices with speed and spin; report directions and speed losses immediately after contact and after natural roll resumes. Include full hits and thin cuts.
7. Measure pocket acceptance by angle/speed with geometry held fixed. Check shelves, hanging balls and rattles before visual tuning obscures those boundaries.
8. Compare held-out shots end to end. Validate numerical convergence separately from experimental correspondence. Set experimental tolerances from reference uncertainty and gameplay sensitivity, not arbitrary tiny error bars.

For each shot, retain `table profile, ball positions and orientations, U, physical tip offset, elevation, v₀, ω⃗₀, trajectory/time samples, transition time, pre/postcollision states, eventual rest positions, camera mapping, measurement uncertainty`. Also retain the original recording and provenance. Treat unobservable or poorly estimated inputs as uncertain, rather than fitting every discrepancy into cloth friction.

### Useful future reference cases and what they would answer

These are **specifications for later tests**, not new code or claims that the current game passes them.

| Case | Analytical or observational target | Why it matters |
|---|---|---|
| Center strike, `v₀ = 1 m/s`, `μ_s = 0.20`, rolling losses disabled during slip | Roll begins near 0.145624 s, 0.124821 m; `v = 5/7 m/s` | Detects incorrect transition dynamics |
| Overspin `q₀ = 1.25` | Center speed initially increases while total kinetic energy decreases | Detects always-slowing drag models |
| Low strike `q₀ = −1`, `v₀ = 2 m/s`, same cloth | Zero backspin near 0.407747 s and 0.652396 m; natural roll near 0.582496 s and 0.832137 m | Distinguishes stun from roll |
| Full-hit approach distances below, at and above the preceding stun distance | Draw, ideal stop, follow; separate immediate impact from cloth response | Checks the user's central distance/strength/offset question |
| Ideal equal-mass cut sweep with tangential friction disabled | Section 8 speeds/angles; energy and momentum budgets | Establishes a clean analytical limit |
| Real cut shots at several measured speeds and spins | Throw and transferred spin within reference uncertainty | Prevents ideal geometry masquerading as realism |
| Spin-down of a marked stationary ball | Compare angular speed against time under declared conditions | Separates spin resistance and its units |
| Rail matrix with angle measured from an explicitly named normal/tangent | Fit outgoing speed, spin and direction; respect model validity limits | Prevents a single plausible bank from validating all rails |
| Identical shot at different zooms, viewport sizes and camera views | Identical physical trajectories; correctly projected motion | Separates screen scale from physical scale |
| Very short free travel, 5–10 cm | Reproducible delicate stroke with enough input resolution | Ensures the control exposes realistic low-speed play |

## 15. Investigation ledger and remaining uncertainty

| Question | Result | Evidence/status | Remaining work |
|---|---|---|---|
| Is there a universal strength-to-spin percentage? | No; derive energy shares from the launch state, not slider percentage | A.12/A.30 and independent energy algebra | Measure actual cue impact at offsets/elevations |
| Can friction accelerate a ball? | Yes for overspin while total energy falls | 4.1/A.4 analytical limits | Compare marked-ball recordings |
| Does low tip position guarantee draw? | No; spin at object contact controls the outcome | A.18/B.8 | Target-table shot matrix |
| Are soft/medium/hard fixed standards? | No universal standard established; one useful teaching scale found, plus conflicting older example labels | Author's current speed page versus A.18 | Player calibration/usability evidence |
| Can shot distance be defined by pixels? | Only after physical projection; screen size alone is insufficient | Repository camera/geometry and projection calculation | Measure actual rendered playing dimensions in each view |
| Are generic friction constants sufficient evidence? | No; experiments have equipment and model boundaries | Mathavan 2009/2010 | Target American-pool calibration dataset |
| Does the updated power curve expose a useful touch range? | Sol's current source probe measured 2.107 cm travel at 0.5% power on an oversized one-ball fixture, inside the proposed simulated target. Human precision and physical-table matching remain open. | Reported in the current local [stroke-power checkpoint](../quality-roadmap/reports/stroke-power.md); simulation evidence only | Test selection/repeatability on the installed game and check measured table travel |
| What unanswered effects matter next? | Throw, squirt/swerve, rail response, pockets and timing/orientation consistency | Primary reading map plus independent review | Rank using measured gameplay discrepancies |

Independent frames used: primary-source research audit; expert question coverage; failure pre-mortem; second-order analysis of input, projection and assists. They converged on measuring speed and spin through time and separating physical state from controls and rendering. One framing suggested defining distance labels through free-roll travel; this report retains free-roll travel as a *separate strength calibration* and defines shot-length labels by a named physical path, because the two quantities answer different questions.

Supporting artifacts: [independent source audit](physics-source-audit.md) and [independent mathematical/source review](physics-research-review.md). The review found no blocking equation or numerical errors. Its camera wording correction and local collision assumptions are incorporated above, along with its suggested inverse stop-shot example. Review confirms internal explanation checks, not experimental validation of the game.

No user interview was needed for these factual questions. Expensive broad ideation and implementation skills were not run because the deliverable is a grounded physics explanation. Open uncertainties include exact target-table coefficients, actual stroke distributions, elevated-cue dynamics, contact-model validity outside measured ranges, acoustic response and a fresh measured comparison against the reference commercial game. This research does not claim those are settled.
