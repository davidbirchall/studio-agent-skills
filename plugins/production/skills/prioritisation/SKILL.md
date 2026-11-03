---
name: prioritisation
description: Ordering work by value and cost - MoSCoW, RICE scoring, Kano model, cost of delay and weighted shortest job first, value vs effort grids, dependency-aware sequencing, and recording the user's decision. Load when deciding what to do first, cutting a backlog to fit a deadline, resolving competing requests, or asked to rank, triage, or prioritise features or tasks.
---

# Prioritisation

Follows `scope`; feeds `estimation`.

## Purpose
Turn an agreed set of in-scope items into a defensible order, so limited capacity goes to the work that matters most and cuts are made on purpose.

## Inputs
- In-scope items with acceptance criteria from `scope`.
- Goal and success criteria from `planning`.
- Rough effort signals (even guesses) and known dependencies.

## Steps
1. Pick one primary method and apply it consistently; mixing methods per item hides bias.
2. MoSCoW for fixed-deadline work: Must (project fails without it), Should, Could, Won't (this time). Cap Musts, commonly around 60% of capacity, to leave room for Shoulds and surprises.
3. RICE for comparing many ideas: score = (Reach x Impact x Confidence) / Effort. Define scales up front and record the evidence behind each number.
4. Kano for experience-led work: classify features as basic expectations, performance (more is better), or delighters. Basics are non-negotiable; delighters differentiate.
5. Cost of delay when timing matters: estimate value lost per unit time of waiting. Weighted shortest job first divides cost of delay by duration, favouring urgent, short items.
6. Adjust for dependencies: a lower-ranked item that unblocks a top item moves up.
7. Pressure-test the top and bottom: ask what breaks if the top item is dropped and what is lost by deferring the bottom. If a real trade-off remains, ask the user one focused question and log their decision.
8. Re-rank when evidence changes, not on every new request.

## Output
```
# Priority list: <name>   <date>
Method and scales used:
Rank | Item | Category/Score | Rationale | Depends on
Cut line (below this is deferred):
Decision (user) and date:
Review trigger:
```

## Worked example (Lanternfall)
```
Capacity: 30 focused hours per week x 3 weeks = 90 hours. Musts capped at 54 (60 percent).
Rank | Item | MoSCoW | RICE | Depends on
1 | Lantern controller | Must | - | -
2 | Light/shadow rules | Must | - | 1
3 | District 1 greybox | Must | - | 2
4 | Tutorial prompts | Should | R 100 x I 2 x C 0.8 / E 4 = 40 | 3
5 | Oil crafting | Could | R 100 x I 1 x C 0.5 / E 8 = 6 | 3
--- cut line ---
6 | Controller rumble | Won't (this time)
```
Chat-app feature: read receipts score RICE 120 but depend on a message-state model that typing indicators (RICE 90) also need; build the shared model first.

## When to use which method
- Fixed date, shrinking time: MoSCoW with a Must cap.
- Many similar ideas and real data on reach: RICE. Use whole-number scales (impact 0.5/1/2/3, confidence 0.5/0.8/1.0).
- Experience quality (games, UX polish): Kano; skip numeric scoring.
- Quick triage: ICE (impact, confidence, ease, each 1-10), then judge.
- Do not use RICE or ICE when reach cannot be estimated (pre-launch game, no users yet), when items are not comparable (a bug fix versus a new mode), or when scores differ by under 20 percent; the ranking is noise.
- Time-critical items (event dates, expiring deals): use cost of delay and weighted shortest job first.

## Quality checklist
- One method, scales defined, evidence noted.
- Dependencies reflected in the order.
- A visible cut line exists.
- Musts fit within capacity with slack.
- Decision and date are recorded.

## Anti-patterns
- Everything is high priority.
- Ranking by the most recent or loudest request.
- False precision: scoring to decimals on guessed inputs.
- Ignoring effort and ranking on value alone.
- Re-ordering constantly so nothing finishes.
- Letting a score override judgement without a stated reason.
- Starting everything: limit work in progress to 1-2 items, and finish before pulling more.
- Hiding the cut line, so the cut surprises you later.

## Ready for estimation
- [ ] One method and its scales are recorded.
- [ ] Order reflects dependencies.
- [ ] A cut line exists and Musts fit under the cap.
- [ ] The decider and date are recorded.
- [ ] A review trigger is named (new evidence, not new requests).

## Handoff
Pass the ordered list and cut line to `estimation`. Items near the cut line are the first candidates for descoping in `milestones`.
