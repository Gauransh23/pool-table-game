---
task_id: quality-roadmap
title: Physics and visual quality recovery
workflow_profile: deep
criticality: T3
state: IN_PROGRESS
lead_agent: codex-continuation
implementation_owner: next-authorized-executor
target_worktree: "/Users/codex/Documents/My Public Repos/pool-table-game"
target_branch: main
target_head: 5788954d8b6c9111177888a04b529400c86ac926
task_revision: 3
contract_revision: 2
---

# Artifact variables

TASK_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/TASK.md
QUESTION_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/QUESTIONS.md
TARGET_WORKTREE=/Users/codex/Documents/My Public Repos/pool-table-game
TARGET_REPO=/Users/codex/Documents/My Public Repos/pool-table-game
TARGET_BRANCH=main
TARGET_HEAD=5788954d8b6c9111177888a04b529400c86ac926
IMPLEMENTATION_TARGETS=scripts/, assets/, tests/, tools/ as bounded by cards
REPORTS_DIR=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/reports
REVIEW_PACKETS_DIR=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/review-packets

# 1. Task contract

## Outcome
Deliver the quality milestone specified below.

## Goals
Repair core play quality.

## Acceptance evidence
RESEARCH.md defines measurable gates.

## Invariants
Preserve simulation ownership and evidence integrity.

## Scope and risk

Status: conditional. Research and baseline collection are ready; gameplay implementation depends on S3 and local prerequisite gates. This turn delivers assessment and planning, not implementation. Read ASSESSMENT.md and RESEARCH.md first. Goal: a convincing, controllable practice table with measured physics, coherent visuals and dependable lifecycle. Non-goals: online multiplayer, AI, economy, progression, new platforms and broad engine rewrite.

Invariants: meter/second units remain explicit; render/audio do not alter simulation; no undocumented assistance; preserve undo and saved-state recovery; keep failures visible; never loosen thresholds without recorded rationale and review; do not claim native tests validate the active engine. Preserve unrelated work. No publishing or account actions are authorized by this roadmap.

# 2. Selected workflow

## Selection rationale

Deep T3: numerical model uncertainty and weak perceptual oracles demand research before implementation. One lead owns TASK.md and contract revisions. One executor owns each active source change; run overlapping file work sequentially. Economical agents collect evidence and implement frozen contracts. Strong reasoning review owns solver selection and ambiguous physical semantics. These are capability classes, not unverified model rankings. No subagents were dispatched for this assessment.

# 4. Evidence ledger

Source baseline and earlier evidence are recorded in ASSESSMENT.md. Flow: main.tscn -> GameController input/power -> CueStrikeModel -> BallState -> PhysicsStepper/TableSpec -> contact events -> TableAudio, BallVisual and HUD -> settled save. Symmetry obligations: all six pockets, both spin signs, both cameras, shot/undo/restore, GDScript/native (parity unresolved), model/render geometry. The separate rules module is out of scope until fundamentals pass.

# 5. Investigation Register

QUESTIONS.md contains decision-changing investigations. Owner preference is needed only for original art direction and any unresolved realism/assistance tradeoff; research should supply concrete alternatives first. Proposed default: believable calibrated physics with optional visible aiming assistance. No human gate is required for read-only investigation or reproducing failures.

# Execution discipline

Before each card, verify checkout, dirty state and current ownership against the baseline; read back goal, non-goals, first edit and acceptance rows. Save a report after each bounded change. On contradiction, preserve best verified state and stop semantic edits. Two failed attempts without new evidence require an escalation packet: baseline, changed files, known facts, disproved hypotheses, last verified state, exact unknown, next discriminating probe and resume condition. Do not blindly retry.

Contract changes append old/new requirement, evidence, authority and affected steps to CONTRACT_REVISIONS.jsonl. Do not execute source edits on a stale contract. Tests derive from requirements, not implementation internals. Independent final review reads original request and evidence before planner conclusions.

# 9. Step and subtask cards

## S0 — Reproduce baseline

Purpose: Run documented regression, practice and quality suites; capture two camera views and shot videos. Preserve exit codes and environment.
Depends on: none.
Agent role: bounded executor/researcher.
Write authority: tests/, tools/, docs/quality/; plus reports/S0.md. Do not edit TASK.md as a delegated worker.
**Decision density:** moderate.
**Verification strength:** strong for recorded facts; avoid unsupported quality inference.
**Model:** economical capability with explicit inputs and gates.
**Niche skills:** Agent auto-routing only — follow repository/domain instructions without adding competing workflow owners.
Inputs/variables: TASK_FILE, ASSESSMENT.md, RESEARCH.md, prerequisite reports, current source.
Outputs: authorized changes and /Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/reports/S0.md.
**Exit gate:** Baseline evidence includes four quality-contract outcomes, engine version, hardware and unresolved blockers.
**Stop/re-plan if:** prerequisite evidence is missing, oracle conflicts with physical evidence, scope expands, or required hardware/access is unavailable. Record partial results and a concrete next probe.

```text
TASK_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/TASK.md
TARGET_WORKTREE=/Users/codex/Documents/My Public Repos/pool-table-game
REPORT_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/reports/S0.md
Execute only S0. Read its prerequisite reports and confirm current checkout before edits.
Read back the contract and first action. Run documented regression, practice and quality suites; capture two camera views and shot videos. Preserve exit codes and environment.
Write only the card's authorized paths and REPORT_FILE. Record commands, actual results,
artifacts, counterexamples and remaining uncertainty. Exit only when: Baseline evidence includes four quality-contract outcomes, engine version, hardware and unresolved blockers.
Otherwise report CONDITIONAL or BLOCKED with a resumable escalation packet.
```

## S1 — Competitive evidence

Purpose: Execute RESEARCH sections 1 and 6; compare representative accessible products using matched tasks.
Depends on: S0.
Agent role: bounded executor/researcher.
Write authority: reports/competitors.md; plus reports/S1.md. Do not edit TASK.md as a delegated worker.
**Decision density:** moderate.
**Verification strength:** strong for recorded facts; avoid unsupported quality inference.
**Model:** economical capability with explicit inputs and gates.
**Niche skills:** Agent auto-routing only — follow repository/domain instructions without adding competing workflow owners.
Inputs/variables: TASK_FILE, ASSESSMENT.md, RESEARCH.md, prerequisite reports, current source.
Outputs: authorized changes and /Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/reports/S1.md.
**Exit gate:** Dated captures and observations support each comparison; unavailable references explicit.
**Stop/re-plan if:** prerequisite evidence is missing, oracle conflicts with physical evidence, scope expands, or required hardware/access is unavailable. Record partial results and a concrete next probe.

```text
TASK_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/TASK.md
TARGET_WORKTREE=/Users/codex/Documents/My Public Repos/pool-table-game
REPORT_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/reports/S1.md
Execute only S1. Read its prerequisite reports and confirm current checkout before edits.
Read back the contract and first action. Execute RESEARCH sections 1 and 6; compare representative accessible products using matched tasks.
Write only the card's authorized paths and REPORT_FILE. Record commands, actual results,
artifacts, counterexamples and remaining uncertainty. Exit only when: Dated captures and observations support each comparison; unavailable references explicit.
Otherwise report CONDITIONAL or BLOCKED with a resumable escalation packet.
```

## S2 — Physical reference dataset

Purpose: Read primary sources, derive isolated analytic checks and design measured-shot acquisition.
Depends on: S0.
Agent role: bounded executor/researcher.
Write authority: reports/physical-oracles.md; plus reports/S2.md. Do not edit TASK.md as a delegated worker.
**Decision density:** moderate.
**Verification strength:** strong for recorded facts; avoid unsupported quality inference.
**Model:** economical capability with explicit inputs and gates.
**Niche skills:** Agent auto-routing only — follow repository/domain instructions without adding competing workflow owners.
Inputs/variables: TASK_FILE, ASSESSMENT.md, RESEARCH.md, prerequisite reports, current source.
Outputs: authorized changes and /Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/reports/S2.md.
**Exit gate:** Units, assumptions, uncertainty and held-out families recorded; no default coefficient presented as calibration.
**Stop/re-plan if:** prerequisite evidence is missing, oracle conflicts with physical evidence, scope expands, or required hardware/access is unavailable. Record partial results and a concrete next probe.

```text
TASK_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/TASK.md
TARGET_WORKTREE=/Users/codex/Documents/My Public Repos/pool-table-game
REPORT_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/reports/S2.md
Execute only S2. Read its prerequisite reports and confirm current checkout before edits.
Read back the contract and first action. Read primary sources, derive isolated analytic checks and design measured-shot acquisition.
Write only the card's authorized paths and REPORT_FILE. Record commands, actual results,
artifacts, counterexamples and remaining uncertainty. Exit only when: Units, assumptions, uncertainty and held-out families recorded; no default coefficient presented as calibration.
Otherwise report CONDITIONAL or BLOCKED with a resumable escalation packet.
```

## S3 — Freeze quality contract

Purpose: Resolve tolerances, target hardware, original art direction, pocket support semantics and assistance policy. Reconcile prior SOL_HANDOFF.
Depends on: S1 S2.
Agent role: specialist/reviewer.
Write authority: reports/specification.md; plus reports/S3.md. Do not edit TASK.md as a delegated worker.
**Decision density:** high.
**Verification strength:** moderate; human/physical evidence required.
**Model:** strong reasoning capability for consequential judgment.
**Niche skills:** Agent auto-routing only — follow repository/domain instructions without adding competing workflow owners.
Inputs/variables: TASK_FILE, ASSESSMENT.md, RESEARCH.md, prerequisite reports, current source.
Outputs: authorized changes and /Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/reports/S3.md.
**Exit gate:** Every requirement has an oracle and owner; high-impact unknowns resolved or explicitly blocked.
**Stop/re-plan if:** prerequisite evidence is missing, oracle conflicts with physical evidence, scope expands, or required hardware/access is unavailable. Record partial results and a concrete next probe.

```text
TASK_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/TASK.md
TARGET_WORKTREE=/Users/codex/Documents/My Public Repos/pool-table-game
REPORT_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/reports/S3.md
Execute only S3. Read its prerequisite reports and confirm current checkout before edits.
Read back the contract and first action. Resolve tolerances, target hardware, original art direction, pocket support semantics and assistance policy. Reconcile prior SOL_HANDOFF.
Write only the card's authorized paths and REPORT_FILE. Record commands, actual results,
artifacts, counterexamples and remaining uncertainty. Exit only when: Every requirement has an oracle and owner; high-impact unknowns resolved or explicitly blocked.
Otherwise report CONDITIONAL or BLOCKED with a resumable escalation packet.
```

## S4 — Fixture and measurement harness

Purpose: Add shared deterministic fixtures, event/trajectory export, frame timing and comparison reports without altering gameplay.
Depends on: S3.
Agent role: bounded executor/researcher.
Write authority: tests/, measurement-only tools/; plus reports/S4.md. Do not edit TASK.md as a delegated worker.
**Decision density:** moderate.
**Verification strength:** strong for recorded facts; avoid unsupported quality inference.
**Model:** economical capability with explicit inputs and gates.
**Niche skills:** Agent auto-routing only — follow repository/domain instructions without adding competing workflow owners.
Inputs/variables: TASK_FILE, ASSESSMENT.md, RESEARCH.md, prerequisite reports, current source.
Outputs: authorized changes and /Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/reports/S4.md.
**Exit gate:** Known-bad injected outputs fail checks; exported data exercises playable GDScript path.
**Stop/re-plan if:** prerequisite evidence is missing, oracle conflicts with physical evidence, scope expands, or required hardware/access is unavailable. Record partial results and a concrete next probe.

```text
TASK_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/TASK.md
TARGET_WORKTREE=/Users/codex/Documents/My Public Repos/pool-table-game
REPORT_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/reports/S4.md
Execute only S4. Read its prerequisite reports and confirm current checkout before edits.
Read back the contract and first action. Add shared deterministic fixtures, event/trajectory export, frame timing and comparison reports without altering gameplay.
Write only the card's authorized paths and REPORT_FILE. Record commands, actual results,
artifacts, counterexamples and remaining uncertainty. Exit only when: Known-bad injected outputs fail checks; exported data exercises playable GDScript path.
Otherwise report CONDITIONAL or BLOCKED with a resumable escalation packet.
```

## S5 — Aim and stroke control

Purpose: Implement deliberate aim gestures, retained aim, monotonic useful low-power curve and exact cue-impact synchronization.
Depends on: S4.
Agent role: bounded executor/researcher.
Write authority: scripts/app/game_controller.gd, scripts/ui/, tests/; plus reports/S5.md. Do not edit TASK.md as a delegated worker.
**Decision density:** moderate.
**Verification strength:** strong for recorded facts; avoid unsupported quality inference.
**Model:** economical capability with explicit inputs and gates.
**Niche skills:** Agent auto-routing only — follow repository/domain instructions without adding competing workflow owners.
Inputs/variables: TASK_FILE, ASSESSMENT.md, RESEARCH.md, prerequisite reports, current source.
Outputs: authorized changes and /Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/reports/S5.md.
**Exit gate:** CTL-LOCK, CTL-SOFT and FEEL-CONTACT pass without retuning cloth to compensate.
**Stop/re-plan if:** prerequisite evidence is missing, oracle conflicts with physical evidence, scope expands, or required hardware/access is unavailable. Record partial results and a concrete next probe.

```text
TASK_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/TASK.md
TARGET_WORKTREE=/Users/codex/Documents/My Public Repos/pool-table-game
REPORT_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/reports/S5.md
Execute only S5. Read its prerequisite reports and confirm current checkout before edits.
Read back the contract and first action. Implement deliberate aim gestures, retained aim, monotonic useful low-power curve and exact cue-impact synchronization.
Write only the card's authorized paths and REPORT_FILE. Record commands, actual results,
artifacts, counterexamples and remaining uncertainty. Exit only when: CTL-LOCK, CTL-SOFT and FEEL-CONTACT pass without retuning cloth to compensate.
Otherwise report CONDITIONAL or BLOCKED with a resumable escalation packet.
```

## S6 — Pocket geometry and support

Purpose: Implement frozen support/capture contract and shared geometry; distinguish supported, shelf/jaw interaction and irreversible fall.
Depends on: S4.
Agent role: bounded executor/researcher.
Write authority: scripts/sim/table_spec.gd, scripts/sim/physics_stepper.gd, scripts/presentation/table_presentation.gd, tests/; plus reports/S6.md. Do not edit TASK.md as a delegated worker.
**Decision density:** moderate.
**Verification strength:** strong for recorded facts; avoid unsupported quality inference.
**Model:** economical capability with explicit inputs and gates.
**Niche skills:** Agent auto-routing only — follow repository/domain instructions without adding competing workflow owners.
Inputs/variables: TASK_FILE, ASSESSMENT.md, RESEARCH.md, prerequisite reports, current source.
Outputs: authorized changes and /Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/reports/S6.md.
**Exit gate:** All six pockets pass boundary, rattle and support fixtures; rendered debug overlay agrees.
**Stop/re-plan if:** prerequisite evidence is missing, oracle conflicts with physical evidence, scope expands, or required hardware/access is unavailable. Record partial results and a concrete next probe.

```text
TASK_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/TASK.md
TARGET_WORKTREE=/Users/codex/Documents/My Public Repos/pool-table-game
REPORT_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/reports/S6.md
Execute only S6. Read its prerequisite reports and confirm current checkout before edits.
Read back the contract and first action. Implement frozen support/capture contract and shared geometry; distinguish supported, shelf/jaw interaction and irreversible fall.
Write only the card's authorized paths and REPORT_FILE. Record commands, actual results,
artifacts, counterexamples and remaining uncertainty. Exit only when: All six pockets pass boundary, rattle and support fixtures; rendered debug overlay agrees.
Otherwise report CONDITIONAL or BLOCKED with a resumable escalation packet.
```

## S7 — Numerical solver decision

Purpose: Measure convergence, grazing and cluster order dependence. Compare bounded solver improvements and native migration costs.
Depends on: S4 S6.
Agent role: specialist/reviewer.
Write authority: reports/solver-decision.md; plus reports/S7.md. Do not edit TASK.md as a delegated worker.
**Decision density:** high.
**Verification strength:** moderate; human/physical evidence required.
**Model:** strong reasoning capability for consequential judgment.
**Niche skills:** Agent auto-routing only — follow repository/domain instructions without adding competing workflow owners.
Inputs/variables: TASK_FILE, ASSESSMENT.md, RESEARCH.md, prerequisite reports, current source.
Outputs: authorized changes and /Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/reports/S7.md.
**Exit gate:** Strong reviewer selects smallest adequate approach with falsifier; migration remains conditional on parity and build proof.
**Stop/re-plan if:** prerequisite evidence is missing, oracle conflicts with physical evidence, scope expands, or required hardware/access is unavailable. Record partial results and a concrete next probe.

```text
TASK_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/TASK.md
TARGET_WORKTREE=/Users/codex/Documents/My Public Repos/pool-table-game
REPORT_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/reports/S7.md
Execute only S7. Read its prerequisite reports and confirm current checkout before edits.
Read back the contract and first action. Measure convergence, grazing and cluster order dependence. Compare bounded solver improvements and native migration costs.
Write only the card's authorized paths and REPORT_FILE. Record commands, actual results,
artifacts, counterexamples and remaining uncertainty. Exit only when: Strong reviewer selects smallest adequate approach with falsifier; migration remains conditional on parity and build proof.
Otherwise report CONDITIONAL or BLOCKED with a resumable escalation packet.
```

## S8 — Physics calibration

Purpose: Implement approved numerical repair, fit coefficients against training families, then evaluate held-out shots.
Depends on: S7.
Agent role: specialist/reviewer.
Write authority: scripts/sim/, tests/, reports/calibration.md; plus reports/S8.md. Do not edit TASK.md as a delegated worker.
**Decision density:** high.
**Verification strength:** moderate; human/physical evidence required.
**Model:** strong reasoning capability for consequential judgment.
**Niche skills:** Agent auto-routing only — follow repository/domain instructions without adding competing workflow owners.
Inputs/variables: TASK_FILE, ASSESSMENT.md, RESEARCH.md, prerequisite reports, current source.
Outputs: authorized changes and /Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/reports/S8.md.
**Exit gate:** Analytic, convergence and measured gates pass with residuals/uncertainty; failures retained.
**Stop/re-plan if:** prerequisite evidence is missing, oracle conflicts with physical evidence, scope expands, or required hardware/access is unavailable. Record partial results and a concrete next probe.

```text
TASK_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/TASK.md
TARGET_WORKTREE=/Users/codex/Documents/My Public Repos/pool-table-game
REPORT_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/reports/S8.md
Execute only S8. Read its prerequisite reports and confirm current checkout before edits.
Read back the contract and first action. Implement approved numerical repair, fit coefficients against training families, then evaluate held-out shots.
Write only the card's authorized paths and REPORT_FILE. Record commands, actual results,
artifacts, counterexamples and remaining uncertainty. Exit only when: Analytic, convergence and measured gates pass with residuals/uncertainty; failures retained.
Otherwise report CONDITIONAL or BLOCKED with a resumable escalation packet.
```

## S9 — Visual vertical slice

Purpose: Produce one coherent pocket, cloth/rail region and three representative balls; evaluate gameplay-scale identity and depth.
Depends on: S3 S6.
Agent role: specialist/reviewer.
Write authority: scripts/presentation/, assets/, reports/art-slice.md; plus reports/S9.md. Do not edit TASK.md as a delegated worker.
**Decision density:** high.
**Verification strength:** moderate; human/physical evidence required.
**Model:** strong reasoning capability for consequential judgment.
**Niche skills:** Agent auto-routing only — follow repository/domain instructions without adding competing workflow owners.
Inputs/variables: TASK_FILE, ASSESSMENT.md, RESEARCH.md, prerequisite reports, current source.
Outputs: authorized changes and /Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/reports/S9.md.
**Exit gate:** Owner-selected direction plus evidence of readability; no geometry mismatch or frame-budget regression.
**Stop/re-plan if:** prerequisite evidence is missing, oracle conflicts with physical evidence, scope expands, or required hardware/access is unavailable. Record partial results and a concrete next probe.

```text
TASK_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/TASK.md
TARGET_WORKTREE=/Users/codex/Documents/My Public Repos/pool-table-game
REPORT_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/reports/S9.md
Execute only S9. Read its prerequisite reports and confirm current checkout before edits.
Read back the contract and first action. Produce one coherent pocket, cloth/rail region and three representative balls; evaluate gameplay-scale identity and depth.
Write only the card's authorized paths and REPORT_FILE. Record commands, actual results,
artifacts, counterexamples and remaining uncertainty. Exit only when: Owner-selected direction plus evidence of readability; no geometry mismatch or frame-budget regression.
Otherwise report CONDITIONAL or BLOCKED with a resumable escalation packet.
```

## S10 — Full presentation and audio

Purpose: Extend approved art, integrate cue motion and event-driven audio; investigate interpolation only if motion measurements justify it.
Depends on: S5 S9.
Agent role: bounded executor/researcher.
Write authority: scripts/presentation/, scripts/ui/, assets/, tools/generate_audio.py; plus reports/S10.md. Do not edit TASK.md as a delegated worker.
**Decision density:** moderate.
**Verification strength:** strong for recorded facts; avoid unsupported quality inference.
**Model:** economical capability with explicit inputs and gates.
**Niche skills:** Agent auto-routing only — follow repository/domain instructions without adding competing workflow owners.
Inputs/variables: TASK_FILE, ASSESSMENT.md, RESEARCH.md, prerequisite reports, current source.
Outputs: authorized changes and /Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/reports/S10.md.
**Exit gate:** Visual matrix, listening evidence and contact timing pass; presentation never mutates physical state.
**Stop/re-plan if:** prerequisite evidence is missing, oracle conflicts with physical evidence, scope expands, or required hardware/access is unavailable. Record partial results and a concrete next probe.

```text
TASK_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/TASK.md
TARGET_WORKTREE=/Users/codex/Documents/My Public Repos/pool-table-game
REPORT_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/reports/S10.md
Execute only S10. Read its prerequisite reports and confirm current checkout before edits.
Read back the contract and first action. Extend approved art, integrate cue motion and event-driven audio; investigate interpolation only if motion measurements justify it.
Write only the card's authorized paths and REPORT_FILE. Record commands, actual results,
artifacts, counterexamples and remaining uncertainty. Exit only when: Visual matrix, listening evidence and contact timing pass; presentation never mutates physical state.
Otherwise report CONDITIONAL or BLOCKED with a resumable escalation packet.
```

## S11 — Lifecycle and performance

Purpose: Repair save/restore, test pauses/undo, profile catch-up and long sessions; choose explicit overload policy before changing timing.
Depends on: S8 S10.
Agent role: bounded executor/researcher.
Write authority: scripts/app/, scripts/sim/physics_stepper.gd, tests/, reports/performance.md; plus reports/S11.md. Do not edit TASK.md as a delegated worker.
**Decision density:** moderate.
**Verification strength:** strong for recorded facts; avoid unsupported quality inference.
**Model:** economical capability with explicit inputs and gates.
**Niche skills:** Agent auto-routing only — follow repository/domain instructions without adding competing workflow owners.
Inputs/variables: TASK_FILE, ASSESSMENT.md, RESEARCH.md, prerequisite reports, current source.
Outputs: authorized changes and /Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/reports/S11.md.
**Exit gate:** LIFE-REPLAY, stress and target hardware frame budgets pass; no silent loss of simulation time.
**Stop/re-plan if:** prerequisite evidence is missing, oracle conflicts with physical evidence, scope expands, or required hardware/access is unavailable. Record partial results and a concrete next probe.

```text
TASK_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/TASK.md
TARGET_WORKTREE=/Users/codex/Documents/My Public Repos/pool-table-game
REPORT_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/reports/S11.md
Execute only S11. Read its prerequisite reports and confirm current checkout before edits.
Read back the contract and first action. Repair save/restore, test pauses/undo, profile catch-up and long sessions; choose explicit overload policy before changing timing.
Write only the card's authorized paths and REPORT_FILE. Record commands, actual results,
artifacts, counterexamples and remaining uncertainty. Exit only when: LIFE-REPLAY, stress and target hardware frame budgets pass; no silent loss of simulation time.
Otherwise report CONDITIONAL or BLOCKED with a resumable escalation packet.
```

## S12 — Independent acceptance review

Purpose: Reconstruct requirements from original request, inspect diff and raw evidence; run representative counterexamples and comparative playtest.
Depends on: S11.
Agent role: specialist/reviewer.
Write authority: review-packets/final-review.md; plus reports/S12.md. Do not edit TASK.md as a delegated worker.
**Decision density:** high.
**Verification strength:** moderate; human/physical evidence required.
**Model:** strong reasoning capability for consequential judgment.
**Niche skills:** Agent auto-routing only — follow repository/domain instructions without adding competing workflow owners.
Inputs/variables: TASK_FILE, ASSESSMENT.md, RESEARCH.md, prerequisite reports, current source.
Outputs: authorized changes and /Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/reports/S12.md.
**Exit gate:** PASS or explicit CONDITIONAL/BLOCKED with defects. No completion claim from assertion count.
**Stop/re-plan if:** prerequisite evidence is missing, oracle conflicts with physical evidence, scope expands, or required hardware/access is unavailable. Record partial results and a concrete next probe.

```text
TASK_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/TASK.md
TARGET_WORKTREE=/Users/codex/Documents/My Public Repos/pool-table-game
REPORT_FILE=/Users/codex/Documents/My Public Repos/pool-table-game/docs/quality-roadmap/reports/S12.md
Execute only S12. Read its prerequisite reports and confirm current checkout before edits.
Read back the contract and first action. Reconstruct requirements from original request, inspect diff and raw evidence; run representative counterexamples and comparative playtest.
Write only the card's authorized paths and REPORT_FILE. Record commands, actual results,
artifacts, counterexamples and remaining uncertainty. Exit only when: PASS or explicit CONDITIONAL/BLOCKED with defects. No completion claim from assertion count.
Otherwise report CONDITIONAL or BLOCKED with a resumable escalation packet.
```

# 11. Verification

| Check | Why | Status | Proves | Does not prove |
|---|---|---|---|---|
| Source inspection | Establish implementation coverage | Completed | Current source representations | Runtime or perceptual quality |
| Fresh runtime and comparative trials | Establish quality | Pending | No current result | Acceptance remains conditional |

Baseline commands, executed from TARGET_WORKTREE after verifying the Godot bootstrap/version:

```sh
bash tools/godot.sh --headless --path . --script tests/run.gd
bash tools/godot.sh --headless --path . --script tests/practice_flow.gd
bash tools/godot.sh --headless --path . --script tests/quality_contract.gd
bash tools/run_native_tests.sh
bash tools/godot.sh --path . --script tests/capture_preview.gd
bash tools/godot.sh --path . --script tests/capture_preview.gd -- --overhead
```

The quality suite is intentionally red on the historical baseline. Native checks validate only the experimental implementation. Do not auto-replace the pinned engine when unavailable; resolve provenance/version compatibility first. Future fixture and profiling commands must be added when implemented, not invented now.

Current verification: source inspection completed; runtime, visual inspection, listening and competitor sessions not executed in this assessment. Prior QA results remain historical. Workflow validators check document structure, not scientific validity or gameplay.

Done requires requirement-by-requirement actual evidence, current runtime tests, shared-geometry inspection, calibrated/held-out physical results, target-device profiles, visual and listening review, comparative sessions and independent acceptance. If physical capture is unavailable, label the result analytically validated but uncalibrated; do not claim realism parity. If preferences conflict, present concrete clips and tradeoffs to the owner.

State transition: INTAKE -> PLANNED, 2026-10-30. Implementation remains pending. Do not add match features until this milestone is accepted.

# 14. Closeout
Planning delivered; execution conditional on prerequisite evidence.

# Excellence contract amendment — revision 2

Owner clarification on 2026-10-30 raises the goal beyond defect repair to fine-grained physical, numerical, interaction and perceptual excellence. Preserve all prior work. Read EXCELLENCE_EXPLORATION.md for the expanded quality model and EXCELLENCE_GATES.md for E0–E9 prerequisites and research prompts. Existing S cards remain the implementation spine; E gates extend their acceptance. Do not call the milestone complete solely because historical defects are fixed.

Status remains conditional: current source exploration is evidence; proposed precision/perception targets are not measured results. No gameplay implementation is performed by this amendment.

## Verification record

| Check | Status | Proves | Does not prove |
|---|---|---|---|
| Current strike, guide, HUD, spin pad, cloth and audio source inspection | Completed | Current representations and cross-system omissions described in excellence exploration | Perceived severity or runtime correctness |
| Primary-source discovery for spin/cloth and render timing | Completed | Research entry points and distinct mechanisms | Calibration or commercial parity |
| Fresh gameplay, visual, listening and comparative trials | Pending | Nothing yet | All experience-level acceptance remains conditional |

# Active bounded checkpoint: S5a — deliberate aim retention

Owner authorization: implement one small-to-medium checkpoint using Luna workers, then stop. This is a narrow prerequisite improvement, not approval of the full excellence milestone.

Baseline HEAD: 5788954d8b6c9111177888a04b529400c86ac926. Existing untracked docs/quality-roadmap belongs to prior planning and must be preserved.

Implementation worker: gpt-6-luna, high effort; owns game_controller.gd, game_hud.gd and README.md. Independent tests/review worker: gpt-6-luna, high effort; owns tests/aim_controls.gd and aim-review report. Parent owns integration, checks and checkpoint report. Models explicitly selected by user; available through current agent harness.

Contract: left press on cloth begins deliberate aim; held drag adjusts; release anywhere retains. UI-origin and unpressed motion cannot aim. Placement, menu, focus loss, shot, camera, undo and rack transitions cannot leave a sticky gesture. Preserve keyboard fine aim while idle. Update instructions. No power curve, physics or art changes.

Verification: focused aim tests including GUI routing, existing physics/rules and practice-flow regressions, and existing quality contract. Only CTL-LOCK is expected to turn green in that intentionally red suite; remaining failures stay explicit. Stop after this checkpoint, even if follow-up defects remain.

## S5a closeout — 2026-10-31

Implemented; focused input suite passes, CTL-LOCK repaired, 949 simulation/rules and 41 practice assertions pass. Existing PNG-write test error and three unrelated quality failures remain. See reports/aim-review.md for evidence and review limitations. Stop: no next checkpoint begun.

# Continuation authorization — 2026-10-31

The owner explicitly resumed the remaining work. The prior stop-after-S5a directive is superseded. Current execution remains checkpointed: S5b soft-touch mapping and cue-contact synchronization, S11a settled-save validation, and S4/S7 numerical evidence. These are bounded improvements and evidence collection; missing human/physical/competitive validation does not become implicitly passed.

Lead readback: preserve working aim changes; do not retune friction to compensate for controls. Power worker owns StrokePower, HUD power sections and power tests. Save worker owns controller serialization sections and save tests. Physics evidence worker owns only a measurement harness/reports. Parent owns cue presentation, controller stroke sections, integration, verification and canonical state. No overlapping source writers.

S5b frozen contract: zero does not fire; full input preserves 8m/s cue speed; smallest nonzero slider step yields 2–10cm center-shot travel on existing cloth. Use a monotone product mapping, measure dense low-end and 21-point curve. Contact occurs when visible tip reaches the selected contact point; actual impulse/audio execute in that contact callback with captured shot parameters. Menu/reset/focus cancel pending strokes. Numerical tests cannot certify felt latency.

S11a contract: accept valid settled v1 saves, reject moving/malformed snapshots without mutating live state; pending-shot snapshot/counters remain consistent. S4/S7 probes are reports, not a physical realism certification.

## S6a shared geometry contract — 2026-10-31

Evidence: official WPA equipment spec section9 (https://wpapool.com/wp-content/uploads/2024/01/RECOMMENDED-EQUIPMENT-SPECIFICATIONS.pdf) gives corner shelf .0254–.05715m, side shelf0–.009525m, horizontal cut142deg corner/104deg side. Selected preset .035m/.006m; these are sourced-range product defaults, not physical calibration. Preserve existing mouth sizes.

Power worker now owns TableSpec geometry and table_geometry tests only. Parent owns physics support/descent and cloth/well render integration. Scope: six finite jaws/mouth/shelf/back definitions feed both renderer and collision. Cloth outline includes supported shelf and is triangulated into actual surface; wells have recessed bottom/lining. Partial descent retains collisions; irreversible capture/event only below slate. Gravity begins on support loss with no artificial downward speed. No native migration or coefficient retuning. Existing tests with old early-capture assumptions must be corrected to support-loss/capture events without loosening assertions.

Accepted limitation: finite flat slate edge and constant jaw response remain provisional; calibrated facing/back-draft/compliance and real rattles cannot be declared complete. Measure all six support boundaries, descent, re-entry, one event, mirror behavior and shared mesh coordinates.

## S5c relative tip adjustment — 2026-10-31

Add Shift-drag at one-fifth pointer gain and double-click center to the existing spin pad; retain ordinary absolute selection and physical .5R bound. This addresses fine input resolution while preserving global aim shortcuts. Verify reduced adjustment, no initial jump on Shift press, center reset and range clamp. The chosen gain is a product default awaiting human precision trials, not a measured optimum.

# Continuation state — 2026-10-31

S5b control/contact, S5c fine tip input, S11a recovery and S6a shared support geometry implemented with focused checks. Full excellence remains conditional. reports/continuation-progress.md owns the current evidence summary; NEXT_CHECKPOINT.md defines the next numerical gate. Original S/E cards remain authoritative for remaining physical/perceptual acceptance.

Luna worker credit exhaustion interrupted final delegated review; parent completed verification and preserved that independence limitation. Original four quality checks passing does not close S1/S2 calibration, S7 solver qualification, S9 full art, S10 listening, S11 release pacing, or S12 comparative perception.

## Current local artifact and next action

0.3.0 app/DMG built and signature/startup verified; source tests and the completed matrix pass within their stated scope. Source/artifact hashes: reports/candidate-manifest.json. Motion: captures/quality-motion.mp4 (30.5s, fixed-FPS source evidence). S7b impact prototype is staged in tests/experiments and not active in the exported game. Its highest-resolution corpus passes the frozen target;7 coarser comparisons remain outside it. Follow NEXT_CHECKPOINT.md and preserve all failed rows.

Do not mark the full game quality objective complete. The owner requested continuation; no permanent stop or pause is inferred. Native/installed interaction, measurement/calibration, independent numerical review and comparative perception are still required.

# Focused competitor observation — owner authorization 2026-10-31

The owner requested four dedicated observers and a commit/push after research. COMPETITOR_REVIEW.md consolidates separate reports for interaction, precise controls, visuals/sound and physics. Evidence comes from actual first-party animated gameplay and official control imagery plus explicitly labeled documentation; live entry remained at a splash/login screen, and audio remains unobserved. No coefficient matching or competitor-quality signoff follows from this material. Add the proposed comparative tasks to E3/E4/E6/E7/E8 before adopting design alternatives. This turn publishes the existing implementation and these authored findings; third-party media are not repository assets.
