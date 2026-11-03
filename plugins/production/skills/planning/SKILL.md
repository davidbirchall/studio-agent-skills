---
name: planning
description: Turning an idea into a workable project plan - goal and outcome definition, who the work is for, constraints, assumptions, risks, dependencies, work breakdown structure, and a living plan document. Load when starting a project, phase, or initiative, when a goal is vague, or when asked to plan, kick off, or structure work before scope is fixed.
---

# Planning

First skill in the chain: planning, scope, prioritisation, estimation, milestones, release, retrospective. Domain-agnostic: software, games, creative work.

## Purpose
Establish why the work exists, what success looks like, and what could stop it, so later skills have firm ground. A plan is a tool for decisions, not a promise.

## Inputs
- The idea, request, or problem statement.
- Who the work is for (user, player, customer), deadline pressures, budget, and your own capacity (focused hours per week, other commitments).
- Lessons from any previous similar project.

## Steps
1. State the goal as an outcome, not an activity ("players finish the tutorial in under 10 minutes", not "build tutorial").
2. Define measurable success criteria and how you will judge them (a metric, a test, a user reaction).
3. Name who the work is for and who is affected (users, players, customers, a client). The user is the single decision-maker; ask them when a real decision is needed. If you work with others: list who else decides.
4. Record constraints (time, budget, people, platform, legal) separately from assumptions (things believed true but unverified).
5. Build a work breakdown structure (WBS): decompose deliverables, not tasks, until each leaf fits in one focused session or a few days and can be estimated. Follow the 100% rule: the children must cover all of the parent's work and nothing more.
6. Map dependencies between leaves and to outside parties (vendors, platforms, contractors); mark the critical path.
7. Run a short risk pass: list risks with likelihood, impact, and a mitigation or trigger. Convert unverified assumptions into validation tasks.
8. Decide cadence: re-read the plan at the start of each weekly session, update it, and log any change and why in the plan's change log. Only the user decides changes to goal or success criteria; ask one focused question when blocked.

## Output
```
# Plan: <name>   v<n>   <date>
Goal / outcome:
Success criteria:
Who it is for / affected:
Constraints:
Assumptions (with how each is validated):
WBS: 1. <deliverable> / 1.1 ... (leaf = ownable, estimable)
Dependencies and critical path:
Risks: <risk> | L | I | mitigation
Review cadence and change rule:
Open questions:
```

## Worked example (Lanternfall and a chat app)
```
Goal: 70 percent of new Lanternfall players finish District 1 in under 20 minutes (Unity, solo, 12 weeks).
Constraints: demo at a fixed festival on week 12; about 15 focused hours per week around a day job.
Assumptions: lantern-light mechanic is fun (validate: paper test, week 1); URP handles 40 lights on target GPU (validate: spike, week 2).
WBS: 1 Core loop > 1.1 Lantern controller > 1.2 Light and shadow rules; 2 District 1 > 2.1 Greybox > 2.2 Art pass; 3 Tutorial; 4 Build and demo pipeline.
Risk: R1 | L high | I high | lighting cost too high -> trigger: under 45 fps on week-2 spike -> fall back to baked light.
```
Chat-app feature, same shape: goal "message delivery confirmed within 2 seconds for 95 percent of sends"; assumption "the websocket gateway holds 5k connections" becomes a load-test task before any UI work.

## Decision rules
- Plan the next 2-4 weeks at task level, the next quarter at deliverable level, beyond that at theme level.
- Any assumption that is high impact and unverified becomes a task in the first two weeks.
- More than 7 top-level WBS items, or a leaf over about 2 weeks of work, means decompose further or regroup.
- A risk with high likelihood and high impact needs a mitigation scheduled now, not a note.
- Solo: one page, at most 1-2 leaves in progress at once. Plan against focused hours (often 15-25 per week), not calendar time.

## Quality checklist
- Goal is an outcome with a measurable test.
- Every WBS leaf is a deliverable that fits in a few focused sessions.
- Assumptions are labelled and have a validation step.
- Top risks have mitigations or triggers.
- The plan fits on a few pages and is easy to update.

## Anti-patterns
- Planning in detail far ahead; plan near-term in detail, later work coarsely (rolling-wave planning).
- Activity lists with no outcome.
- Hidden assumptions treated as facts.
- A plan written once and never revisited.
- Skipping dependencies on outside parties (platforms, vendors, contractors).
- A WBS of tasks ("write code") rather than deliverables, which hides what is actually being produced.
- Success criteria that cannot be checked by a test, metric, or observation.
- Treating the plan as a promise to others rather than a decision tool.

## Ready for scope
- [ ] Goal is an outcome with a measurable test.
- [ ] Constraints and assumptions are separate lists; assumptions have validation steps.
- [ ] WBS leaves are deliverables.
- [ ] Top three risks have triggers.
- [ ] Re-read cadence and change log are in the plan file.

## Handoff
Pass the goal, constraints, and draft WBS to `scope` to fix boundaries. Risks and assumptions feed `estimation` and `milestones`.
