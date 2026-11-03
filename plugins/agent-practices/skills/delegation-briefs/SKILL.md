---
name: delegation-briefs
description: Briefing sub-agents and other AI agents so they succeed - complete self-contained context, objective with a stop condition, constraints and conventions, exact paths, required output format, built-in verification, explicit exclusions, scope bounds, parallelising independent work without conflicting edits, skipping delegation for small jobs, validating returned work instead of trusting summaries, and capping iteration cycles. Load when about to spawn a sub-agent, hand a task to another AI, split work across parallel agents, or review what a delegate returned.
---

# Delegation briefs

A delegate has none of your context: not the conversation, not what you learned, not what the user wants. Whatever is not in the brief does not exist. You remain responsible for the result. Pair with `task-decomposition` and `verify-before-done`.

## Whether to delegate
- Do not delegate what you can finish in about 3-5 direct tool calls; briefing costs more than doing.
- Delegate when work is large, verbose (long test runs, broad searches), independent of your next step, or benefits from a clean context.
- Never delegate a single continuous trace where each step depends on the last. Never delegate the decision, only the legwork.

## What every brief contains
1. Objective: the outcome wanted and why (one or two sentences). The why lets the delegate make good local choices.
2. Context: facts you already know, what you tried, what is already ruled out. Paste the relevant excerpts; do not say "see above".
3. Exact scope: absolute or repo-relative paths, symbols, commands. Say which files it may edit and which it must not touch.
4. Constraints: conventions to match, tools to use or avoid, no new dependencies, no network, no secrets (`secret-handling`).
5. Stop condition: what "done" is, measurable. Without it, delegates stop early or never.
6. Verification it must run before reporting, with the exact commands.
7. Output format: what to return and how long.
8. Exclusions: what not to do (no refactors, no commits, no unrelated fixes, no asking the user).

```
Objective: Make `parse_config` reject duplicate keys (users silently lose
settings today). Done when the new test passes and the config suite is green.
Context: Parser is in src/config/parse.<ext>; tests in tests/config/. Duplicate
handling currently last-wins. Error type to reuse: ConfigError.
Scope: edit only the two files above. Match existing test style.
Run: <test-cmd> tests/config/ ; report the pass/fail counts.
Return: changed files, one-line summary per file, command output tail,
anything you could not verify. Max 15 lines.
Do not: refactor, rename, add dependencies, or commit.
```

## Parallel work
- Fan out only independent tasks. Two delegates must never edit the same file; partition by file or directory up front.
- Read-only research tasks parallelise freely; writing tasks need disjoint scopes.
- Meanwhile do your own independent work instead of polling.
- After merging parallel results, run the checks once over the combined tree.

## Validate the result
- A summary describes intent, not reality. Open the changed files, read the diff, rerun the key command yourself.
- Check against the stop condition and the exclusions: unrequested edits, deleted tests, loosened assertions, "fixed" by skipping.
- Spot-check claimed facts (file exists, function signature, output) before reusing them.
- Treat "unable to verify" in the report as a task for you, not a pass.

## Iterate, bounded
- If the result misses, send a targeted follow-up naming the specific gap, with the delta only. Maximum about 3 cycles.
- If cycle 2 fails the same way, the brief or the decomposition is the problem. Rewrite it, or do the work directly.
- Do not relaunch an identical brief hoping for a different outcome.

## Sizing the delegate's task
- One brief, one objective. If the return format needs sections for unrelated outcomes, send two briefs.
- Research briefs: ask for evidence (paths, line numbers, quoted output), not conclusions alone.
- Writing briefs: require the delegate to report anything it changed outside scope.

## Anti-patterns
- "Fix the failing tests" with no paths, no context, no stop.
- Assuming the delegate saw the conversation.
- Giving a vague goal and accepting a confident summary.
- Parallel agents editing the same file.
- Delegating to avoid thinking about the design.

## Checklist
- Cheaper to brief than to do? If not, do it.
- Objective, context, scope, constraints, stop, verification, format, exclusions all present.
- Parallel scopes disjoint.
- Result inspected and rechecked by me.
- At most about 3 cycles.
