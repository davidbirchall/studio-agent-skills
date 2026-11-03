---
name: discovery
description: Product discovery process - frame the outcome, map the opportunity space with an opportunity solution tree, run the double diamond (diverge/converge on problem then solution), and plan assumption tests to decide what is worth building. Load when an idea has been shaped and the user must decide which problems and solutions to pursue, or when scope is unclear and evidence is thin.
---

# Product discovery

## Purpose
Reduce the risk of building the wrong thing. Discovery identifies which user problems are worth solving and which solutions are worth testing, using evidence rather than opinion.

## Inputs
- Idea brief and ranked assumptions (from `idea`).
- A desired outcome or business goal, and the time box for discovery.
- Access to users, data, or the user's own data and contacts.

## Steps
1. Set the outcome: a measurable change in user or business behaviour, not an output ("increase weekly active teams", not "ship dashboards").
2. Diverge on the problem (first diamond, Discover): gather evidence from analytics, support tickets, sales calls, and existing research. Plan interviews via `user-research`.
3. Converge (Define): cluster findings into opportunities, phrased as user needs, pain points, or desires. Build an opportunity solution tree (Teresa Torres): outcome at the top, opportunities beneath, candidate solutions beneath those, assumption tests at the leaves.
4. Prioritise opportunities by reach, severity, and strategic fit. Pick one target opportunity at a time.
5. Diverge on solutions (second diamond, Develop): generate at least three different solutions for the chosen opportunity, not variations of one.
6. Converge (Deliver): choose the solution to test. Map its assumptions and test the riskiest first with prototypes, fake-door tests, concierge or Wizard-of-Oz trials, or surveys.
7. Review evidence at a fixed cadence. Decide: build, iterate, or drop.

## Output
```
# Discovery summary: <area>
Outcome:
Evidence gathered: <source, date, finding>
Opportunity tree: Outcome > Opportunity > Solutions > Tests
Chosen opportunity and why:
Solutions considered (3+):
Assumption tests: <assumption | method | success threshold | result>
Decision: build | iterate | drop
Open questions:
```

## Sizing the effort
- Small tweak: one or two days. Check analytics and support tickets, test one assumption, decide.
- Medium feature: one to two weeks, one opportunity, three solutions, two or three tests.
- Big bet: several weeks, a full opportunity tree, and a written decision log entry (evidence, choice, reason) at each diamond close.

## Assumption map and ranking
Plot every assumption on two axes: importance (impact if wrong) and evidence (how much we know). Test the important, low-evidence quadrant first; ignore the unimportant, well-evidenced one. Cover desirability, viability, feasibility, and usability.

## Cheapest test per assumption
| Assumption type | Cheapest useful test |
| Users want it | Fake-door button, landing page sign-up, 5 interviews |
| Users can use it | Clickable prototype, think-aloud sessions |
| It pays off | Pre-sale, price test, back-of-envelope model |
| We can build it | Time-boxed technical spike |
| Value is real | Concierge or Wizard-of-Oz manual delivery |

## Experiment design
State: assumption, method, sample, success threshold, failure threshold, and the decision each result triggers. Example: "Fake-door on the invoices page. Success: at least 8 percent of 400 visitors click. Below 3 percent: drop this solution. Between: iterate on the wording and rerun."

## Continuous discovery cadence
Weekly: talk to at least one user, review the opportunity tree, run or read one test. Monthly: revisit the outcome and retire stale opportunities.

## Quality checklist
- Outcome is measurable and not a feature.
- Each opportunity traces to evidence, not a hunch.
- At least three solutions were compared.
- Every test has a success threshold set before running it.
- The decision records what evidence would change it.

## Anti-patterns
- Jumping straight to the first solution.
- Running discovery as a one-off phase instead of continuously.
- Interviewing only friendly users or only the user's own opinions.
- Tests with no pre-agreed pass or fail criteria.
- Confirmation bias: counting only the signals that support the favoured solution.

## Opportunity solution tree outline
```
Outcome: <measurable change>
  Opportunity A: <user need or pain, with evidence>
    Solution A1 > Assumption test
    Solution A2 > Assumption test
    Solution A3 > Assumption test
  Opportunity B: ...
```

## Ready for ux-design
- [ ] One opportunity is chosen with evidence from at least two sources.
- [ ] The chosen solution passed its riskiest desirability and usability tests.
- [ ] Remaining unknowns are logged as open questions.

## Handoff
Take the open evidence gaps to `user-research` for primary research. When the opportunity is validated, proceed to `ux-design`.
