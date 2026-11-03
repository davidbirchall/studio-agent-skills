---
name: systems-design
description: Design how game mechanics connect into systems - resources, economy sinks and faucets, feedback loops (positive and negative), crafting, inventory, combat and AI interactions, and emergent behaviour. Covers system maps and economy flow. Load when designing an economy, resource model, crafting or loot system, or checking whether systems reinforce or break each other.
---

# Systems design

Follows `mechanic-design`. Next: `progression-design`.

## Purpose
Combine individual mechanics into a coherent whole where resources flow predictably and interactions produce intended dynamics.

## Inputs
- Mechanics and tuning knobs from `mechanic-design`.
- Loops and goals from `game-design`.

## Framework
1. **Inventory of systems**: list each system (combat, crafting, economy, AI, social) and its one-line purpose.
2. **Resources**: for each resource note type (currency, energy, time, information, health), source, use, cap, and whether it is visible.
3. **Faucets and sinks**: faucets add a resource, sinks remove it. A healthy economy keeps them in rough balance over the intended play horizon. Faucets without sinks cause inflation; sinks without faucets cause stalling.
4. **Feedback loops**: positive loops amplify (winner gets stronger), negative loops stabilise (leader is slowed). Pair them deliberately; unchecked positive loops produce runaway outcomes.
5. **System map**: draw nodes (systems, resources) and arrows (flows, dependencies). Mark each loop as reinforcing or balancing.
6. **Interactions and emergence**: ask what happens when two systems combine at extremes. Decide which emergent behaviours to support and which to constrain.
7. **Exploit pass**: look for infinite loops, trade arbitrage, and ways to skip intended friction.
8. **Transparency**: decide what the player sees of the system (numbers, hints) versus discovers.

## Output
```
Systems: <name: purpose>
Resources: <name | type | faucet | sink | cap | visible?>
Loops: <description | reinforcing or balancing | controlled by>
System map: <nodes and arrows, text or diagram>
Intended emergence / constrained emergence:
Exploit risks and mitigations:
Tuning knobs (merged list, handed to balance):
```

## Worked example (Lanternfall)
```
Resource | Type   | Faucet               | Sink                         | Cap | Visible
Light    | health | Fuel pickups, lamps  | Pulse, hazards, tool use     | 10  | yes
Fuel     | currency| Exploration, drops  | Refill light, buy tools      | 20  | yes
Echoes   | meta   | Finishing a descent  | Unlock districts and tools   | none| yes
Loops:
  Fuel -> more pulses -> find more fuel          (reinforcing; capped by Light cap 10)
  Low light -> hunters close in -> more light lost (reinforcing; limited by lamp-posts)
  Deeper = richer fuel but harder hazards         (balancing)
```
Interaction matrix: mark each cell with R (reinforces), C (conflicts), or - (none).
```
            | Pulse | Hunters | Fuel | Tools
Pulse       |   -   |    C    |  R   |  R
Hunters     |   C   |    -    |  C   |  -
Fuel        |   R   |    C    |  -   |  R
Tools       |   R   |    -    |  R   |  -
```
Every C and R cell needs a sentence: is it intended, constrained, or a bug.

## Economy modelling and tuning knobs
Faucet/drain check over the intended horizon: expected income per descent versus expected spend per descent. Target a small surplus early (growth) and near parity late (decisions stay tight). Model it in a spreadsheet for 1, 10, and 50 runs. Dominant strategy scan: for each resource, ask whether the best play is to hoard, to spam, or to ignore it; if so, one of the loops is mis-set. Keep a merged knob list (name, current value, safe range, owner system) for `balance`.

## Quality checklist
- Every resource has at least one sink and one faucet.
- Every positive loop has a limiter or a deliberate endpoint.
- Systems can be described without reference to implementation.
- Exploit pass was done with specific scenarios.

## Anti-patterns
- Currencies multiplied without distinct purpose.
- Economy tuned only at launch, with no long-term sink.
- Systems that never interact, so the game feels like parallel minigames.
- Complexity for its own sake; a system that supports no pillar.
- Relying on players to avoid exploits.
- Hidden multipliers the player cannot observe, so cause and effect is lost.
- Balancing each system alone and never testing them together at extremes.

## Ready for the next skill
- [ ] Resource table complete, with faucet, sink, and cap for each.
- [ ] Interaction matrix filled in and each conflict explained.
- [ ] Exploit pass done with named scenarios, and mitigations listed.
- [ ] Merged tuning-knob list has safe ranges.
- [ ] Per-run income and spend modelled for early, mid, and late play.

## Handoff
System map and resource model go to `progression-design`, which paces how the player gains power, content, and mastery over time.

## See also

Optional, if installed: gameplay-systems (the game-development plugin) for the broader discipline this skill applies. This skill stands on its own.
