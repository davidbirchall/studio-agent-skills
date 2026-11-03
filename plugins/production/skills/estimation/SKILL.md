---
name: estimation
description: Estimating effort and duration under uncertainty - ranges, three-point (PERT) estimation, reference-class estimation, relative sizing, the cone of uncertainty, buffers, confidence levels, and tracking estimates against actuals. Load when sizing work, forecasting a date, building a schedule or budget, or asked how long something will take or how to give an estimate.
---

# Estimation

Follows `prioritisation`; feeds `milestones`.

## Purpose
Produce honest forecasts with stated uncertainty, so dates and budgets reflect risk rather than hope.

## Inputs
- Prioritised items with acceptance criteria and WBS leaves.
- Your capacity: focused hours per week, leave, and other commitments.
- Historical data from similar past work, if any.
- Risks and assumptions from `planning`.

## Steps
1. Estimate effort (work content) separately from duration (calendar time). Duration also depends on availability, waiting, and interruptions.
2. Estimate as a range, never a single number. Calibrate against the logged actuals of the person doing the work (the user).
3. Three-point estimation: optimistic (O), most likely (M), pessimistic (P). PERT expected value = (O + 4M + P) / 6. The spread signals uncertainty.
4. Reference-class estimation: find comparable past work and use its actual outcomes as the baseline, then adjust for known differences. This counters the planning fallacy (optimism about one's own project).
5. For large or fuzzy items use relative sizing (t-shirt sizes or points) and calibrate against a completed item; convert to time using observed throughput.
6. Apply the cone of uncertainty: early estimates can be off by a large factor and narrow as decisions are made and work is proven. Re-estimate at milestones and record the current range.
7. Add buffers explicitly: a project-level buffer for risk, held by the project, not padded invisibly into every task. Size it from the pessimistic spread and the risk list.
8. State confidence ("80% likely by 14 June") and the assumptions behind it.
9. Record estimates and actuals; review the gap at each milestone.

## Output
```
# Estimates: <name>   <date>   Basis: <three-point | reference class | relative>
Item | O | M | P | Expected | Confidence | Assumptions
Subtotal effort / Capacity per period / Duration range:
Buffer (size and rationale):
Forecast: <date range> at <confidence>
Estimate vs actual log:
```

## Worked example (Lanternfall)
```
Item | O | M | P | Expected (O+4M+P)/6 | Confidence
Lantern controller | 2 | 3 | 7 | 3.8 days | 80 percent
Light/shadow rules | 3 | 5 | 12 | 5.8 days | 70 percent
District 1 greybox | 4 | 6 | 10 | 6.3 days | 80 percent
Subtotal 15.9 days. Reference class: last two levels took 1.4x and 1.6x the first estimate -> plan 1.5x = 24 days.
Capacity: 1 person x 3 focused days per week x 3 weeks = 9 days -> forecast 8 weeks at 24 days of effort; 80 percent by week 9.
Buffer: 20 percent of 24 = 5 days, held at project level.
```
Chat-app feature: a "similar to search filters, which took 9 days against an estimate of 5" becomes the baseline, not the optimistic gut feel.

## Decision rules
- Cone of uncertainty: at idea stage expect 0.25x-4x error, after scope and design roughly 0.5x-2x, after a vertical slice about 0.8x-1.25x. Quote ranges that match the stage.
- Appetite versus estimate: an estimate asks how long a defined thing takes; an appetite fixes the time and shapes scope to fit. Use appetite for shapeable work, estimates for fixed deliverables.
- If P is more than 3x O, the item is not understood; split it or run a spike first.
- Anything over about 5 days of effort gets split before estimating.
- Throughput forecasting: after 5 or more finished items, use average cycle time and its spread rather than fresh guesses.
- Buffer: 15-25 percent for familiar work, 30-50 percent with new tech or an unproven pipeline.

## Quality checklist
- Ranges and confidence are shown, not single points.
- Effort and duration are separated.
- Buffer is explicit.
- Assumptions are listed.
- Comparable past data (your own logged actuals) was consulted.

## Anti-patterns
- Estimates turned into commitments without the range.
- Padding every task, which gets consumed (Parkinson's law).
- Estimating without checking logged actuals or a reference class.
- Ignoring non-working time and context switching.
- Anchoring on the first number suggested (including by the user or the AI).
- Treating the PERT expected value as a promise; it is the mean, about half of outcomes land later.
- Never logging actuals, so every estimate starts from zero.

## Ready for milestones
- [ ] Every item has a range, a basis, and listed assumptions.
- [ ] Effort and duration are separated, with capacity shown.
- [ ] Buffer is sized.
- [ ] The forecast states a confidence level.
- [ ] The estimate vs actual log exists.

## Handoff
Pass forecast ranges and the buffer to `milestones` to place dates and decision points.

## See also

Optional, if installed: technical-design (the shared plugin) for the broader discipline this skill applies. This skill stands on its own.
