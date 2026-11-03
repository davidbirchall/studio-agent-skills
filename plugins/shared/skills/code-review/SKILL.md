---
name: code-review
description: Technology-neutral code review practice - reviewing for correctness, design, tests, security, and readability; keeping changes small; self-review with a checklist after a cooling-off period, using an AI assistant as a second reviewer, change descriptions, comment severity labels (blocking, suggestion, nit), automation versus human focus, extra scrutiny for AI-generated code, and what not to review. Load when finishing a change, reviewing your own or AI-generated code, or deciding how a solo developer reviews work.
---

# Code Review

Builds on `software-testing-strategy` and `application-security`. Use `test-discipline` to judge test quality and `technical-documentation` for docs changes. Frontend, backend, AI, and game plugins add stack-specific checks.

## Purpose
- Catch defects and design problems early, share knowledge, and keep the codebase consistent.
- Review the change against its intent, not against how you would have written it.

## Solo review approach
- You are the author and the reviewer, so build in distance: re-read the diff cold in a fresh pass (ideally a fresh AI session with only the diff and intent) as if someone else wrote it.
- Use an AI assistant as a second reviewer: give it the diff, the intent, and the checklist below, and ask for bugs, missing tests, and risks. Treat its findings as leads to verify, not verdicts.
- Keep changes small and single-purpose; split refactors from behaviour changes.
- Make CI green first. Do not spend review attention on lint or build failures.
- Record a description (commit message or change note) that answers: what, why, how to verify, risks, and linked issue.
- If others review your work: re-check only the delta after changes.

```
## What / Why
Short summary and link to the issue.
## How verified
Tests added, manual steps, screenshots.
## Risk / rollout
Migrations, flags, rollback plan.
```

## Review checklist
- Correctness: does it do what the issue asks? Edge cases, null and empty input, errors, concurrency, off-by-one.
- Design: fits existing architecture, right layer, no needless abstraction or duplication (`software-architecture`).
- Tests: cover new behaviour and failure paths, fail when the code is broken, no flaky timing.
- Security: input validation, authorisation, secrets, injection (`application-security`).
- Performance: obvious N+1, unbounded loops or memory, hot-path cost.
- Readability: names, structure, comments explaining why, not what.
- Operations: logging, metrics, config, migrations, backward compatibility.
- Read tests first, then the code; check what is missing as well as what is present.

## Comments
- Label severity in your review notes (or the AI's) so you know what blocks:
  - blocking: must change before merge (bug, security, broken contract).
  - suggestion: worth considering; you decide.
  - nit: minor taste; ignorable.
  - question: something you do not understand yet; answer it before merging.
- Explain the reason and note an alternative. Ask rather than assume ("What happens if this is null?").
- When you disagree with an AI finding, settle it by data (run it, test it) or principle; record the call in a decision log if it is design-level.

## Automation versus humans
- Formatters, linters, type checks, and static analysis handle style and common bugs. Do not comment on what tooling enforces.
- Your own review focuses on intent, design, risk, and missing tests.

## Process
- Do not merge with unresolved blocking items.
- Self-approve only after the checklist is complete and CI is green; do not skip it because the change is small.
- Re-check the delta after fixing review findings, not the whole diff.

## AI-generated code
- Review as if written by an unfamiliar contributor with no context. You remain fully accountable for every line.
- Verify that APIs, packages, and options actually exist. Check for invented functions and outdated usage.
- Look for plausible but wrong logic, over-broad changes, deleted tests, weakened assertions, and copied insecure patterns.
- Be able to explain the code in your own words and show it running. Run it, do not just read it.
- Check licensing and dependency additions (`dependency-management`).

## Do not review
- Formatting, import order, and naming rules already enforced by tools.
- Generated files, lockfile noise, and vendored code beyond a sanity check.
- Personal preference with no stated benefit.
