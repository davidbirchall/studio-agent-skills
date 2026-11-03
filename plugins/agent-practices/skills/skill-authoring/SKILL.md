---
name: skill-authoring
description: Writing skills that change an AI agent's behaviour - one job per skill, a description whose Load-when trigger is the loading signal, encoding opinions and thresholds rather than common knowledge, terse imperative bodies of 60-100 lines, examples, anti-patterns and closing checklists, independence between skills, no project-specific coupling, testing a skill on a real task, pruning dead skills, and version flags. Load when creating, editing, reviewing, splitting, merging, or retiring a skill file for an AI agent.
---

# Skill authoring

A skill is a small, loadable rulebook. It earns its place only if an agent behaves measurably better with it than without. Pair with `minimal-change-discipline` for edits to existing skills.

## One job per skill
- State the job in one sentence. If it needs "and" between unrelated jobs, split it.
- Split by when it is needed, not by topic size. A skill loaded for every task must be tiny; a niche skill can be longer.
- Merge two skills that are always loaded together and never useful apart.

## Description is the loading signal
- The agent decides whether to load from the description alone. Write it for that decision.
- One dense paragraph: the topics covered, then a final sentence "Load when ..." listing concrete triggers (situations, requests, symptoms), not abstract areas.
- Use words the user or task would actually contain. "Load when a test fails intermittently" beats "Load for quality topics".
- Over-broad triggers load the skill everywhere and waste context; under-specific ones never load.

## Encode opinions, not common knowledge
- The model already knows what unit tests are. Tell it what it does wrong: your thresholds, your order of operations, your defaults.
- Prefer a number or rule to an adjective: "split above ~10 files" not "keep changes small".
- Every line should change a decision. Delete lines that restate what any competent agent would do.
- Take a side where reasonable people differ, and give the one-line reason.

## Form
- Frontmatter: only `name` (equal to the folder name) and `description`.
- Body 60-100 lines. Short sections with imperative bullets: "Run X", "Never Y".
- Include at least one concrete example and one short template in a code block, generic and not tied to any product.
- Include an Anti-patterns section (the failure modes you actually see) and a closing Checklist the agent can tick through.
- ASCII only, no emojis, no marketing tone, no history of why the skill exists.

```
---
name: folder-name
description: Topics ... . Load when <trigger>, <trigger>, or <trigger>.
---
# Title
## Rule group
- imperative rule with threshold
## Anti-patterns
## Checklist
```

## Independence
- A skill must work when loaded alone. Reference sibling skills only as optional pointers ("pair with the debugging skill for ..."), never as required steps.
- Do not duplicate another skill's content; point to it and keep your own rule short.
- No project names, repo paths, team names, ticket systems, or private URLs. If it only makes sense in one codebase, it belongs in that repo's notes, not a skill.
- No tool-specific commands unless the skill is about that tool; show the shape and say "adapt to the project".

## Test it
- Pick a real task the skill targets. Run it once without the skill, once with. Compare behaviour, not prose quality.
- Pass: the agent now makes the decision the skill prescribes (asks the right question, runs the check, parks the extra work).
- If nothing changed, the skill is generic or too long to be followed. Cut it or sharpen the rules.
- Re-test after edits that touch thresholds or triggers.

## Maintain
- Prune skills no one loads or whose advice is now default behaviour. Dead skills cost description tokens every session.
- When content depends on a tool or API version, add a flag: "Verify against the installed version" and name what to check.
- Fix a skill when a real failure shows a missing or wrong rule; do not accrete speculative rules.
- Keep wording consistent with sibling skills in the same repository: heading style, section order, tone.

## Anti-patterns
- Encyclopedic overviews that teach concepts.
- Descriptions that say what the skill is, not when to load it.
- Hard dependencies ("first load skill A, then B").
- Rules with no threshold, example, or check.
- A skill written once and never run on a real task.

## Checklist
- One job; description ends with "Load when ...".
- Opinions and thresholds, not textbook content.
- 60-100 lines, example, template, anti-patterns, checklist.
- Standalone, no project coupling, only optional sibling pointers.
- Tested on a real task; version flags where needed.
