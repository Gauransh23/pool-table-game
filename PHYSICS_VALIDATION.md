# Physics validation

Last updated: 2026-10-27

## Current evidence

The headless suite checks equal-mass head-on momentum transfer, no-contact-reversal
sliding transition, cushion direction and bounds, identical state under different
frame chunking, centered and elevated cue contact, gravity-driven jump motion,
side-pocket fall state, rack composition, and 9-foot starting dimensions. The checks
are regression guards for the implemented model; they do not prove realism.

The separate rules tests exercise group assignment, called pockets, wrong-first
fouls, ball-in-hand, safeties, break choices, out-of-turn shots, and 8-ball outcomes.
They test the rules module directly and do not validate its integration with
physical events or UI.

## Starting parameters

| Parameter | Starting value | Evidence/status |
|---|---:|---|
| Table playing surface | 2.54 × 1.27 m | WPA recommended 9-foot size |
| Ball diameter | 0.05715 m | WPA equipment specification |
| Ball mass | 0.168 kg | Inside WPA 0.156–0.170 kg range |
| Corner pocket mouth | 0.116 m | Inside WPA 0.1143–0.1175 m range |
| Side pocket mouth | 0.129 m | Inside WPA 0.1270–0.130175 m range |
| Fixed simulation interval | 1/480 s | Baseline; convergence not measured |
| Ball restitution | 0.94 | Untuned starting value |
| Ball friction | 0.055 | Untuned starting value |
| Sliding friction | 0.19 | Untuned starting value |
| Cushion restitution | 0.84 | Untuned starting value; requires rail matrix |
| Cushion friction | 0.12 | Untuned starting value |

The values for mass, geometry, and mouth widths are grounded in the WPA document.
The contact coefficients are provisional, table-condition-dependent model inputs.

## Missing validation before the physics milestone

- Fixed-step convergence at increasing tick/substep quality for rolling, spin,
  collision, rail, pocket, jump, and break scenarios.
- Rail response matrix across speed, incidence, and spin, compared with the
  Mathavan/Jackson/Parkin cushion model and measured table behavior.
- Ball-ball cut, throw, low-speed, high-speed, cluster, and moving-contact cases.
- Corner and side jaw near-miss, rattle, shelf, and hanging-ball matrix.
- Thousands of seeded breaks with overlap, energy, tunneling, and reproducibility
  checks.
- Long-duration create/simulate/clear and serialization stress.
- Calibration preset ranges instead of a universal coefficient claim.
