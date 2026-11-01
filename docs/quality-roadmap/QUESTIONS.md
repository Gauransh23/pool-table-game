# Investigation questions

Priority questions, each requiring a report before dependent implementation:

1. What is the earliest observable divergence in pocket entry: visual mouth, support boundary, jaw contact or capture? Resolver: physics investigator; inspect shared geometry and boundary fixtures. Decision: support/capture model. Falsifier: a source-consistent fixture showing valid support after current capture.
2. How much of perceived bad physics is control mapping? Resolver: controls investigator; compare retained-aim and low-power experiments while holding physics fixed. Decision: control repair scope. Falsifier: dissatisfaction persists with identical shot inputs and corrected controls.
3. Which collision families fail convergence or depend on storage order? Resolver: numerical specialist; refined timestep and permutation sweeps. Decision: local solver repair versus migration. Do not choose a rewrite from code appearance.
4. What reference table and measured uncertainty define realism? Resolver: research lead; primary literature and measured trajectories. External-data dependent. Blocks claims of calibrated realism, not analytic validation.
5. Which visual defects dominate at gameplay scale? Resolver: presentation researcher; native-scale captures and identity tasks. Decision: geometry, readability, lighting or material investment. Falsifier: matched tests show the suspected defect is not perceptible.
6. What minimum hardware and input platform are we targeting? Resolver: lead with owner preference if needed; baseline measurements and product context. Decision: performance budgets and interaction affordances. Do not silently inherit high-end hardware results.
7. Do historical save/aim/soft-shot failures reproduce at current HEAD? Resolver: baseline executor; quality contract plus real input. Decision: retain or update diagnosis with evidence.
8. What does each comparator do better, and is the advantage physical, perceptual or interaction design? Resolver: competitive researcher; matched tasks, not trailers. Decision: bounded improvement targets. Access limitations remain explicit.
9. Is native migration necessary after measured runtime repair? Resolver: strong reviewer; shared-fixture parity, performance and build costs. Decision: architecture. Passing isolated native sweeps is insufficient.
10. Which proposed targets are stricter than data support? Resolver: lead/reviewer; uncertainty budget and measurement feasibility. Decision: freeze meaningful tolerances before implementation.

Non-priority: match rules integration, multiplayer determinism, AI shot planning and additional platforms are later milestones.

Stop/re-plan when a presumed oracle disagrees with independent measurements, unavailable hardware prevents a claimed gate, or product preference changes physical semantics. Do not substitute agent confidence for evidence.
