---
name: milestones
description: Turn scope into outcome-based checkpoints with vertical slices, dependencies, critical path, exit criteria, buffers, progress tracking, and replanning or cuts when dates move. Load when sequencing work, setting phase gates, building a roadmap, or tracking delivery.
---

# Milestones

Follows `estimation`; feeds `release`.

## Purpose
Break the plan into checkpoints that prove real progress, expose problems early, and give decision points where scope or dates can change.

## Inputs
- Ordered items and cut line from `prioritisation`.
- Forecast ranges and buffer from `estimation`.
- Dependencies, critical path, and risks from `planning`.
- Fixed external dates (events, partner deadlines).

## Steps
1. Define milestones as verifiable outcomes ("a player can complete one level end to end"), not dates or activity ("50% done").
2. Build an early vertical slice: a thin, complete pass through every layer of the work at near-final quality. It tests the approach, the pipeline, and the estimates while change is still cheap. Riskiest and most uncertain items go first.
3. Give each milestone exit criteria: the observable checks that must pass, using the definition of done from `scope`.
4. Sequence by dependency and priority; keep critical-path items protected.
5. Place the project buffer before fixed external dates, and track its consumption as a health signal.
6. Record progress by completed outcomes, not hours spent or percentage complete. Use a simple status in the milestone file: on track, at risk (with recovery plan), off track (with a decision needed from the user).
7. At each milestone check: compare actuals to estimates, update the forecast, and decide whether to continue, cut scope from the bottom of the priority list, or move the date. If the choice is a real trade-off, ask the user one focused question and log the answer. Adding capacity late rarely helps (Brooks's law).
8. Schedule a pre-release milestone that freezes scope; after it only fixes are accepted.

## Output
```
# Milestones: <name>   v<n>
# | Milestone (outcome) | Target (range) | Exit criteria | Depends on | Status
Buffer: <size> remaining <size>
Fixed external dates:
Scope freeze:
Decision log: <date> | <decision> | <reason>
```

## Worked example (Lanternfall, 12 weeks)
```
# | Milestone (outcome) | Target | Exit criteria
M1 | Vertical slice: one lantern room, play to win screen, on device | wk 3-4 | 60 fps, one shipped-quality asset set, build pipeline green, estimates re-checked
M2 | District 1 playable start to finish | wk 7-8 | 5 fresh testers finish; no blockers
M3 | Content and tuning complete | wk 10 | clear rate 40-60 percent
M4 | Scope freeze, fixes only | wk 11 | zero open blockers
M5 | Festival demo build | wk 12 | release checklist passed
Buffer: 5 days, placed before M4.
```
Chat-app feature: M1 is "one message sent from the browser, stored, and delivered to a second client", before any styling.

## Decision rules
- Risk first: order milestones so the highest-risk assumption is tested earliest, not the most enjoyable work.
- Vertical slice by about 25-30 percent of the timeline; if it slips past 40 percent, re-plan now.
- Milestones every 2-4 weeks; a gap longer than 4 weeks hides trouble.
- Buffer burn above 50 percent before the halfway point means status is at risk; above 80 percent means off track and a scope decision is due.
- Behind schedule: cut from the bottom of the priority list first, move the date second, extend your hours (crunch) last.
- Run the milestone check within one day of the target date, and log the decision.

## Quality checklist
- Each milestone is an outcome with exit criteria.
- A vertical slice or equivalent risk-reducing milestone comes early.
- Buffer consumption is tracked.
- Each check ends with a logged decision.
- A freeze point precedes release.

## Anti-patterns
- Milestones that are dates or "phase complete" with no test.
- Leaving all integration to the end.
- Reporting green until suddenly red (watermelon status).
- Silently absorbing slippage instead of triggering a decision.
- Crunch as the default recovery plan.
- Polish-first milestones that look good but leave the riskiest system untested.
- Moving the target date without recording why.

## Ready for release
- [ ] The final milestone and exit criteria are defined.
- [ ] The scope freeze date is set.
- [ ] Buffer remaining is known and recorded.
- [ ] The decision log is current.
- [ ] Fixed external dates have been checked against the forecast.

## Handoff
Pass the final milestone, freeze date, and exit criteria to `release`. Decision log and estimate gaps are inputs to `retrospective`.
