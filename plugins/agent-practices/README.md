# squad-skills-agent-practices

Working practices for an AI agent serving one person: task decomposition, verifying before declaring done, asking versus assuming, minimal-change discipline, session handoff notes, delegation briefs, and skill authoring.

Version `0.1.0`, 7 skills.

## Install

```
copilot plugin install ./plugins/agent-practices
```

## Skills

| Skill | Purpose | Load when |
|-------|---------|-----------|
| `ask-vs-assume` | Deciding when to ask the user a question and when to proceed on a stated default - asking only for irreversible actions, materially divergent... | A request is ambiguous, a choice has no obvious answer, an action looks risky or irreversible, or you are tempted to ask something you could look up |
| `delegation-briefs` | Briefing sub-agents and other AI agents so they succeed - complete self-contained context, objective with a stop condition, constraints and... | About to spawn a sub-agent, hand a task to another AI, split work across parallel agents, or review what a delegate returned |
| `minimal-change-discipline` | Making the smallest change that fully solves the problem - no drive-by refactors, matching local conventions, noting but not fixing unrelated issues,... | Editing existing code, tempted to clean up nearby code, adding a dependency, or changing a shared interface |
| `session-handoff` | Writing durable handoff notes so a later AI session can resume work cold - what a note contains (goal, current state, decisions and why, files... | Context is filling up, stopping mid-task, finishing a work session, or starting a session that may continue earlier work |
| `skill-authoring` | Writing skills that change an AI agent's behaviour - one job per skill, a description whose Load-when trigger is the loading signal, encoding... | Creating, editing, reviewing, splitting, merging, or retiring a skill file for an AI agent |
| `task-decomposition` | Breaking work into small, independently verifiable steps - when to decompose, vertical slices over horizontal layers, exit checks per step, ordering... | A task touches more than about three files, has an unclear path, has several sequential steps, or feels too big to hold in one pass |
| `verify-before-done` | Treating done as evidence rather than belief - capturing a baseline before changes, running the narrowest relevant build, lint, and test checks,... | About to declare a task complete, mark a step done, summarise results, or hand work back to the user |

## Related plugins

Works well with: workflows, shared, knowledge. Squad also bundles error-recovery, iterative-retrieval and session-recovery, which these skills do not duplicate. Skills may mention other plugins in plain prose; each stands on its own.
