---
name: product-definition
description: Write a product requirements document (PRD) - problem, goals and non-goals, users, prioritised requirements (MoSCoW), acceptance criteria, success metrics (HEART, north star), risks, and open questions, with a ready-to-use inline template. Load when a validated, designed opportunity must be turned into a scoped definition that the user and future sessions can build and check against.
---

# Product definition (PRD)

## Purpose
Create one reviewable document that states what is being built, for whom, why, and how success is judged, without prescribing the technical implementation.

## Inputs
- Idea brief, discovery summary, research insights, and UX design brief with story map.
- Business goals, constraints, and known dependencies.

## Steps
1. Write the problem and evidence first; link research. State goals as outcomes with metrics, and non-goals to fence scope.
2. Describe users and key scenarios using the personas and story map.
3. List requirements as testable statements, each prioritised with MoSCoW (Must, Should, Could, Won't this time). Keep Musts to what the thin end-to-end slice needs.
4. Add acceptance criteria per requirement, in Given/When/Then form where behaviour is conditional.
5. Choose success metrics: one primary outcome metric plus guardrails. HEART (Happiness, Engagement, Adoption, Retention, Task success) helps pick user-centred metrics; give baseline, target, and timeframe.
6. Record risks with mitigations, dependencies, and open questions with owners and due dates.
7. Self-review against the checklist below; version changes and log decisions in a decision log file.

## Output
```
# PRD: <name>   Status: draft | in review | approved   Version:
Owner:
## Problem and evidence
## Goals (with metrics) / Non-goals
## Users and scenarios
## Requirements
| ID | Requirement | Priority (M/S/C/W) | Acceptance criteria |
## UX references (flows, prototype, story map)
## Success metrics: primary, guardrails, baseline -> target, timeframe
## Release plan / slices
## Risks and mitigations
## Dependencies and assumptions
## Open questions: <question | owner | due>
## Change log
```

## Sizing the effort
- Small tweak: a half-page note with problem, change, and acceptance criteria.
- Medium feature: the full template with a short review.
- Big bet: the full template, a vision statement, a staged release plan, and a recorded final decision from the user.

## Vision, goals, and non-goals
Vision: one sentence on the future state for the user. Goals are outcomes, not features. Non-goals name plausible things deliberately left out, for example "No payment collection in this release".

## Metrics: leading and lagging
Lagging metrics show the result but arrive late (retention, revenue). Leading metrics move early and predict it (activation, task completion). Pick one primary metric, one or two leading indicators, and guardrails that must not worsen (error rate, support contacts). Always state baseline, target, and date.

## Requirements as testable statements
Weak: "Reminders should be easy." Testable: "A user can send a reminder for an overdue invoice in three taps or fewer, and 90 percent of test users complete it unaided."

## Worked example (extract)
Problem: Designers lose track of unpaid invoices. Goal: raise on-time payment from 62 to 75 percent within 90 days of launch. Non-goal: payment processing. R1 (Must): list unpaid invoices by age. R2 (Should): send a reminder in one flow. R3 (Could): schedule reminders. R4 (Won't): accept payments.

## Quality checklist
- Problem is evidenced, not asserted.
- Non-goals are explicit.
- Every requirement is testable and prioritised.
- Metrics have baselines, targets, and dates.
- Open questions have owners.
- No implementation detail is dictated.

## Anti-patterns
- A solution described as the problem.
- Everything marked Must.
- Vague requirements such as "fast" or "easy to use".
- A PRD written once and never updated.
- Metrics chosen after launch to fit what happened.

## Scope boundaries and risks
Mark each requirement in or out of the first release. Record risks as "If [event], then [impact]; mitigation [action]; owner". Open questions need an owner and due date, and blocking ones must close before approval.

## Ready for feature-design
- [ ] Self-review against this checklist done; the user confirmed any open decision.
- [ ] Musts form a thin end-to-end slice.
- [ ] Every requirement is testable and traces to evidence.
- [ ] Blocking open questions are closed.

## Handoff
Pick one Must-level requirement or story-map slice and take it to `feature-design` for detailed behaviour, edge cases, and delivery readiness.
