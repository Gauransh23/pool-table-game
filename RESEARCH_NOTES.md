# Physics and rules research

Last checked: 2026-10-27

## Equipment geometry

The WPA Recommended Equipment Specifications list a 9-foot playing area of
100 × 50 inches nominal (2.54 × 1.27 m, with the listed tolerance), ball diameter 2 1/4 inches
(57.15 mm) and mass 156–170 g, corner-pocket mouths of 4.5–4.625 inches, and
side-pocket mouths of 5–5.125 inches. They also specify a cushion nose height of
62.5–64.5% of ball diameter. The project uses values inside those ranges as starting
geometry, not as a complete measured table profile.

Source: [WPA Recommended Equipment Specifications](https://wpapool.com/wp-content/uploads/2024/01/RECOMMENDED-EQUIPMENT-SPECIFICATIONS.pdf)

## 8-ball rules

The current WPA Rules of Play linked from the WPA rules page are effective
2025-09-15. They define called shots, open-table group assignment (including a
temporary group claim when one group is already cleared), legal break handling,
ball-in-hand fouls, and 8-ball win/loss conditions. The current rules module covers
common cases but remains incomplete; the full WPA profile and casual variants need
separate verification.

Sources: [WPA Rules of Play, current official download](https://wpapool.com/wp-content/uploads/2026/01/2026.01.02-WPA-Rules.pdf),
[WPA rule index](https://wpapool.com/rules/)

## Dynamics references

- Mathavan, Jackson, and Parkin, “Application of high-speed imaging to determine the
  dynamics of billiards” (2009), measured ball trajectories and friction and compared
  oblique collision results. [DOI: 10.1119/1.3157159](https://doi.org/10.1119/1.3157159)
- Mathavan, Jackson, and Parkin, “A theoretical analysis of billiard ball dynamics
  under cushion impacts” (2010), derives a 3D spinning ball/cushion impact model.
  Its reported coefficient values describe the studied equipment and must not be
  treated as universal. [DOI: 10.1243/09544062JMES1964](https://doi.org/10.1243/09544062JMES1964)
- “Motions of a billiard ball after a cue stroke” examines cue-tip contact and
  post-stroke motion. [arXiv:2104.11232](https://arxiv.org/abs/2104.11232)
- “Collision of two spinning billiard balls and the role of table” analyzes
  restitution, ball-ball friction, and table friction effects.
  [arXiv:2402.13258](https://arxiv.org/abs/2402.13258)

These papers inform model structure and future reference tests. The current solver
does not yet reproduce or validate against their numerical results. Elevated cue
contact currently does not create an upward jump impulse; a validated cue/table impact
model is needed before jump shots are exposed.

## Engine source

Godot's official release archive lists 4.7.2 stable, dated 2026-08-18, and 4.8 as
beta1. The project pins the stable Standard build.

Source: [Godot 4.7.2 stable archive](https://godotengine.org/download/archive/4.7.2-stable/)
