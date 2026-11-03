---
name: decision-making
description: Making and recording decisions well - clarifying the decision and criteria, generating options, classifying reversible (two-way door) vs irreversible (one-way door) choices, weighing options with a decision matrix, running a pre-mortem, and writing a decision record with context, options, decision, and consequences. Load when choosing between alternatives, committing to a direction, or documenting why a choice was made.
---

# Decision-making

Chain: `research-practice` -> `knowledge-capture` -> **decision-making** -> `documentation` -> `review`. The decision-record template is included below.

## Purpose
Reach a defensible choice at a speed proportional to its risk, and leave a written record so the reasoning survives into future sessions.

## Inputs
- The decision to be made and its deadline. The user is the decision-maker.
- Evidence and confidence levels from `research-practice` or `knowledge-capture`.
- Constraints and the user's known preferences.

## Steps
1. **State the decision** as a question with a deadline. Separate it from related decisions.
2. **Classify reversibility.** Two-way door (easy and cheap to undo): decide fast with the information at hand. One-way door (costly or impossible to undo): slow down, gather more evidence, and put the choice to the user with the options and a recommendation.
3. **Set criteria.** List 3-6 criteria and weight them (e.g. cost, risk, time, fit, effort to maintain). Fix the weights before scoring to avoid rationalizing a favorite.
4. **Generate options.** At least three, including "do nothing" and a hybrid. A choice between two is often a false dilemma.
5. **Evaluate.** Score each option per criterion using a decision matrix; cite evidence and mark low-confidence inputs. Treat the score as input to judgment, not a verdict.
6. **Run a pre-mortem.** Assume the chosen option failed a year from now; list the most plausible reasons, then add mitigations or change the choice.
7. **Decide and commit.** If the choice needs the user (preference, risk appetite, one-way door), ask one focused question with a recommendation; otherwise decide. Record the strongest argument against. Define a trigger or date to revisit, especially for one-way doors.
8. **Record it** in the template below and save it in the project's decision log.

## Output
```markdown
# Decision: <short title>
Status: proposed | accepted | superseded by <title> | rejected
Date: <YYYY-MM-DD> | Decided by: user | Reversibility: one-way | two-way

## Context
<Situation, forces, constraints, evidence with confidence.>

## Options considered
1. <Option> - pros, cons
2. <Option> - pros, cons
3. Do nothing - pros, cons

## Decision
<Chosen option and the main reasons, tied to criteria.>

## Consequences
- Positive: ...
- Negative / accepted trade-offs: ...
- Risks and mitigations (from pre-mortem): ...
- Revisit when: <date or trigger>
```

## Quality checklist
- Decision is a single clear question.
- Reversibility is stated and effort matches it.
- At least three options, including doing nothing.
- Criteria set before scoring; evidence cited.
- Pre-mortem done for one-way doors; revisit trigger recorded.
- Superseded decisions are marked, never deleted.

## Anti-patterns
- Analysis paralysis on two-way doors.
- Treating one-way doors casually.
- Choosing first, then building criteria to justify it.
- Decisions made silently, or one-way doors decided without asking the user.
- Recording only the outcome, omitting rejected options and why.

## Handoff
- Pass the accepted record to `documentation` for durable write-ups.
- Pass the record and its rationale to `review` for a checklist challenge before it is final.
- Store the record as a permanent note via `knowledge-capture`.

## See also

Optional, if installed: technical-design (the shared plugin) for the broader discipline this skill applies. This skill stands on its own.
