---
name: refactor-safely
description: Recipe for restructuring code without changing behaviour - establish a behavioural safety net first, write characterisation tests where coverage is thin, work in small reversible steps, keep one kind of change per commit, keep tests green at every step, never mix behaviour changes into a refactor, measure when performance is the motive, apply stop criteria, and know how to roll back. Names the skills to apply at each step, the exit check, and what to hand forward. Load when asked to refactor, restructure, rename, extract, simplify, or clean up existing code.
---

# Refactor safely

An ordered recipe, not a reference. Each named skill is optional: if its plugin is not installed, do the step anyway using general good practice. Do not copy skill content here; apply the skill and record only the output.

## When to use / when not to
- Use when the goal is better structure, naming, or duplication removal while behaviour stays identical.
- Not for fixing a bug (use fix-a-bug), adding a feature, or a dependency upgrade (use upgrade-dependencies). If behaviour must change, do that as a separate change.

## Steps
1. Define the goal and the boundary.
   - Goal: a named structural outcome and a limited area.
   - Apply: task-decomposition (agent-practices plugin), minimal-change-discipline (agent-practices plugin), software-architecture (shared plugin).
   - Exit: two or three lines stating what gets better, which files are in scope, and what is explicitly out. Ask the user one question only if the goal could mean two very different designs. Hand on: the scope note.
2. Establish a safety net.
   - Goal: a fast check that fails if behaviour changes.
   - Apply: software-testing-strategy (shared plugin), backend-testing or frontend-testing as relevant.
   - Exit: existing tests run green and cover the area; the baseline command and result are recorded. Hand on: the baseline.
3. Add characterisation tests.
   - Goal: pin down current behaviour where coverage is thin, including odd behaviour.
   - Apply: software-testing-strategy (shared plugin), debugging (shared plugin) for exploring actual outputs.
   - Exit: tests assert what the code does today at its public edges, not its internals; they pass on untouched code. Hand on: the tests, committed separately.
4. Measure first if performance-motivated.
   - Goal: evidence that the change is needed and later that it helped.
   - Apply: performance-engineering (shared plugin), game-profiling when relevant.
   - Exit: a baseline number under a repeatable benchmark. If the motive is not performance, skip. Hand on: the baseline.
5. Refactor in small reversible steps.
   - Goal: each step is tiny, understood, and undoable.
   - Apply: minimal-change-discipline (agent-practices plugin), git-workflows (platform-engineering plugin), typescript-conventions (shared plugin) where relevant.
   - Exit: after each step the tests, type-check, and lint pass; one kind of change per commit (rename, move, extract, or inline, never two at once). Prefer tool-driven renames over manual edits. Hand on: a commit per step.
6. Keep behaviour changes out.
   - Goal: preserve review clarity and rollback value.
   - Apply: code-review (shared plugin).
   - Exit: any bug or improvement noticed along the way is written to a notes list and left unfixed; a failing safety-net test means revert the last step, not edit the test. Hand on: the noticed-items list.
7. Verify and compare.
   - Goal: prove equivalence.
   - Apply: verify-before-done (agent-practices plugin), performance-engineering (shared plugin) if step 4 applied.
   - Exit: full suite, type-check, lint, and build pass; the benchmark is re-run against the baseline; public interfaces and exports are unchanged unless declared in step 1.
8. Stop and record.
   - Goal: end on purpose.
   - Apply: technical-documentation (shared plugin), session-handoff (agent-practices plugin).
   - Exit: stop criteria met (see below); notes record what changed, what was deliberately left, and the follow-up list.

## Skip rules
- Rename within one file with full type-checker support: skip step 3; keep step 2.
- Code with no tests and high risk: do step 3 fully before any change; do not proceed without it.
- Purely mechanical formatter or codemod run: commit it alone, after tests pass before and after.
- Never skip the safety net or mix behaviour change into the commits.

## Rollback and stop criteria
- Rollback: each step is its own commit, so revert the last commit; if several steps went wrong, reset to the baseline commit.
- Stop when the stated goal is met, when remaining ideas are speculative, or when a step needs a behaviour change. Log the rest instead.

## Common failure modes
- Refactoring with no tests, then discovering a subtle change in production.
- Editing a failing test to make it green.
- A giant commit that mixes renames, moves, and logic edits.
- Scope creep into neighbouring modules.
- Optimising without a before measurement.

## Checklist
- [ ] Goal and scope written.
- [ ] Baseline green and recorded.
- [ ] Characterisation tests added where thin.
- [ ] Steps small, one change type per commit.
- [ ] Tests green after every step.
- [ ] No behaviour change included.
- [ ] Performance compared to baseline if relevant.
- [ ] Follow-ups and notes saved.
