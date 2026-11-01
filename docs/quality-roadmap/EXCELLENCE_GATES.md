# Excellence gates for the existing implementation roadmap

This supplements TASK.md; it does not create a competing implementation plan. Existing S0–S12 cards remain. Passing the earlier correctness gates is the floor. These gates raise the ceiling and define additional prerequisites. All reports live beside this file under reports/ or review-packets/.

## Shared executor contract

Before work, read TASK.md, EXCELLENCE_EXPLORATION.md and the applicable existing research/assessment. Confirm checkout and local instructions. Research cards may inspect source and write only the named report plus explicitly named evidence files. A prototype requiring source changes must receive a bounded write set from the lead; this document does not authorize a broad rewrite.

Each report must contain: requirement IDs; observed current representation; evidence status; proposed experiment; alternatives; selected decision or unresolved question; reproducible inputs/commands; actual outputs; uncertainty; counterexample; owner; next implementation card. Distinguish physics measurements, derived values, product choices and hypotheses.

An economical agent can gather evidence and execute frozen experiments. A strong reasoning reviewer owns physical-model selection, error-budget allocation and coupled-effect interpretation. A human owner chooses among concrete art/interaction preferences after evidence is supplied. Do not give smaller agents the instruction “make it feel premium” without a selected contract and examples.

Stop if a test oracle depends on the same implementation it is meant to validate, effects are smaller than measurement uncertainty, a source assumes a different contact regime, or a proposed change breaks another quality axis. Preserve results, state the smallest missing fact and propose the next discriminating experiment. Two retries without new information require a checkpoint.

## E0: Define the premium experience

Placement: Before S3.
Purpose/action: Read the owner clarification, EXCELLENCE_EXPLORATION and the existing assessment. Define six separate quality axes, reference shot families, target devices and an original art-direction brief. Mark universal requirements versus taste decisions.
Write authority/output: reports/E0-quality-charter.md; linked captures/data under reports/E0/.
Exit gate: Every axis has observable success, a failure example and a measurement method; no average score masks failure.
Verification: independent physical/analytic evidence for model claims; task trials for controls; matched video/listening for perception. Neither substitutes for the other.

```text
TASK_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/TASK.md
EXCELLENCE_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/EXCELLENCE_EXPLORATION.md
GATES_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/EXCELLENCE_GATES.md
REPORT_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/reports/E0-quality-charter.md
Read the shared executor contract. Execute only E0; inspect its prerequisites.
Read the owner clarification, EXCELLENCE_EXPLORATION and the existing assessment. Define six separate quality axes, reference shot families, target devices and an original art-direction brief. Mark universal requirements versus taste decisions.
Do not edit gameplay code. Record evidence, uncertainty, alternatives and a falsifier.
Pass only when: Every axis has observable success, a failure example and a measurement method; no average score masks failure.
Otherwise return CONDITIONAL or BLOCKED with a concrete next probe.
```

## E1: Audit mechanism coverage

Placement: Before S3; informs S2.
Purpose/action: For strike, cloth, balls, cushions, pockets and rest, map implemented equation, assumptions, unsupported regimes and supporting sources. Distinguish absent, simplified, uncalibrated and unverified. Build a behavior-to-source-to-test matrix.
Write authority/output: reports/E1-mechanisms.md; linked captures/data under reports/E1/.
Exit gate: Each claimed limitation has a source anchor; every proposed physical refinement has a predicted observable effect and independent oracle.
Verification: independent physical/analytic evidence for model claims; task trials for controls; matched video/listening for perception. Neither substitutes for the other.

```text
TASK_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/TASK.md
EXCELLENCE_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/EXCELLENCE_EXPLORATION.md
GATES_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/EXCELLENCE_GATES.md
REPORT_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/reports/E1-mechanisms.md
Read the shared executor contract. Execute only E1; inspect its prerequisites.
For strike, cloth, balls, cushions, pockets and rest, map implemented equation, assumptions, unsupported regimes and supporting sources. Distinguish absent, simplified, uncalibrated and unverified. Build a behavior-to-source-to-test matrix.
Do not edit gameplay code. Record evidence, uncertainty, alternatives and a falsifier.
Pass only when: Each claimed limitation has a source anchor; every proposed physical refinement has a predicted observable effect and independent oracle.
Otherwise return CONDITIONAL or BLOCKED with a concrete next probe.
```

## E2: Build the precision budget

Placement: Before S4; informs S7.
Purpose/action: Choose representative smooth and boundary shots. Derive input-to-endpoint sensitivity, parameter sensitivity and numerical convergence plans. Allocate input, model, solver, geometry and presentation error separately.
Write authority/output: reports/E2-error-budget.md; linked captures/data under reports/E2/.
Exit gate: Tolerances trace to task needs or measurement uncertainty; discontinuous pocket outcomes are not evaluated with inappropriate smooth-error metrics.
Verification: independent physical/analytic evidence for model claims; task trials for controls; matched video/listening for perception. Neither substitutes for the other.

```text
TASK_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/TASK.md
EXCELLENCE_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/EXCELLENCE_EXPLORATION.md
GATES_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/EXCELLENCE_GATES.md
REPORT_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/reports/E2-error-budget.md
Read the shared executor contract. Execute only E2; inspect its prerequisites.
Choose representative smooth and boundary shots. Derive input-to-endpoint sensitivity, parameter sensitivity and numerical convergence plans. Allocate input, model, solver, geometry and presentation error separately.
Do not edit gameplay code. Record evidence, uncertainty, alternatives and a falsifier.
Pass only when: Tolerances trace to task needs or measurement uncertainty; discontinuous pocket outcomes are not evaluated with inappropriate smooth-error metrics.
Otherwise return CONDITIONAL or BLOCKED with a concrete next probe.
```

## E3: Research expressive controls

Placement: Before S5.
Purpose/action: Design bounded alternative aiming/power/spin prototypes. Compare target acquisition, adjustment stability, low-power landing tasks and repeated-shot variance. Audit percentage rounding and spin clamp feedback.
Write authority/output: reports/E3-controls.md; linked captures/data under reports/E3/.
Exit gate: Selected interaction is justified by task evidence; machine resolution and human precision reported separately; no physics retuning to compensate for UI shortcomings.
Verification: independent physical/analytic evidence for model claims; task trials for controls; matched video/listening for perception. Neither substitutes for the other.

```text
TASK_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/TASK.md
EXCELLENCE_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/EXCELLENCE_EXPLORATION.md
GATES_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/EXCELLENCE_GATES.md
REPORT_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/reports/E3-controls.md
Read the shared executor contract. Execute only E3; inspect its prerequisites.
Design bounded alternative aiming/power/spin prototypes. Compare target acquisition, adjustment stability, low-power landing tasks and repeated-shot variance. Audit percentage rounding and spin clamp feedback.
Do not edit gameplay code. Record evidence, uncertainty, alternatives and a falsifier.
Pass only when: Selected interaction is justified by task evidence; machine resolution and human precision reported separately; no physics retuning to compensate for UI shortcomings.
Otherwise return CONDITIONAL or BLOCKED with a concrete next probe.
```

## E4: Validate coupled shot families

Placement: Before completion of S8.
Purpose/action: Build a held-out shot atlas covering stun/follow/draw, squirt/throw, spin transfer, rail response and pocket approaches. Record full trajectories and events, not just endpoints. Investigate only mechanisms whose errors exceed the agreed budget.
Write authority/output: reports/E4-shot-atlas.md; linked captures/data under reports/E4/.
Exit gate: All supported families have calibration/validation evidence and uncertainty; omitted phenomena have explicit domain limits and consequences.
Verification: independent physical/analytic evidence for model claims; task trials for controls; matched video/listening for perception. Neither substitutes for the other.

```text
TASK_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/TASK.md
EXCELLENCE_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/EXCELLENCE_EXPLORATION.md
GATES_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/EXCELLENCE_GATES.md
REPORT_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/reports/E4-shot-atlas.md
Read the shared executor contract. Execute only E4; inspect its prerequisites.
Build a held-out shot atlas covering stun/follow/draw, squirt/throw, spin transfer, rail response and pocket approaches. Record full trajectories and events, not just endpoints. Investigate only mechanisms whose errors exceed the agreed budget.
Do not edit gameplay code. Record evidence, uncertainty, alternatives and a falsifier.
Pass only when: All supported families have calibration/validation evidence and uncertainty; omitted phenomena have explicit domain limits and consequences.
Otherwise return CONDITIONAL or BLOCKED with a concrete next probe.
```

## E5: Resolve guide honesty

Placement: Before completion of S5/S8.
Purpose/action: Compare the displayed guide with actual launch, first contact and object-ball departure over spin/power sweeps. Choose direction-only or predictive semantics. Verify camera picking and guide thickness at gameplay scale.
Write authority/output: reports/E5-guides.md; linked captures/data under reports/E5/.
Exit gate: Displayed promise matches simulation within frozen bounds, or limitation is clear; no hidden modification of trajectories to make the guide look right.
Verification: independent physical/analytic evidence for model claims; task trials for controls; matched video/listening for perception. Neither substitutes for the other.

```text
TASK_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/TASK.md
EXCELLENCE_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/EXCELLENCE_EXPLORATION.md
GATES_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/EXCELLENCE_GATES.md
REPORT_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/reports/E5-guides.md
Read the shared executor contract. Execute only E5; inspect its prerequisites.
Compare the displayed guide with actual launch, first contact and object-ball departure over spin/power sweeps. Choose direction-only or predictive semantics. Verify camera picking and guide thickness at gameplay scale.
Do not edit gameplay code. Record evidence, uncertainty, alternatives and a falsifier.
Pass only when: Displayed promise matches simulation within frozen bounds, or limitation is clear; no hidden modification of trajectories to make the guide look right.
Otherwise return CONDITIONAL or BLOCKED with a concrete next probe.
```

## E6: Create the temporal visual deck

Placement: Before S9; repeat after S10.
Purpose/action: Capture the adversarial visual scenes in EXCELLENCE_EXPLORATION, including slow rolls and pocket transitions. Evaluate geometry, material response, ball identity, aliasing, shadows and camera changes. Compare original art prototypes at identical framing.
Write authority/output: reports/E6-visual-deck.md; linked captures/data under reports/E6/.
Exit gate: Still and motion review pass independently; detailed assets do not degrade readability or target-device pacing.
Verification: independent physical/analytic evidence for model claims; task trials for controls; matched video/listening for perception. Neither substitutes for the other.

```text
TASK_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/TASK.md
EXCELLENCE_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/EXCELLENCE_EXPLORATION.md
GATES_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/EXCELLENCE_GATES.md
REPORT_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/reports/E6-visual-deck.md
Read the shared executor contract. Execute only E6; inspect its prerequisites.
Capture the adversarial visual scenes in EXCELLENCE_EXPLORATION, including slow rolls and pocket transitions. Evaluate geometry, material response, ball identity, aliasing, shadows and camera changes. Compare original art prototypes at identical framing.
Do not edit gameplay code. Record evidence, uncertainty, alternatives and a falsifier.
Pass only when: Still and motion review pass independently; detailed assets do not degrade readability or target-device pacing.
Otherwise return CONDITIONAL or BLOCKED with a concrete next probe.
```

## E7: Calibrate contact feel

Placement: Before completion of S10.
Purpose/action: Measure cue animation/impulse/audio timestamps and recorded perceptual onset. Compare soft strokes, hard cuts, rails and breaks. Audit debounce and voice stealing. Prototype bounded audio and motion alternatives.
Write authority/output: reports/E7-contact-feel.md; linked captures/data under reports/E7/.
Exit gate: Distinct contacts survive dense sequences; material cues and timing remain coherent; perceived improvements supported by paired listening/play evidence.
Verification: independent physical/analytic evidence for model claims; task trials for controls; matched video/listening for perception. Neither substitutes for the other.

```text
TASK_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/TASK.md
EXCELLENCE_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/EXCELLENCE_EXPLORATION.md
GATES_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/EXCELLENCE_GATES.md
REPORT_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/reports/E7-contact-feel.md
Read the shared executor contract. Execute only E7; inspect its prerequisites.
Measure cue animation/impulse/audio timestamps and recorded perceptual onset. Compare soft strokes, hard cuts, rails and breaks. Audit debounce and voice stealing. Prototype bounded audio and motion alternatives.
Do not edit gameplay code. Record evidence, uncertainty, alternatives and a falsifier.
Pass only when: Distinct contacts survive dense sequences; material cues and timing remain coherent; perceived improvements supported by paired listening/play evidence.
Otherwise return CONDITIONAL or BLOCKED with a concrete next probe.
```

## E8: Run expert and novice quality trials

Placement: Before S12 signoff.
Purpose/action: Run frozen reference tasks in this game and selected accessible comparators, randomizing order. Include repeated sessions, expert positional-play tasks and novice learnability. Record participant counts, experience, device, uncertainty and dissent.
Write authority/output: reports/E8-comparison.md; linked captures/data under reports/E8/.
Exit gate: No unsupported superiority claim; material deficits trigger named follow-up work; favorable screenshots cannot waive physical/control deficits.
Verification: independent physical/analytic evidence for model claims; task trials for controls; matched video/listening for perception. Neither substitutes for the other.

```text
TASK_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/TASK.md
EXCELLENCE_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/EXCELLENCE_EXPLORATION.md
GATES_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/EXCELLENCE_GATES.md
REPORT_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/reports/E8-comparison.md
Read the shared executor contract. Execute only E8; inspect its prerequisites.
Run frozen reference tasks in this game and selected accessible comparators, randomizing order. Include repeated sessions, expert positional-play tasks and novice learnability. Record participant counts, experience, device, uncertainty and dissent.
Do not edit gameplay code. Record evidence, uncertainty, alternatives and a falsifier.
Pass only when: No unsupported superiority claim; material deficits trigger named follow-up work; favorable screenshots cannot waive physical/control deficits.
Otherwise return CONDITIONAL or BLOCKED with a concrete next probe.
```

## E9: Approve the complete experience

Placement: Extends S12.
Purpose/action: Independently trace original owner intent to every quality axis. Inspect raw evidence and replay adversarial shots. Review all simplifications for observable consequences and intentional product decisions.
Write authority/output: review-packets/excellence-review.md; linked captures/data under reports/E9/.
Exit gate: PASS only when all frozen axes clear their gates; otherwise CONDITIONAL/BLOCKED with concrete missing evidence and responsible next step.
Verification: independent physical/analytic evidence for model claims; task trials for controls; matched video/listening for perception. Neither substitutes for the other.

```text
TASK_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/TASK.md
EXCELLENCE_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/EXCELLENCE_EXPLORATION.md
GATES_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/EXCELLENCE_GATES.md
REPORT_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/review-packets/excellence-review.md
Read the shared executor contract. Execute only E9; inspect its prerequisites.
Independently trace original owner intent to every quality axis. Inspect raw evidence and replay adversarial shots. Review all simplifications for observable consequences and intentional product decisions.
Do not edit gameplay code. Record evidence, uncertainty, alternatives and a falsifier.
Pass only when: PASS only when all frozen axes clear their gates; otherwise CONDITIONAL/BLOCKED with concrete missing evidence and responsible next step.
Otherwise return CONDITIONAL or BLOCKED with a concrete next probe.
```

## Milestone ladder

M0 — Reliable baseline: reproduce known shortcomings and preserve evidence.
M1 — Precisely controllable instrument: aim, power, tip selection and guide promise agree.
M2 — Convincing shot repertoire: calibrated coupled physics and stable numerical behavior across supported families.
M3 — Cohesive presentation: visuals, motion and sound consistently communicate those physical events.
M4 — Competitive experience: repeated comparative play shows the frozen quality bar is met, with uncertainty and exceptions published.

M0 alone is not a successful response to the owner's request. Neither is M3 with weak M1/M2. Full modes may be planned separately, but cannot substitute for the quality milestone.
