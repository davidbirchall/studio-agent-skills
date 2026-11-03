---
name: retrospective
description: Running solo, blameless written retrospectives and post-project reviews - evidence from your own logs and commits, root-cause thinking, at most three actions with success signals, and feeding lessons into the next plan. Load when a week, milestone, release, or project ends, after an incident or missed date, or when asked for a retro, post-mortem, lessons-learned review, or to improve how the work is done.
---

# Retrospective

Last skill in the chain; its output returns to `planning` for the next cycle.

## Purpose
Learn from what happened and change something concrete, so the next cycle runs better. The target is the process, never the person.

## Inputs
- Decision log and status history from `milestones`.
- Estimate vs actual log from `estimation`.
- Release outcomes, incidents, and monitoring results from `release`.
- Your own notes, decision log, and commit history for the period (git log, closed tasks).

## Steps
1. Set the blameless principle: assume you acted reasonably with the information you had. Ask what in the system (process, tooling, plan) made the outcome likely.
2. Gather evidence first from your logs and commits: timeline, metrics (planned vs actual dates, defects, buffer used, scope changes). Write facts before opinions.
3. Write the review as a file, in the format that suits the situation: start/stop/continue for a general review; what went well, what did not, what to change; a timeline walkthrough for incidents or missed dates.
4. Group similar observations.
5. Dig into the top issues with root-cause thinking, such as repeated "why?" (five whys) until reaching a cause you can change. Expect several contributing causes, not one.
6. Pick at most three actions. Each has a due date and a success signal that can be checked (a file changed, a rule applied). Prefer small experiments.
7. Capture positives to keep, not only problems.
8. Save the record where future sessions will find it, and check the previous retrospective's actions first.
9. Feed lessons into the next plan: update estimation baselines, risk lists, checklists, and templates.

## Output
```
# Retrospective: <name>   <date>   Period:
Facts: planned vs actual (dates, scope, effort, defects)
Went well (keep):
Did not go well (evidence):
Root causes:
Actions (max 3): action | due | success signal
Carry into next plan: baselines, risks, checklist changes
Status of previous actions:
```

## Worked example (Lanternfall demo)
```
Facts: M1 planned wk 4, actual wk 6; light/shadow estimate 5.8 days, actual 11; buffer 5 of 5 days used by M2.
Root cause (five whys): slip -> lighting rework -> no GPU spike -> spike skipped to save a week -> no rule that high-risk assumptions get tested first.
Actions:
 1. Add "spike before estimate" for any item with P above 3x O | due next planning | signal: no item enters a milestone without it
 2. Update estimation baseline: lighting work x2 | due Fri | signal: baseline file changed
Review: first step of the next retro.
```
Chat-app feature: after an outage-free launch with a missed date, the same format applies; success needs a retro too.

## Formats and cadence
- Weekly: a 20-minute written review, start/stop/continue, from the week's commits and notes.
- Per milestone: the full template, with the timeline walkthrough for incidents, missed dates, and releases (build the timeline first, then add the decisions made at each point).
- Four Ls (liked, learned, lacked, longed for): for end-of-project reviews.
- Write milestone reviews within 5 working days, incidents within 3, and project reviews within 2 weeks.

## Decision rules
- Cap actions at 3; if everything matters, pick the one with the highest recurrence.
- An action without a due date and a success signal is a wish; strike it.
- An action open for two cycles is either dropped explicitly or turned into a decision for the user.
- A cause outside your control becomes a risk entry in `planning`, not an action.

## Quality checklist
- Written soon enough that the logs and memory are fresh.
- Evidence recorded before opinions.
- No blame; causes are about the system.
- Three or fewer actions, each dated with a success signal.
- Previous actions reviewed.

## Anti-patterns
- Blame or a hunt for a culprit, including self-blame.
- A long list of actions that never get done.
- Same complaints every cycle with no follow-up.
- Skipping the retro because the project was successful or because it was painful.
- Actions like "communicate better" with no observable signal.
- Stopping at the first "why"; "human error" is a prompt to ask why the system allowed it.

## Ready for the next planning cycle
- [ ] Actions (three or fewer) have due dates and success signals.
- [ ] Estimation baselines and the risk list are updated.
- [ ] The release checklist reflects what was learned.
- [ ] The next retrospective date is in the plan.

## Handoff
Return actions and updated baselines to `planning` to open the next cycle. Update `estimation` data and the `release` checklist with what was learned.
