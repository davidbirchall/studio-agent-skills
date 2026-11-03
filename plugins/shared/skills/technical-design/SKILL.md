---
name: technical-design
description: Technology-neutral technical design process - writing a design doc with problem, goals and non-goals, constraints, options considered with trade-offs, chosen approach, risks, rollout and rollback, testing and observability plan, open questions, and review; sizing the design to the change from one-pager to full doc; using spikes to retire uncertainty; and an inline template. Load when planning a non-trivial feature or change, writing or reviewing a design doc, comparing implementation options, or planning a rollout.
---

# Technical design

Builds on `software-architecture` for structural choices, `software-testing-strategy` for the test plan, and `technical-documentation` for where the doc lives. Frontend, backend, ai-engineering and game-development plugins apply it to their stacks.

## When and how much
- Design before coding when the change is hard to reverse, crosses modules, touches data, security or public contracts, or is unclear.
- Skip the doc for small, reversible, well-understood changes; a clear commit message is enough.
- Size to risk:
  - One-pager (under a page): problem, approach, risks, test plan. For changes of a few days.
  - Standard doc: full template below. For multi-week work.
  - Full doc plus a self-review pass (and AI review): for one-way doors, migrations, new services, public API changes.
- A design is a thinking tool. If writing it taught you nothing, it was too small to need one.

## Write the problem first
- State the problem and who has it, with evidence (metrics, tickets, incidents). A solution without a problem is a guess.
- Goals are measurable outcomes. Non-goals are plausible things you will explicitly not do; they bound the scope.
- List constraints: deadlines, compatibility, compliance, team skills, existing systems.

## Options
- Present at least two real options, including "do nothing" or the minimal change.
- For each: how it works in two or three sentences, pros, cons, cost, risk, reversibility.
- Choose with reasons tied to the goals. Say why the rejected options lost, so later readers need not rediscover them.

## Plan the delivery
- Rollout: phases, feature flags, migration steps, backfill, who is affected, how to verify each step.
- Rollback: how to undo each step, what data cannot be undone, and the point of no return.
- Compatibility: old and new versions coexisting, expand-then-contract for schemas and APIs.
- Testing: levels and risks covered (`software-testing-strategy`), plus what is verified only in production.
- Observability: metrics, logs, traces and alerts that show the change works or is failing; define success and abort thresholds.
- Security, privacy and performance impact (`application-security`, `performance-engineering`).

## Spikes
- Use a time-boxed spike to answer a specific unknown (feasibility, performance, integration). Write the question and the time limit first.
- Output is knowledge, not production code. Record findings in the doc and discard or rewrite the code.

## Review
- Self-review the draft against the template with a fresh pass, and ask an AI assistant to challenge assumptions, missing options, failure modes and operability, not formatting.
- When a real decision is needed, ask the user one focused question with options and a recommendation.
- Resolve or record every open question before build. Update the doc if the design changes materially.
- Keep the doc in the repo (see `technical-documentation`) and, for architecture-level choices, add a decision record as described in `software-architecture`.

## Template
```md
# <Title>
Status / date

## Problem
What hurts, for whom, evidence.

## Goals / Non-goals
- Goal: measurable outcome
- Non-goal: explicitly out of scope

## Constraints
## Options considered
### A. <name> - how it works; pros; cons; cost; reversibility
### B. <name> ...
## Chosen approach
Design details: components, data model, interfaces, flows. Why this option.

## Risks and mitigations
## Rollout and rollback
## Testing plan
## Observability and success metrics
## Open questions
## Follow-ups
```

## Anti-patterns
- Writing the doc after the code. Listing one option. Goals that cannot be measured. No rollback. Open questions left untracked. A doc that is never updated and misleads later readers.
