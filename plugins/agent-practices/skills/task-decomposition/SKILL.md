---
name: task-decomposition
description: Breaking work into small, independently verifiable steps - when to decompose, vertical slices over horizontal layers, exit checks per step, ordering by risk and unknowns, commit-sized step limits, recording dependencies, tracking steps in a todo list, re-planning triggers, stop conditions, and parking discovered extra work instead of expanding scope. Load when a task touches more than about three files, has an unclear path, has several sequential steps, or feels too big to hold in one pass.
---

# Task decomposition

Pair with `verify-before-done` for the exit checks and `minimal-change-discipline` for scope control. Use `delegation-briefs` when a step is handed to another agent.

## When to decompose
- Decompose when any is true: more than ~3 files change, the path to the goal is unclear, there are 3+ sequential steps, or you cannot state the finish line in one sentence.
- Do not decompose a one-file fix or a single obvious command. A plan longer than the change is waste.
- Write the goal and the finish line first: "Done when `X` passes and `Y` behaves like Z."

## Slice vertically
- Each step delivers a thin end-to-end behaviour, not a layer. Bad: "add model", "add API", "add UI". Good: "create item (model + API + minimal UI)", then "edit item", then "delete item".
- A step must leave the build green and the tree committable. If it cannot, it is too big or mis-cut.
- Tiny scaffolding steps (rename, move, add test harness) are fine when they unblock a slice and change no behaviour.

## One step, one exit check
- Every step names a concrete check that proves it: a command, a test, an observable output.
- No exit check means no step. Rewrite it until you can state one.
- Size limit: one step is one commit-sized change, roughly under 150 changed lines or one reason to revert. Split anything larger.

```
[ ] 1. Reproduce bug in failing test   -> check: test fails with expected message
[ ] 2. Fix parser edge case            -> check: new test passes, suite green
[ ] 3. Update docs example             -> check: example runs as written
```

## Order by risk
- Do unknowns first: unfamiliar API, unclear data shape, performance doubt, anything that could invalidate the plan. A 20-minute spike now beats a rewrite later.
- Then the thinnest end-to-end path, then breadth, then polish.
- If the riskiest step fails, stop and re-plan before building on it.

## Record dependencies
- Note which step truly needs which. Do not infer order from list position; independent steps stay independent and can be delegated or reordered.
- Track in the available todo or task tool with stable ids and statuses (pending, in progress, done, blocked). Keep exactly one step in progress.
- Mark done only after the exit check ran (`verify-before-done`). Mark blocked with the reason.

## Re-plan triggers
- A step takes more than ~2x its expected effort.
- An assumption proves false (API differs, file missing, tests already red).
- Two steps now need to be edited together.
- You discover the goal itself was misread.
On a trigger: pause, state what changed in one or two lines, rewrite the remaining steps, continue. Do not silently drift.

## Discovered work
- New findings (a bug, a cleanup, a missing test) go to a parked list, not into the current step.
- Park format: one line with location and why it matters. Report the list at the end.
- Pull a parked item in only if the current goal cannot be met without it; then add it as an explicit step.

## Stop conditions
- Stop when the finish line check passes and the diff holds only planned steps.
- Stop and ask (`ask-vs-assume`) when a step needs an irreversible action, a decision only the user can make, or two re-plans in a row failed.
- Do not keep going because more could be improved.

## Anti-patterns
- Layer-by-layer plans where nothing works until the last step.
- Steps phrased as activities ("investigate auth") with no deliverable or check.
- A 15-item plan for a 3-item change.
- Plan written once, never revisited after reality diverged.
- Marking several steps done in one batch at the end.

## Checklist
- Finish line stated in one sentence.
- Each step is a vertical slice with an exit check.
- Risky unknowns scheduled first.
- Steps commit-sized; dependencies recorded.
- One step in progress at a time.
- Extra findings parked, not absorbed.
- Re-planned when a trigger fired.
