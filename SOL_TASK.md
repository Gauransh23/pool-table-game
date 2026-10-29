# Start here: quality recovery

Implement [the Sol quality contract](docs/quality/SOL_HANDOFF.md).
Read [the measured baseline](docs/quality/BASELINE.md) first.

The owner rejected preview 0.2.0. Its "polished" descriptions are not acceptance.
Prioritize practice-table controls, physical consistency, visual fidelity and sound.
No feature expansion until the quality gates pass. The new quality contract test is
intentionally red on the baseline; keep existing regression tests separate.

Run:

```sh
bash tools/godot.sh --headless --path . --script tests/quality_contract.gd
bash tools/godot.sh --headless --path . --script tests/run.gd
bash tools/godot.sh --headless --path . --script tests/practice_flow.gd
```

Deliver measured improvements and an installable Mac candidate with comparison
captures and actual listening/interaction review. Owner perceptual acceptance is a
separate pending gate, not something the implementation agent can declare for them.
