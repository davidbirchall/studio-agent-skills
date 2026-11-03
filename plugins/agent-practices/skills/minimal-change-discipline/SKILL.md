---
name: minimal-change-discipline
description: Making the smallest change that fully solves the problem - no drive-by refactors, matching local conventions, noting but not fixing unrelated issues, avoiding new dependencies, preserving behaviour with tests, keeping diffs reviewable, deleting only code your change orphaned, protecting public API stability, and isolating a larger refactor when it is truly justified. Load when editing existing code, tempted to clean up nearby code, adding a dependency, or changing a shared interface.
---

# Minimal change discipline

"Minimal" means smallest change that fully solves the problem, not smallest that looks done. A partial fix is not minimal; it is incomplete. Pair with `verify-before-done` and `task-decomposition`.

## Size the change
- Solve the stated problem and its tightly coupled consequences (callers, tests, docs of the thing you changed). Stop there.
- Target: every changed line traces to the request. If you cannot explain a hunk in one sentence tied to the goal, revert it.
- Rule of thumb: a reviewer should grasp the diff in under 10 minutes. Over ~300 changed lines or ~10 files, split it (`task-decomposition`).

## No drive-by edits
- Do not rename, reformat, reorder imports, or restructure code you were not asked to change.
- Do not run a formatter over whole files if it rewrites untouched lines. Format only your hunks, or confirm the formatter is already clean first.
- Do not upgrade dependencies, change config, or tweak build settings along the way.

## Match local conventions
- Read two or three neighbouring files before writing. Copy their naming, error handling, structure, test style, and comment density.
- Your preference loses to the codebase's habit, even when yours is better. Raise it as a note, not a change.
- Use existing helpers instead of writing parallel ones. Search for one before adding any.

## Unrelated issues: note, do not fix
- Bug, smell, outdated comment, failing test unrelated to the goal: record one line (file, issue, why it matters) and move on.
- Exception: fix it when the goal cannot work without it. Say so in the report.
- Report the parked list at the end so the user decides.

```
Noticed, not changed:
- src/parse.ext:88 swallows errors silently (may hide bad input)
- tests/io_test.ext flaky on slow disks
```

## Dependencies
- Default answer is no. Use the standard library or what the project already has.
- Add one only when it removes substantial code or risk, is maintained, and fits the licence and size budget. State why in the report.
- Never add a dependency for a few lines of code.

## Preserve behaviour
- Before touching existing logic, confirm a test covers it; if none, write a characterisation test of current behaviour first, then change.
- After the change, existing tests pass unmodified. Editing an old test to fit your change is a signal you altered behaviour; justify it explicitly.

## Dead code
- Delete code only if your change made it dead (unused import, function, variable, config you orphaned).
- Pre-existing dead code stays; list it as a note.

## Public interfaces
- Treat exported functions, CLI flags, config keys, file formats, and wire schemas as contracts. Change them additively: add, deprecate, then remove later.
- A breaking change needs an explicit decision from the user (`ask-vs-assume`).

## When a bigger refactor is justified
- When the minimal change would need a hack that makes the code measurably worse, or the same defect exists in several places because of one structural flaw.
- Isolate it: separate commit or branch, behaviour-preserving only, tests green before and after, no feature change mixed in. Do the refactor first, the feature second.
- Get agreement before starting if it touches more than the files the task named.

## Anti-patterns
- "While I'm here" cleanups.
- Reformatting a file and burying a 3-line fix in 400 lines of churn.
- Rewriting working code because you would have written it differently.
- New abstraction for a single caller.

## Checklist
- Every hunk maps to the request.
- Conventions and existing helpers reused.
- No new dependency, or one justified.
- Unrelated findings listed, not fixed.
- Existing tests unchanged and passing.
- Public interfaces compatible.
