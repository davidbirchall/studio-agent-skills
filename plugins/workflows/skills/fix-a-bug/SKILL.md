---
name: fix-a-bug
description: Recipe for fixing a defect without guessing - reproduce first with a failing test or minimal repro, isolate the failing area, find the root cause rather than the symptom, make the smallest fix, add a regression test, check related call sites, verify end to end, and record the cause in the commit message or notes. Names the skills to apply at each step, the exit check, and what to hand forward. Load when asked to fix a bug, investigate unexpected behaviour, or resolve a failing test or error report.
---

# Fix a bug

An ordered recipe, not a reference. Each named skill is optional: if its plugin is not installed, do the step anyway using general good practice. Do not copy skill content here; apply the skill and record only the output.

## When to use / when not to
- Use when behaviour differs from what the code, spec, or user expects and the cause is not already obvious.
- Not for a typo or one-line obvious slip (see skip rules), a new feature, or a planned restructure (use refactor-safely).

## Steps
1. Reproduce first.
   - Goal: a repeatable failure you can run on demand.
   - Apply: debugging (shared plugin), software-testing-strategy (shared plugin), backend-testing or frontend-testing as relevant.
   - Exit: a failing automated test, or a minimal script with exact inputs and observed versus expected output. If it cannot be reproduced, say so and gather logs instead of guessing. Hand on: the repro.
2. Isolate.
   - Goal: shrink the search area.
   - Apply: debugging (shared plugin), git-workflows (platform-engineering plugin) for bisecting to the commit that broke it.
   - Exit: the failing layer, file, or commit is named, and inputs are reduced to the smallest that still fail. Hand on: the narrowed location.
3. Find the root cause.
   - Goal: explain why it fails, not just where.
   - Apply: debugging (shared plugin), ask-vs-assume (agent-practices plugin) when the intended behaviour is genuinely unclear.
   - Exit: a one-sentence cause you can prove with the repro (a log line, a breakpoint, a changed input). If the explanation is a guess, keep investigating. Hand on: the cause statement.
4. Make the smallest fix.
   - Goal: correct the cause with the least change.
   - Apply: minimal-change-discipline (agent-practices plugin), application-security (shared plugin) if the bug touches input, auth, or data exposure.
   - Exit: the repro now passes; the diff touches only what the cause requires; no drive-by cleanup. Ask the user one question only if two fixes change visible behaviour differently. Hand on: the diff.
5. Add a regression test.
   - Goal: make this bug unable to return silently.
   - Apply: software-testing-strategy (shared plugin), tdd-style red-green order.
   - Exit: the test fails on the old code and passes on the new; it asserts the behaviour, not the implementation. Hand on: the test.
6. Check related call sites.
   - Goal: find the same mistake elsewhere.
   - Apply: code-review (shared plugin), search for the same pattern, helper, or assumption.
   - Exit: each similar site is fixed, covered, or noted as safe with a reason. Hand on: list of sites checked.
7. Verify.
   - Goal: prove nothing else broke.
   - Apply: verify-before-done (agent-practices plugin).
   - Exit: full relevant test suite, type-check, and lint pass; the original repro is run once more by hand or script. Hand on: command output summary.
8. Record the cause.
   - Goal: preserve why, for future sessions.
   - Apply: conventional commits if available, technical-documentation (shared plugin), session-handoff (agent-practices plugin) for unfinished follow-ups.
   - Exit: commit message states symptom, root cause, and fix; a notes entry is added if the cause reveals a recurring trap.

## Skip rules
- Typo, wrong constant, or obvious one-line slip: skip steps 2, 3, and 6; still run the tests.
- Bug in code with no test harness: write the smallest repro script instead of a full test, and note the gap.
- Production incident in progress: mitigate first (revert or flag off), then run this recipe; apply incident-response (shared plugin).
- Never skip step 1 for a non-obvious bug, and never skip step 7.

## Common failure modes
- Fixing the symptom (null guard, retry, catch-all) while the cause remains.
- Changing code before a repro exists, then not knowing if it worked.
- Regression test that passes on the old code.
- Bundling a refactor or formatting pass into the fix, making the diff unreviewable.
- Fixing one call site and leaving the identical bug in three others.
- Declaring done after the targeted test only.
- Asking the user for information the logs or code already contain.

## Checklist
- [ ] Repro exists and failed before the fix.
- [ ] Root cause stated and demonstrated.
- [ ] Fix is minimal and scoped to the cause.
- [ ] Regression test fails without the fix.
- [ ] Related call sites checked.
- [ ] Tests, type-check, and lint pass.
- [ ] Commit or notes record symptom, cause, and fix.
