---
name: rapid-domain-learning
description: Getting competent in an unfamiliar domain quickly - defining the target capability and a question list, finding the 20 percent core in primary sources and official docs, building a glossary first, drawing a mental model of the domain, learning through small runnable experiments, comparing two or three sources and flagging disagreement, calibrating confidence and marking unverified claims, keeping a learning log, applying a stopping rule, turning learnings into notes or a skill, and knowing when to ask the user for context only they hold. Load when starting work in a domain, tool, or technology you do not yet know well, or when asked to get up to speed on a subject before acting.
---

# Rapid domain learning

Source evaluation rules live in `research-practice`; summaries in `source-summarisation`; storage in `personal-knowledge-base` and `knowledge-capture`. This skill sequences them to reach working competence fast.

## 1. Define the target
- State the capability in one sentence: "Able to configure X so that Y passes", not "learn X".
- Write 5-15 questions the work needs answered. Rank them; the top 3 drive the first pass.
- Note what is out of scope. Unbounded learning never ends.
- Ask the user now if the goal, deadline, or environment is unclear (see step 9).

## 2. Find the core
- Roughly 20 percent of concepts cover 80 percent of tasks. Find it via: official getting-started and concepts pages, the spec or reference, a canonical book, the project's own examples and tests.
- Prefer primary sources over blog summaries. Use secondary sources only for orientation.
- Cap discovery at about 10 percent of the time budget.

## 3. Glossary first
- Collect every unfamiliar term in the first pass; define each in one line in your own words.
- Mark terms with two meanings (domain vs common English).
- Re-read sources after the glossary; comprehension jumps.
```markdown
- idempotent: repeating the call gives the same end state. Source: <ref>
```

## 4. Build the map
- Draw the domain as a short outline or diagram: main entities, how they relate, the lifecycle or data flow, the common failure points.
- Limit to one page. Mark the 3-5 central concepts; everything else hangs off them.
- Update the map when an experiment contradicts it.

## 5. Learn by running
- For each top question, run the smallest experiment: a 10-line script, a REPL call, a one-file project, a failing test.
- Predict the result before running. A wrong prediction marks a gap in the model.
- Prefer experiments over reading when the system can be run safely. Never experiment on production or with real credentials.
- Record the command and observed output.

## 6. Cross-check
- For any claim that drives a decision, find 2-3 independent sources. Weight: official docs and running code over forum answers.
- Flag disagreement explicitly: "A says X, B says Y; tested, Y holds on version 4.2."
- Check dates and versions; domain advice older than 2 years is suspect in fast-moving fields.

## 7. Calibrate
- Tag each claim: `verified` (ran it or read the primary source), `reported` (one secondary source), `inferred` (own reasoning).
- Do not present `inferred` or `reported` claims as fact in outputs.
- List known unknowns at the end of every pass.

## 8. Learning log
```markdown
## 2026-03-14 - <domain>
Goal: <capability>
Learned: <fact> [verified]
Surprise: <what contradicted the model>
Open: <question still unanswered>
Next: <smallest next step>
```
- Append after each session; one entry is under 10 lines.

## 9. Ask the user
- Ask only for what research cannot reveal: their goals, constraints, existing systems, preferences, access, and what "good enough" means.
- Batch questions; offer a default assumption with each so the user can answer "yes".
- Do not ask what the docs answer.

## 10. Stop and convert
- Stopping rule: stop when you can make the next decision or complete the next task with known risks listed. Not when the topic feels complete.
- Re-open learning when a decision hits a known unknown.
- Convert: stable facts to atomic notes, the glossary and map to the knowledge base, a repeated procedure to a skill file.

## Anti-patterns
- Reading broadly with no question list.
- Trusting the first search result or an AI answer without running it.
- Skipping the glossary, then misreading every source.
- Marking everything as certain.
- Learning past the point of the decision.

## Checklist
- Target and ranked questions written; scope bounded.
- Glossary and one-page map exist.
- Top questions answered by experiment or primary source.
- Disagreements flagged; claims tagged by confidence.
- Log updated; open questions and user-only questions listed.
