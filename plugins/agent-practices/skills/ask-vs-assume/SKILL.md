---
name: ask-vs-assume
description: Deciding when to ask the user a question and when to proceed on a stated default - asking only for irreversible actions, materially divergent ambiguity, preferences only the user holds, and secrets, cost, or destructive operations; searching the repo and docs before asking; asking one focused question with a recommendation and options; batching questions; and recording answers as decisions for future sessions. Load when a request is ambiguous, a choice has no obvious answer, an action looks risky or irreversible, or you are tempted to ask something you could look up.
---

# Ask vs assume

The user's attention is the scarcest resource. Every question costs them a context switch; every wrong assumption costs a redo. Pick the cheaper one on purpose. Use `secret-handling` for credentials and `task-decomposition` for stop conditions.

## Ask when
Ask only if at least one is true:
- Irreversible or hard to undo: deleting data, force-pushing, publishing, sending messages, migrations, spending money.
- Ambiguous, and the readings lead to materially different results (different files, architecture, behaviour), not just different style.
- It needs a preference only the user holds: naming they will live with, product behaviour, tradeoffs of taste, which account or environment.
- It touches secrets, credentials, billing, or production systems.
- You have tried two distinct approaches and are still blocked.

## Otherwise assume
- Pick the sensible, conventional, reversible default and keep going.
- State it in one line where the user will see it: "Assuming X because Y; say so if you want Z."
- Prefer the choice that is cheapest to change later.
- If you cannot ask (non-interactive run), choose the safest reversible option, state it, and flag it in the final report.

## Look before asking
Never ask what you can find. Check, in order:
1. The request text again.
2. Repo files: README, docs, config, existing code doing the same thing.
3. Notes, decision logs, and prior session handoffs (`session-handoff`).
4. Project history (`git log`, blame, related changes).
5. Official docs for the installed version.
Asking "which test runner do you use?" when a config file says so is a failure.

## How to ask
One focused question, a recommendation, and bounded options. Make it answerable in one line.

```
The export can include archived items or skip them. This changes the output
file contents. I recommend skipping (matches the list view). Options:
A) skip archived (recommended)  B) include archived  C) flag to choose
```
- Lead with the decision needed, not the backstory.
- Give your recommendation; the default answer should be "yes, that one".
- Say what you will do meanwhile if work can continue on an independent part.
- No open questions like "how should I handle errors?". Offer concrete choices.

## Batch
- Collect questions while working; ask them together at one natural stopping point, ordered by how much they block.
- Exception: ask immediately when the answer gates everything else or the next step is irreversible.
- Cap a batch at about 3 questions. More means the task needs clarifying as a whole; summarise your understanding and ask for correction instead.

## Record answers
- Write each answer and its reason where future sessions will find it: the repo's decision log or notes file, or the handoff note.
- Format: "Decision: skip archived items in export. Why: matches list view. Date. Applies to: export feature."
- Check the log before asking so the user never answers twice.

## Calibrate
- Cost of asking: one interruption. Cost of a wrong guess: redo time times probability. Ask only when the second is clearly larger.
- Two wrong guesses on the same topic means you should have asked; ask next time.
- When the user says "just decide", stop asking about that class of choice and record the delegation.

## Anti-patterns
- Asking permission for every routine step.
- Asking to avoid responsibility for a decision that was yours.
- Silent assumption on something destructive or expensive.
- Several questions with no recommendation.
- Asking, then ignoring the answer in later work.

## Checklist
- Searched repo, docs, and notes first.
- Question meets an "ask when" condition.
- One question, recommendation, options.
- Defaults stated explicitly.
- Answer recorded as a decision.
