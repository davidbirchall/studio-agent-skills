---
name: understand-codebase
description: Recipe for getting oriented in an unfamiliar repository fast - read the README, manifests, and entry points, map the structure, find conventions, trace one request or feature end to end, run the build and tests to learn how things really work, record findings in a notes file for future sessions, identify risks and unknowns, use sub-agents for parallel exploration when it pays off, and stop once the intended change can be made with confidence. Names the skills to apply at each step, the exit check, and what to hand forward. Load when asked to explore, onboard to, audit, or explain a codebase, or before changing code you have not seen.
---

# Understand codebase

An ordered recipe, not a reference. Each named skill is optional: if its plugin is not installed, do the step anyway using general good practice. Do not copy skill content here; apply the skill and record only the output.

## When to use / when not to
- Use before the first change in an unfamiliar repo, when asked how something works, or when returning after a long gap.
- Not for a repo already summarised in a current notes file (read that instead), or for a question about one known function (just read it).

## Steps
1. Define the purpose of the exploration.
   - Goal: know what you need to learn, so you can stop.
   - Apply: ask-vs-assume (agent-practices plugin), task-decomposition (agent-practices plugin).
   - Exit: one line such as "I need to change X, so I must understand Y". Ask the user one question only if the target is truly ambiguous. Hand on: the question list.
2. Check for existing notes.
   - Goal: reuse earlier work.
   - Apply: session-handoff (agent-practices plugin), personal-knowledge-base (knowledge plugin).
   - Exit: any repo notes file, architecture docs, or decision records are read; stale parts are flagged, not trusted blindly.
3. Read the top layer.
   - Goal: purpose, stack, and commands in minutes.
   - Apply: rapid-domain-learning (knowledge plugin), source-summarisation (knowledge plugin).
   - Exit: README, package manifest or build file, lockfile type, config files, and entry points are read; language, framework, scripts, and runtime versions noted. Hand on: the stack summary.
4. Map the structure.
   - Goal: a mental map of modules and boundaries.
   - Apply: software-architecture (shared plugin), monorepo-management (platform-engineering plugin) if workspaces exist.
   - Exit: top-level directories, major modules, their dependencies, and where tests, config, and generated code live are listed; use code intelligence or symbol search over broad file reads. Hand on: the map.
5. Find the conventions.
   - Goal: match the house style.
   - Apply: typescript-conventions (shared plugin), code-review (shared plugin), git-workflows (platform-engineering plugin).
   - Exit: naming, error handling, test layout, commit style (from recent history), and lint rules are noted, with one example file for each.
6. Trace one path end to end.
   - Goal: see how the pieces connect in practice.
   - Apply: debugging (shared plugin) for stepping through behaviour, technical-documentation (shared plugin).
   - Exit: one real request, command, or feature is followed from entry through logic and storage to output, with file references. Hand on: the trace.
7. Run it.
   - Goal: learn reality, not documentation.
   - Apply: verify-before-done (agent-practices plugin), build-systems (platform-engineering plugin), software-testing-strategy (shared plugin).
   - Exit: install, build, and the test suite were run; results, failures, flakiness, and run time are noted; commands that differ from the README are recorded. Do not read env files or copy secrets into notes.
8. Use sub-agents for parallel exploration when worthwhile.
   - Goal: cover independent areas faster without flooding your own context.
   - Apply: delegation-briefs (agent-practices plugin).
   - Exit: only when there are three or more independent areas; each brief names the question, the paths, and a short report format; summaries are merged and spot-checked. A single connected trace stays with you.
9. Identify risks and unknowns.
   - Goal: surface what could hurt the change.
   - Apply: application-security (shared plugin), dependency-management (shared plugin), performance-engineering (shared plugin).
   - Exit: a short list of fragile areas, missing tests, outdated dependencies, hidden coupling, and questions that remain open.
10. Record findings.
   - Goal: make the next session faster.
   - Apply: knowledge-capture (knowledge plugin), documentation (knowledge plugin).
   - Exit: a notes file in the repo or user's chosen location holds the stack, commands, map, conventions, trace, risks, and unknowns, kept under about one page per topic.

## Stop criteria
- Stop when you can state the change you will make, the files it touches, the tests that cover it, and the main risk. More reading beyond that is procrastination.

## Skip rules
- Small repo (a few files): merge steps 3 to 6 into a single read-through.
- Notes file is fresh and matches the code: do steps 7 and 9 only.
- Never skip step 7 when the next action is a code change.

## Common failure modes
- Reading everything breadth-first with no question in mind.
- Trusting the README over the running build.
- Missing conventions, then writing code that does not fit.
- Notes that merely restate file names.
- Launching sub-agents for a task smaller than their setup cost.

## Checklist
- [ ] Exploration purpose written.
- [ ] Existing notes read.
- [ ] Stack, commands, and entry points known.
- [ ] Structure mapped; conventions noted.
- [ ] One path traced end to end.
- [ ] Build and tests run.
- [ ] Risks and unknowns listed.
- [ ] Notes file saved.
