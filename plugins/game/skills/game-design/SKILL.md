---
name: game-design
description: Define the overall design of a game from an approved concept - target player experience using the MDA framework (mechanics, dynamics, aesthetics), core loop and meta loops, player goals, structure, and an early playtest plan. Produces a lightweight game design document. Load when turning a concept into a design, writing or reviewing a design doc, defining the core loop, or planning first playtests.
---

# Game design

Follows `game-idea`. Next: `mechanic-design`.

## Purpose
Translate pillars and fantasy into a coherent design: what the player does, why they keep doing it, and how you will know it works.

## Inputs
- Concept and pillars from `game-idea`.
- Platform, session length, and audience.

## Framework
1. **Target aesthetics first (MDA)**: the MDA framework (Hunicke, LeBlanc, Zubek) separates Mechanics (rules), Dynamics (behaviour emerging in play), and Aesthetics (emotional response). Designers build mechanics, players experience aesthetics, so start from the intended feelings (challenge, discovery, expression, fellowship) and work backward.
2. **Core loop**: the 5-60 second cycle of action, feedback, and reward the player repeats. State each step and what the player decides.
3. **Meta loops**: session loop (minutes to an hour) and long-term loop (days or weeks). Each should feed back into the core loop with new options.
4. **Goals**: short, mid, and long-term goals the player can state in their own words.
5. **Structure**: single or multiplayer, session shape, win/lose conditions, failure cost.
6. **Player types and onboarding**: what the first five minutes teach, and in what order.
7. **Playtest plan**: define the question before the build. Early on use paper or greybox prototypes, observe silently, and ask what players did and felt, not whether they liked it. Record hesitation, confusion, and repeated behaviour. Test with people outside the project (recruited friends or testers), plus a solo playtest by the designer.

## Output
```
Target aesthetics: <ranked, with the pillar each serves>
Core loop: action -> feedback -> reward -> new decision
Session loop / long-term loop:
Goals (short / mid / long):
Win, lose, and failure cost:
First five minutes:
Playtest 1: question | prototype | participants | success signal
Open questions:
```

## Worked example (Lanternfall)
```
Target aesthetics: 1) Dread / tension (pillar 1) 2) Discovery (pillar 2) 3) Narrative (pillar 3)
Core loop:   [Light the way] -> [Move into the dark] -> [Meet hazard or find fuel]
                 ^                                              |
                 +---- [Decide: go deeper or return] <---------+
Session loop: descend a district, bank fuel at the lamp-post hub, spend it on a lantern tool.
Long-term loop: unlock tools and districts, which open new routes in earlier ones.
Goals: short = reach next lamp-post; mid = clear the district; long = relight the city core.
Win / lose: win = relight the core; lose = light hits zero; cost = lose carried fuel, keep tools.
First five minutes: move, use the light pulse, pick up fuel, survive one hazard, reach a lamp-post.
Playtest 1: "Do players hesitate before spending light?" | paper tokens | 5 outsiders | 3 of 5 pause.
```

## Pillars to features and risk list
Map every proposed feature to a pillar and an aesthetic; a feature with no row is cut or deferred.
```
Feature        | Pillar served | Aesthetic | Cost (S/M/L) | Risk
Light pulse    | 1, 2          | Dread     | S            | Low
Lantern tools  | 1, 3          | Expression| M            | Medium
```
Vertical slice definition: one district, full loop from descent to lamp-post, placeholder art, one tool, one hazard, a win and a lose state. If the slice is not fun, more content will not fix it. Rank risks by (impact x uncertainty) and test the top one first.

## Quality checklist
- Every aesthetic maps to a pillar.
- The core loop is enjoyable on its own, before rewards layered on top.
- A new player can describe their current goal.
- Each playtest has a question and a pass/fail signal.

## Anti-patterns
- Design doc as a catalogue of features with no loop.
- Rewards compensating for a dull core action.
- Asking testers for design solutions rather than observing behaviour.
- Testing only with yourself or people who know the design.
- Leaving onboarding to the end.
- A meta loop that never changes the core loop, so progress feels cosmetic.
- Treating the design doc as finished; it is a living record updated after each playtest.

## Ready for the next skill
- [ ] Core loop written as steps, each with a player decision.
- [ ] Vertical slice defined and small enough to build.
- [ ] Top three risks ranked, with the first playtest planned.
- [ ] Every loop step is listed as a mechanic that needs a spec.

## Handoff
Core loop and goals go to `mechanic-design`, which specifies the individual actions and rules behind each loop step.
