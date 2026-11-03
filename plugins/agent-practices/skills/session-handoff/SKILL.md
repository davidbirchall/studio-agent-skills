---
name: session-handoff
description: Writing durable handoff notes so a later AI session can resume work cold - what a note contains (goal, current state, decisions and why, files touched, verification commands, next steps, open questions, gotchas), where to store it, when to write it, keeping it short and current by replacing rather than appending, pruning, and a resuming checklist that verifies the note against git and re-runs checks. Load when context is filling up, stopping mid-task, finishing a work session, or starting a session that may continue earlier work.
---

# Session handoff

The next session starts with zero memory. Anything not written down is lost; anything written down stale is worse than nothing. Pair with `ask-vs-assume` (recording decisions) and `task-decomposition` (next steps).

## When to write
- Before context fills: at roughly 70% of the window, or before any long-running step.
- At every natural stopping point: a step finished, a check passing, a blocker hit.
- Right after a decision that shaped the work (record it while the reasoning is fresh).
- Before handing work to another agent or ending the session. Never rely on "I will remember".

## Where to store
- Prefer a notes file in the repo if the project has one or the user wants it committed; otherwise the session's own state or scratch folder outside the tracked tree.
- One well-known path per task or branch, e.g. `notes/<task-slug>.md`. Never several competing notes.
- Never write secrets, tokens, or personal data into notes (`secret-handling`).
- Do not leave notes in a place that gets committed by accident. Check `git status`.

## What it contains
Keep to these headings, in this order:

```
# <task slug> - handoff
Updated: <date/time>  Branch: <branch>  Commit: <short sha>

## Goal
One or two sentences and the finish line check.

## State
Done: ... | In progress: ... | Not started: ...

## Decisions (with why)
- Chose X over Y because Z.

## Files touched
- path - what changed and why

## Verify
- <command> -> expected result

## Next steps
1. concrete action with its exit check

## Open questions
- question + my recommendation

## Gotchas
- non-obvious traps, failed approaches, env quirks
```

## Quality rules
- Write for a reader who knows the repo but not this task. Concrete paths, exact commands, exact errors.
- Record failed approaches and why they failed; that saves the most time.
- Distinguish facts you checked from beliefs. Mark guesses as guesses.
- Next steps must be the very next actions, not a restated plan. First step runnable in under a minute.
- Under about 60 lines. If longer, the task needs splitting or the note needs pruning.

## Keep it current
- Replace, do not append forever. Rewrite State and Next steps each time; delete finished items.
- Move settled decisions to the project's decision log if one exists, and leave a pointer.
- Remove gotchas once fixed. When the task ends, delete the note or archive it with the final outcome.
- A note whose Updated line is stale relative to git history is suspect; say so when resuming.

## Resuming checklist
1. Read the note fully before touching anything.
2. Compare to reality: `git status`, `git log` since the noted commit, `git diff`. Note differences.
3. Check listed files exist and contain what the note says.
4. Re-run the Verify commands; record the baseline.
5. Resolve open questions from notes and docs before asking (`ask-vs-assume`).
6. Update the note first (Updated line, corrections), then continue from Next steps.

## Anti-patterns
- A chronological diary of everything attempted.
- "Continue the work" with no state or next action.
- Notes that disagree with the repo and are trusted anyway.
- Pasting large logs or diffs instead of pointers.
- Writing the note only at the very end, after context is gone.

## Checklist
- Written before context ran out.
- Goal, state, decisions, files, verify, next, questions, gotchas present.
- Under ~60 lines; finished items removed.
- No secrets; stored at one known path.
- Resumer verifies against git before trusting it.
