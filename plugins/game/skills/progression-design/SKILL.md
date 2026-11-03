---
name: progression-design
description: Design how players advance over time - power curve, skill and knowledge progression, unlock pacing, rewards and motivation, onboarding to endgame, and retention loops. Covers flow, difficulty curve shape, and reward schedules. Load when planning levels or XP, unlocks, skill trees, rewards, tutorial flow, pacing across a session or campaign, or the endgame.
---

# Progression design

Follows `systems-design`. Next: `level-design`.

## Purpose
Control what the player knows, can do, and wants at each point in the game so challenge and reward stay in step.

## Inputs
- Resources, loops, and system map from `systems-design`.
- Session and long-term loops from `game-design`.

## Framework
1. **Three kinds of progression**: power (stats, gear), knowledge (what the player understands), and content (new places, modes, story). Decide the mix; skill-based games lean on knowledge, so power gains should not hide a lack of it.
2. **Flow channel**: Csikszentmihalyi's flow describes engagement when challenge matches skill; too hard yields anxiety, too easy yields boredom. Aim to raise challenge as skill grows.
3. **Difficulty curve**: plan a sawtooth rather than a straight ramp: tension, peak, relief, then a higher peak. Include rest points.
4. **Introduce, develop, twist, conclude**: teach each mechanic in a safe setting, test it with mild pressure, combine it with others, then retire or escalate it.
5. **Unlock schedule**: table of what unlocks when and why. Space unlocks so the player has time to master each before the next. Avoid flooding at the start.
6. **Rewards**: tie them to goals the player values. Variable rewards sustain interest but must not replace intrinsic motivation. Make milestones visible.
7. **Failure and recovery**: set what loss costs and how quickly the player re-enters play.
8. **Endgame and retention**: define what the player does after the main path (mastery, mods, challenges, social), and what pulls them back, without manipulative pressure.

## Output
```
Progression axes: power / knowledge / content (weights)
Pacing outline: phase | player skill | challenge | new element | reward
Difficulty curve: <sketch of peaks and rests>
Unlock table: item | unlock trigger | purpose
Onboarding sequence: <first 5-30 minutes>
Endgame loop:
Metrics to check: <e.g. time to first win, drop-off points>
```

## Worked example (Lanternfall)
```
Phase | Player skill   | Challenge          | New element          | Reward
1     | Novice         | Static hazards     | Light pulse          | First lamp-post lit
2     | Learning       | Hazards + 1 hunter | Fuel economy         | Echoes, first tool
3     | Competent      | Hunters in groups  | Lantern tool: shutter| Second district
4     | Skilled        | Mixed, timed       | Combine tools        | Route shortcuts
5     | Expert         | Modifiers          | Dark mode challenges | Cosmetics, bragging
Difficulty curve:  /\  /\   /\   (peak, rest at lamp-post, higher peak; rest after phase 3)
Unlock table: item | trigger | purpose
  Shutter tool | 30 Echoes   | teaches hiding from hunters
  District 2   | clear D1    | recombines pulse and shutter
```

## Power versus skill, onboarding, and ethics
- Power progression (more light capacity) must stay small; most growth should come from knowledge and new options, so a skilled player can beat early content with early gear.
- Onboarding: teach one verb per level in a safe space, with the failure state visible but cheap. Replace text with a prop, a clearly lit example, or a forced first use.
- Gating: gate by demonstrated skill or story, not by waiting. If a gate exists for pacing, the player must be able to see what opens it.
- Reward schedule: mix predictable rewards (every descent) with occasional surprises. Do not use fake scarcity, loss aversion timers, or hidden odds; disclose chances if randomised.
- Retention: offer reasons to return (new routes, challenges, story chapters), never penalties for staying away.
- Validation: check time to first success, drop-off per phase, and whether players can state their next goal.

## Quality checklist
- Every phase introduces at most one or two new ideas.
- Power curve and difficulty curve are reconciled, not tuned independently.
- Rest points follow each peak.
- The player always has a visible next goal.

## Anti-patterns
- Linear difficulty ramp with no relief.
- Grind used to pad playtime.
- Reward drops disconnected from effort.
- Power creep that trivialises earlier content.
- Teaching through text walls rather than play.
- Daily streak or countdown pressure that punishes absence.
- Unlocking everything at once, or locking the fun behind the tutorial.

## Ready for the next skill
- [ ] Pacing outline lists each phase with its one or two new ideas.
- [ ] Unlock table gives a reason for every item.
- [ ] Onboarding sequence tested with new players for the first 10 minutes.
- [ ] Target metrics set (time to first win, expected drop-off) for playtests.

## Handoff
Pacing outline and unlock table go to `level-design`, which builds the spaces and encounters that deliver each phase.
