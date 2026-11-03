---
name: verify-before-done
description: Treating done as evidence rather than belief - capturing a baseline before changes, running the narrowest relevant build, lint, and test checks, exercising the changed behaviour directly, inspecting the diff, finding leftover debug and temp files, confirming claims against reality, handling flaky checks, checking UI changes visually, and reporting verified versus not verified honestly. Load when about to declare a task complete, mark a step done, summarise results, or hand work back to the user.
---

# Verify before done

Pairs with `test-discipline` for assertion quality and `task-decomposition` for per-step exit checks.

## Done means evidence
- "Should work" is not done. Done is a command you ran, with output you read, that matches the goal.
- Never mark a step or task done when a relevant check fails or was not run. Say so instead.
- Check what you claim, not what you remember: if you say a file exists, list it; if you say a test passes, you saw it pass this session after your last edit.

## Baseline first
- Before editing, run the relevant checks once to learn what is already red. Record it: "3 tests failing before my change: A, B, C."
- Without a baseline you cannot tell your breakage from existing breakage, and you will either blame yourself or excuse real regressions.
- Do not fix unrelated pre-existing failures; report them.

## Run the narrowest checks that cover the change
Order, cheapest first:
1. Typecheck or compile the touched module.
2. Lint or format check on touched files.
3. Targeted tests: the new test, then the file or package containing it.
4. Wider suite only if the change crosses module boundaries or targeted results are suspicious.

```
# example shape, adapt to the project's own tooling
<build-cmd> <touched-module>
<lint-cmd> <touched-files>
<test-cmd> <path-or-name-filter>
```
- Use the project's existing commands; find them in docs, scripts, or CI config before inventing any.
- A passing test that never ran your code proves nothing. Break the behaviour on purpose once, or confirm the test fails without your change.

## Exercise the behaviour
- Run the thing: call the function, hit the endpoint, run the CLI with a real input, open the page. Tests passing is necessary, not sufficient.
- Try one edge case and one failure path (empty input, missing file, bad argument).
- For UI: load it, look at the rendered result, check the changed state and one neighbouring screen. Compile success says nothing about layout. If you cannot see it, say so.

## Inspect the diff
- Read your full diff as a reviewer would, every hunk.
- Look for: debug prints, commented-out code, TODOs you added, stray formatting churn, unrelated edits, accidental file mode or lockfile changes.
- Check untracked files: scratch scripts, logs, output dumps, temp directories. Remove what you created; keep only what the task needs.
- No secrets in the diff (`secret-handling`).

## Flaky checks
- Rerun a failing check once. If it flips, it is flaky: note it, run it 3 times, and report the rate. Do not mark it passing on one lucky run.
- Never disable, skip, or loosen a test to get green unless the user asked.
- If a failure moved after your change, treat it as yours until proven otherwise.

## Final report format
State two things plainly:

```
Verified:     build ok; 14 targeted tests pass; ran CLI with sample input, output matches
Not verified: full suite (too slow); Windows path handling; UI in Safari
Known issues: test X failed before my change (unrelated)
```
- Never write "all tests pass" if you ran a subset. Name the subset.
- Unverified is acceptable; unverified presented as verified is not.

## Anti-patterns
- Declaring done from reading code alone.
- Running checks before the last edit, then editing again.
- Trusting a sub-agent's "all green" without rerunning (`delegation-briefs`).
- Greening a build by deleting or skipping the failing test.

## Checklist
- Baseline recorded before the change.
- Build, lint, targeted tests run after the final edit.
- Behaviour exercised directly, with an edge case.
- Diff and untracked files reviewed and cleaned.
- Report separates verified from not verified.
