---
name: debugging
description: Technology-neutral systematic debugging - reproducing first, minimal repros, hypothesis-driven investigation, bisecting history and inputs, reading errors and stack traces, checking recent changes, observing with logs, debuggers, and tracing rather than guessing, isolating variables, fixing root causes, regression tests, documenting findings, time-boxing and escalation, heisenbugs and race conditions, and debugging production safely. Load when investigating a bug, failing test, crash, flaky behaviour, or production incident.
---

# Debugging

Builds on `software-testing-strategy` and `test-discipline`. Use `performance-engineering` for slowness and `application-security` for safe handling of sensitive data in logs. Frontend, backend, AI, and game plugins add runtime-specific tooling.

## Reproduce first
- Get a reliable reproduction before changing anything. If you cannot reproduce, you cannot confirm a fix.
- Record exact steps, inputs, version, environment, and expected versus actual result.
- Shrink to a minimal repro: remove code, data, and configuration until the bug disappears, then restore the last piece.
- Turn the repro into a failing automated test as early as possible.

## Read the evidence
- Read the full error message and stack trace; the first frame in your code and the root "caused by" matter most.
- Check what changed: recent commits, deploys, config, dependency upgrades, data, flags, and infrastructure.
- Ask what is different between working and failing cases (input, environment, timing, user, data).

## Hypothesis-driven
- State a falsifiable hypothesis, predict what you would observe, then test it. Discard it if wrong.
- Change one variable at a time; revert experiments that did not help.
- Keep a short log of what you tried and learned to avoid repeating work.
- Challenge assumptions: verify that the code you edit is the code that runs (build, cache, branch, environment).

## Observe, do not guess
- Use a debugger, breakpoints, watch expressions, and logging at boundaries to see actual values.
- Add temporary targeted logs or assertions; remove them after. Prefer structured logs with request ids.
- Use tracing and profilers for cross-service or timing issues.
- Print inputs and outputs of the suspect function to bisect where state first becomes wrong.

## Bisect
- History: find the first bad commit with a scripted test.

```
git bisect start
git bisect bad HEAD
git bisect good v1.4.0
git bisect run ./scripts/repro.sh
```

- Inputs: halve the failing data set, or disable half the features, plugins, or code path until the cause is isolated.
- Dependencies: pin and swap versions to see whether the upstream changed.

## Fix the cause
- Ask why until you reach the root cause; a null check that hides bad data is a symptom fix.
- Make the smallest correct change, check for the same defect elsewhere, and keep unrelated refactors out.
- Add a regression test that failed before the fix and passes after.
- Document the finding in the PR or incident notes: symptom, cause, fix, and how it escaped.

## Hard cases
- Heisenbugs: observation changes behaviour. Prefer low-overhead logging, record and replay, and deterministic seeds and clocks.
- Race conditions: look for shared mutable state, missing locks, ordering assumptions, and async gaps. Add delays or stress to widen the window; fix with proper synchronisation or removing sharing, not sleeps.
- Flaky tests: treat as bugs. Check time, ordering, shared state, randomness, and external services.
- Intermittent production failures: add telemetry first, then wait for the next occurrence.

## Production
- Prefer logs, metrics, traces, and read-only queries. Do not attach debuggers or mutate state on live systems.
- Mitigate first (rollback, flag off, scale up), diagnose after.
- Reproduce in staging with sanitised data. Never copy secrets or personal data into tickets or chats (`secret-handling`).

## Time-box and escalate
- Set a limit (for example 60 minutes) before changing approach or asking the user a focused question. Include the repro, what you tried, and your hypotheses.
- Writing the problem out step by step (rubber-duck style) often exposes the faulty assumption.
- When stuck, re-read the error and the code path from scratch, or start a fresh pass with only the repro; simple mistakes surface that way.
