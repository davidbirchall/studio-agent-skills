---
name: game-idea
description: Turn a vague game concept into a testable concept - player fantasy, hook, genre and audience, game pillars, scope, and a one-page concept. Covers ideation prompts, comparing candidate ideas, and cutting scope before design starts. Load when starting a new game, brainstorming concepts, writing a one-page concept, choosing between ideas, or defining pillars.
---

# Game idea

First skill in the chain: `game-idea` -> `game-design` -> `mechanic-design` -> `systems-design` -> `progression-design` -> `level-design` -> `balance`.

## Purpose
Produce a concept small enough to evaluate and specific enough to design from. Decide whether the idea is worth designing before investing in it.

## Inputs
- Seed (theme, feeling, reference game, constraint, or audience).
- Constraints: the user's available time and skills (a solo developer), platform, budget.
- Known preferences or things to avoid.

## Framework
1. **Player fantasy**: what the player gets to be or feel ("a lone scavenger outwitting a hostile station"). Write it in one sentence.
2. **Hook**: what makes it different from the closest existing games. If there is no difference, find one or accept it is a refinement.
3. **Audience and context**: who plays, on what device, in sessions of what length.
4. **Genre and comparables**: name 2-3 reference games and state what you take from each and what you reject.
5. **Pillars**: 3-4 short statements that decide design arguments later. A pillar must be able to say no to a good feature.
6. **Core loop sketch**: the repeated action-feedback-reward cycle in one line (detail comes in `game-design`).
7. **Scope**: smallest version that delivers the fantasy (a vertical slice), plus explicit cuts.
8. **Risks**: the riskiest assumption (is it fun? is it buildable?) and the cheapest way to test it, such as paper prototype or toy.

## Output
```
# <Working title>
Fantasy: <one sentence>
Hook: <what is different>
Audience / platform / session length:
Comparables: <game: take / reject>
Pillars: 1) ... 2) ... 3) ...
Core loop (one line):
Scope: in <...> / out <...>
Riskiest assumption + test:
Decision: proceed | revise | drop
```

## Worked example
Running example used across the game skills: Lanternfall.
```
# Lanternfall
Fantasy: A lone lamplighter keeps a drowning underground city alive by carrying the last light through the dark.
Hook: Your light is both your health and your tool, so every use of it is a bet.
Audience / platform / session length: Players who like tense, short runs; PC; 20-30 minutes.
Comparables: Darkest Dungeon: take stress and dread, reject party management.
             Hades: take run structure, reject heavy narrative branching.
Pillars: 1) Light is scarce, so every choice costs. 2) The dark is readable, never cheap.
         3) Each run ends in a story worth retelling.
Core loop (one line): Spend light to push into the dark, find fuel, decide whether to go deeper.
Scope: in 1 district, 3 enemy types, 4 lantern tools / out crafting, multiplayer, voiced story.
Riskiest assumption + test: "Light as health makes choices tense." Paper test with tokens, 5 players.
Decision: proceed
```

## Candidate comparison and pillar test
Score 2-3 candidate ideas 1-5 on each row, then pick on the evidence, not on attachment.
```
Criterion              | Idea A | Idea B | Idea C
Fantasy is vivid       |        |        |
Hook is distinct       |        |        |
Fits one person and timeline |        |        |
Testable in a week     |        |        |
```
Pillar test: take a feature you love and ask which pillar it serves. If none, cut it or write it down as a candidate pillar and argue for it openly. Scope reality check: list what one person can ship in the stated time, then halve it.

## Quality checklist
- Fantasy and hook each fit in one sentence.
- Each pillar could reject a plausible feature.
- Scope fits the stated constraints.
- Riskiest assumption has a concrete, cheap test.

## Anti-patterns
- Feature list instead of an experience.
- Pillars that are generic ("fun", "polished").
- "Like X but better" with no stated difference.
- Scope sized to the dream, not to one person's capacity.
- Designing systems before the fantasy is agreed.
- Treating a comparable as a plan: "it worked for them" is not evidence it works here.
- Falling in love with the first idea and never scoring an alternative.

## Ready for the next skill
- [ ] One-page pitch filled in, with a proceed decision.
- [ ] Pillars survived the pillar test against at least one tempting feature.
- [ ] The prototype question is written down with a pass/fail signal.
- [ ] The fantasy fits in one written sentence a stranger could restate; if unsure, ask the user to try it on one outside tester.

## Handoff
Approved concept goes to `game-design` for loop, target experience, and playtest plan.
