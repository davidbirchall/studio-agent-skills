---
name: idea
description: Turn a raw product idea into a sharp, testable concept - problem statement, target user, value hypothesis, riskiest assumptions, and a go/park/kill call. Covers Jobs-to-be-Done framing, a one-page idea brief, and assumption ranking. Load when someone proposes a new product, feature direction, or "what if we..." and it needs shaping before any research or design starts.
---

# Idea shaping

## Purpose
Convert a vague idea into a one-page brief that states the problem, who has it, why it matters, and what must be true for it to work. Decide whether it deserves discovery effort.

## Inputs
- The idea in the requester's own words, plus why they care now.
- Any known context: business goals, existing customers, constraints (time, budget, regulation).

## Steps
1. Separate the problem from the solution. Restate the idea as "People who [situation] struggle to [outcome] because [obstacle]."
2. Frame the job (Jobs-to-be-Done): "When [situation], I want to [motivation], so I can [outcome]." Note the functional, emotional, and social parts of the job.
3. Name the target user and the current alternative (including doing nothing, spreadsheets, a competitor).
4. Write the value hypothesis: why would the user switch, and why would the business benefit.
5. List assumptions across desirability (do they want it), viability (does it pay off), feasibility (can we build it), and usability. Rank by impact if wrong and by how little evidence exists.
6. Pick the riskiest one or two and define the cheapest way to test each.
7. Decide: pursue to discovery, park with a revisit trigger, or kill with the reason recorded.

## Output
```
# Idea brief: <working title>
Problem: <who, situation, obstacle>
Job to be done: When ..., I want ..., so I can ...
Target user / current alternative:
Value hypothesis (user / business):
Assumptions (ranked): 1. ... [risk: high, evidence: none]
Cheapest tests: <assumption> -> <test>
Decision: pursue | park (revisit when ...) | kill (because ...)
```

## Sizing the effort
- Small tweak: a five-line note (problem, user, one assumption, decision). Skip the full brief.
- Medium feature: the full brief, 30 to 60 minutes.
- Big bet: full brief plus a self-review against the checklist and the user's go/no-go before any discovery time is spent.

## Quick screen and kill criteria
Score each 1 to 3 (3 = strong evidence): desirability (users feel the pain), viability (it pays off for the business), feasibility (we can build it in reasonable time). Any 1 on a dimension needs a test before pursuing. Write kill criteria up front, for example "Fewer than 3 of 8 target users describe this problem unprompted" or "No path to payback within 12 months".

## Worked example
Problem: Freelance designers who invoice several clients struggle to know who has paid because payments arrive by mixed channels.
Job: When a month ends, I want to see who still owes me, so I can chase the right people.
Alternative: A spreadsheet and bank app checks.
Hypothesis: If designers see all unpaid invoices in one place, they will switch from spreadsheets, and we gain paying subscribers.
Top assumption: Designers feel this pain weekly [risk: high, evidence: none]. Test: ask 8 designers to walk through their last month-end.
Decision: pursue; kill if fewer than 3 of 8 name chasing payments as a top frustration.

## Quality checklist
- The problem is stated without naming a solution.
- A specific user segment is named, not "everyone".
- The current alternative is identified.
- Every top assumption has a test that costs far less than building.
- A decision is recorded, with a reason.

## Anti-patterns
- Describing features instead of problems.
- Treating the requester's enthusiasm as evidence.
- Listing assumptions but never ranking or testing them.
- Skipping the kill option, so every idea survives.
- Anchoring on one clever solution and shaping the problem to fit it.

## Hypothesis format
We believe [target user] will [behaviour change] because [reason]. We will know we are right when [measurable signal] within [timeframe].

## Ready for discovery
- [ ] Problem, user, and alternative are written without a solution.
- [ ] Top two assumptions are ranked with a cheap test each.
- [ ] Kill criteria and a decision owner are recorded.

## Handoff
If the decision is pursue, hand the brief and the ranked assumptions to `discovery`.
