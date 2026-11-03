---
name: balance
description: Tune a game to be fair and engaging - define balance goals, identify tuning knobs, compare options with spreadsheets and simulation, run structured playtests, read data and feedback, and iterate with controlled changes. Covers dominant strategies, difficulty and economy tuning, and PvP versus PvE balance. Load when tuning numbers, fixing an overpowered or useless option, adjusting difficulty or economy, or planning and analysing playtests.
---

# Balance

Follows `level-design`. Last skill in the chain; findings loop back to the earlier skill that owns the issue.

## Purpose
Make intended choices viable and the intended difficulty and economy hold true in real play.

## Inputs
- Tuning knobs from `mechanic-design` and `systems-design`.
- Difficulty curve from `progression-design`; encounters from `level-design`.
- Playable build and playtest data.

## Framework
1. **Balance goals**: state what balanced means here. Fairness between players, parity of options, a target win rate, target time to complete, or an economy that stays in range.
2. **Choose the kind**: symmetric (identical options), asymmetric (different options, similar viability), PvE (challenge curve), or economy balance. Each needs different tests.
3. **Reference point**: pick a baseline (typical option, typical player). Express other options relative to it, such as cost per unit of value.
4. **Model before play**: put numbers in a spreadsheet or small simulation to find outliers and dominant strategies quickly, then confirm in play.
5. **Playtest loop**: define the question, run sessions with fresh players, observe behaviour, collect data (win rates, deaths per area, time per section, option pick rates) and feedback, form a hypothesis, change one thing, retest.
6. **Read the signal**: heavy use of one option indicates it dominates or is the only clear choice; low use may mean weak, unclear, or poorly taught. Players report symptoms accurately but causes unreliably.
7. **Tune in small steps**: change one knob, record why, keep a changelog, and revert if unclear. Nerf and buff in moderate steps to avoid overcorrection.
8. **Difficulty options**: if offered, vary a few legible knobs (damage, resources, time) rather than rewriting rules.
9. **Live games**: use telemetry; keep a change log of old value, new value, and reason.

## Output
```
Goals: <metric | target range>
Knobs and baseline values:
Hypotheses: <observation -> suspected cause -> change>
Playtest log: build | question | participants | data | findings
Change log: knob | old -> new | reason | result
Remaining issues and owner skill:
```

## Worked example (Lanternfall)
```
Goal: 40-60 percent of new players clear District 1 within 5 attempts.
Observation: pulse picked in 95 percent of runs; shutter tool in 8 percent.
Hypothesis: pulse cost is too low relative to its value, so no other tool competes.
Change: PulseCostPerSecond 1.0 -> 1.4 (one knob). Retest with 8 fresh players.
Result: pulse use 70 percent, shutter 22 percent, clear rate 48 percent. Keep.
```
Spreadsheet columns (one row per option):
```
Option | Cost | Value metric | Value per cost | Pick rate | Win rate when picked | Notes
```
Store tuning data as a plain-text table (CSV or similar) under version control, with the build number in each playtest log, so a change can be traced and reverted.

## Detection, simulation, and change log
- Dominant strategy detection: an option with pick rate far above peers and a win rate above the target band is dominant; an option with low pick and low win rate is weak or unclear. Low pick but high win rate suggests it is under-taught.
- Time-to-kill and time-to-clear: record per encounter; outliers show where difficulty spikes.
- Simulation: run a simple script or spreadsheet over many runs with each strategy to see the range of outcomes before human testing.
- Sample sizes: a few players reveal causes, many runs reveal rates. Do not quote a rate from five sessions.
- Change log: record what changed, the old and new values, and the reason, so later sessions do not re-tune blindly (publish patch notes only if the user asks).

## Quality checklist
- Each change maps to a goal and a named hypothesis.
- Only one major variable changes between tests.
- Testers include players new to the build.
- Data and observed behaviour agree, or the gap is explained.

## Anti-patterns
- Tuning from the designer's own skill rather than target players.
- Changing many knobs at once.
- Balancing by feedback alone, or by data alone.
- Perfect symmetry pursued at the cost of identity.
- Using numbers to patch a design flaw; send it back to `mechanic-design` or `systems-design`.
- Treating balance as done at launch.
- Quoting percentages from tiny samples as if they were facts.
- Nerfing the popular option when the real cause is that its alternatives are unclear.

## Ready to close a tuning pass
- [ ] Every goal metric is inside its target range, or the gap has an owner skill.
- [ ] The changelog and tuning data are saved with the build number.
- [ ] A final playtest with fresh players confirmed the result.
- [ ] Structural issues are logged back to the skill that owns them.

## Handoff
Structural problems return to `mechanic-design`, `systems-design`, `progression-design`, or `level-design`. Strategic concerns return to `game-design`.
