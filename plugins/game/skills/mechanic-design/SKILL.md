---
name: mechanic-design
description: Specify individual game mechanics - player verbs, rules, inputs, feedback, risk/reward, meaningful choices, and edge cases - so each action in the core loop is clear, testable, and fun. Covers verb lists, rule statements, feedback (juice) and failure states. Load when designing an action, ability, combat or movement rule, puzzle rule, or reviewing whether a mechanic creates interesting decisions.
---

# Mechanic design

Follows `game-design`. Next: `systems-design`.

## Purpose
Turn each step of the core loop into a precise, small rule set that creates interesting decisions.

## Inputs
- Core loop, goals, and pillars from `game-design`.
- Platform input constraints.

## Framework
1. **Verbs**: list what the player can do (move, aim, trade, build). Prefer few verbs with depth over many shallow ones.
2. **Rule statement per mechanic**: trigger, conditions, effect, cost, cooldown or limit, and what stops it. Write so two people would implement it the same way.
3. **Meaningful choice**: a choice is meaningful when options differ in outcome, the player can anticipate consequences, and no option is always best. Remove dominant strategies.
4. **Risk/reward**: tie stronger outcomes to higher exposure (time, resource, position, chance). Make risk legible before the player commits.
5. **Feedback**: every action needs clear response through visuals, audio, and state change (often called juice). The player must be able to tell cause from effect, and success from failure.
6. **Mastery and skill**: decide what skill grows (timing, planning, knowledge) and how the mechanic rewards it.
7. **Failure and edge cases**: what happens at zero, at max, simultaneously, or when interrupted. Failure should teach.
8. **Interactions**: note how this mechanic combines with others; emergent combinations are intended or must be bounded.

## Output
```
Mechanic: <name>   Serves loop step: <...>
Verb / input:
Rule: when <trigger> and <conditions>, then <effect>; cost <...>; limit <...>
Choice created: <options and tradeoffs>
Risk / reward:
Feedback: <visual / audio / state>
Skill expressed:
Failure and edge cases:
Interacts with: <mechanics>
Tuning knobs: <named values, handed to balance>
```

## Worked example (Lanternfall)
```
Mechanic: Light pulse   Serves loop step: Light the way / Move into the dark
Verb / input: Pulse (hold to charge, release to fire)
Rule: when released with at least 1 light, reveal hazards within radius (1 + charge seconds)
      tiles for 3 seconds; cost 1 light per full second charged; limit one pulse at a time.
Choice created: small cheap pulse and risk the unseen, or big pulse and burn light.
Risk / reward: pulsing reveals you to creatures that hunt by light; information costs safety.
Feedback: ring expands with a rising hum; revealed hazards flash; light meter drops visibly.
Skill expressed: judging charge time against distance; reading the dark.
Failure and edge cases: at 0 light the pulse fizzles with a clear cue; interrupted by damage
      cancels the charge and refunds nothing; two pulses cannot overlap.
Interacts with: Hunters (drawn by pulse), Fuel (restores light).
Tuning knobs: PulseCostPerSecond, BaseRadius, RadiusPerSecond, RevealDuration.
```

## Skill versus randomness, depth, and paper prototyping
- Randomness before the decision (what spawns) adds variety; randomness after it (a hit roll) undermines the player's plan. Prefer the first, and give the player a way to mitigate the second.
- Depth comes from interaction: few rules that combine (pulse reveals, hunters react to pulse, fuel limits pulses) beat many isolated rules.
- Paper prototype: tokens for light, a grid, a die for spawns. If the decision is not interesting with tokens, juice will not save it.
- Exploit scan: try the mechanic at max, at zero, spammed, and combined with every other verb in the list.

## Quality checklist
- Mechanic is explainable in two sentences and demonstrable in seconds.
- At least two viable options exist at the decision point.
- Feedback is immediate and unambiguous.
- Tuning knobs are named, not buried in prose.

## Anti-patterns
- Mechanics that serve realism but not the loop.
- Hidden rules the player cannot infer.
- One option strictly dominating the rest.
- Randomness that overrides skill without recourse.
- Special-case exceptions instead of a consistent rule.
- Juice used to hide a weak decision; feedback amplifies a mechanic, it does not create one.
- Adding verbs to fix a boring loop instead of deepening the existing ones.

## Ready for the next skill
- [ ] Each loop step has a spec sheet with a named tuning-knob list.
- [ ] Each mechanic was played on paper or greybox with at least one outsider.
- [ ] Edge-case and exploit scan done, with results noted.
- [ ] Interaction list shows which mechanics touch which.

## Handoff
Mechanics and their tuning knobs go to `systems-design`, which connects them into resource flows and interacting systems.

## See also

Optional, if installed: gameplay-systems (the game-development plugin) for the broader discipline this skill applies. This skill stands on its own.
