---
name: level-design
description: Design levels, maps, encounters, and puzzles that deliver the intended pacing - layout flow, teaching moments, landmarks and guidance, encounter composition, set pieces, and greybox (blockout) iteration. Load when planning a level or map, building a blockout, designing an encounter or puzzle, teaching a mechanic in space, or reviewing level readability.
---

# Level design

Follows `progression-design`. Next: `balance`.

## Purpose
Create spaces and sequences where the player exercises mechanics, feels the intended pacing, and always knows where to go and what to try.

## Inputs
- Pacing outline, unlock table, and onboarding sequence from `progression-design`.
- Mechanics from `mechanic-design`.

## Framework
1. **Level goal**: one sentence on what the player learns or feels, and which mechanic it features.
2. **Beat sheet**: ordered beats (arrival, teach, test, twist, climax, rest, exit), each with intended duration.
3. **Layout and flow**: sketch the route, branches, loops, and chokepoints. Decide the critical path and optional detours.
4. **Guidance**: use landmarks, lighting, contrast, lines, and level geometry to guide before using markers or text. Players should be able to find the objective without prompts.
5. **Teaching in space**: introduce a mechanic where failing is safe, repeat it with variation, then combine. Show before telling.
6. **Encounters**: define composition (enemies, hazards, puzzle parts), space, player options, and the expected solution range. Offer more than one approach.
7. **Risk and reward placement**: put optional rewards behind visible risk. Place checkpoints so failure repeats little.
8. **Greybox (blockout) first**: build with untextured simple shapes to test scale, flow, and sight lines before art. Iterate: playtest, observe where players stall, get lost, or skip content, adjust, retest. Art comes after layout is stable.

## Output
```
Level: <name>   Goal: <learn / feel>   Featured mechanic:
Target duration:
Beat sheet: beat | location | what the player does | intended feeling
Layout sketch: <route, branches, chokepoints>
Guidance cues:
Encounters: <composition | space | solutions>
Rewards and checkpoints:
Greybox test notes: <where players stalled, got lost, or skipped>
```

## Worked example (Lanternfall, District 1, "The Drowned Stair")
```
Level: The Drowned Stair   Goal: learn the pulse   Featured mechanic: Light pulse
Target duration: 6-8 minutes
Beat | Location       | What the player does          | Feeling
Arrive | Lamp-post    | Sees a lit stair going down   | Safe
Teach  | Wet landing  | Pulse reveals a gap in floor  | Curiosity
Test   | Broken bridge| Pulse twice to find the path  | Mild pressure
Twist  | Flooded hall | Hunter reacts to the pulse    | Tension
Climax | Pump room    | Sneak and pulse under chase   | Dread, release
Rest   | Second lamp  | Bank fuel, optional tool      | Relief
```
Metrics (set in the blockout, then keep): player speed, jump or step height, safe gap width, pulse radius at 1 second, sight line to the next landmark. Write them down so every room uses the same numbers.

## Readability, encounters, and playtest notes
- Landmarks: one tall or lit feature per room visible from the entrance, so the player can state where they are going.
- Introduce, develop, twist, conclude: each mechanic gets a safe teach room, a pressured test, a combination, then a payoff.
- Encounter template: threat | space | player options (at least two) | intended solution | fail state.
- Blockout first: grey boxes with scale metrics, playable end to end before any art. Mark where testers hesitated, retraced their steps, or skipped optional space.
- Playtest notes template: tester | time per beat | where lost | where died | quote | fix.

## Quality checklist
- Level has one clear goal and a defined beat order.
- A new player finds the path without a marker.
- Each encounter has more than one viable approach.
- Checkpoints and rests follow high-tension beats.
- Greybox was tested before art started.

## Anti-patterns
- Beautiful spaces with no gameplay purpose.
- Mazes mistaken for challenge.
- Introducing and testing a mechanic in the same moment.
- Dead ends with no payoff.
- Polishing art before layout is playtested.
- Relying on a waypoint marker to cover for poor layout.
- Inconsistent metrics between rooms, so jumps or gaps feel unfair.

## Ready for the next skill
- [ ] Blockout is playable end to end and tested with new players.
- [ ] Beat durations measured, not guessed, and match the target.
- [ ] Encounter values (counts, damage, timers) listed in one place.
- [ ] Notes list where players stalled or got lost, with fixes done or logged.

## Handoff
Playable levels and encounters, with their tuning values, go to `balance` for tuning and structured playtesting.
