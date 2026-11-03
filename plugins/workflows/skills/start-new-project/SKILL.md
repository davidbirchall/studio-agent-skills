---
name: start-new-project
description: Recipe for starting a project from an empty directory - clarify the goal and constraints with minimal questions, choose the stack from sensible defaults, scaffold, set up lint, format, type-check, and tests, add a CI baseline, handle environment variables and secrets safely, write a repo notes file for future sessions, build a first vertical slice, define done, and deliberately defer everything else. Names the skills to apply at each step, the exit check, and what to hand forward. Load when asked to create, scaffold, bootstrap, or start a new application, service, library, or tool.
---

# Start new project

An ordered recipe, not a reference. Each named skill is optional: if its plugin is not installed, do the step anyway using general good practice. Do not copy skill content here; apply the skill and record only the output.

## When to use / when not to
- Use when no code exists yet, or an existing repo is being reset to a clean foundation.
- Not for adding a feature to an existing project (use understand-codebase first, then ship-web-feature) or for a throwaway experiment where a single file is enough.

## Steps
1. Clarify goal and constraints.
   - Goal: enough shared understanding to choose a stack.
   - Apply: ask-vs-assume (agent-practices plugin), decision-making (knowledge plugin).
   - Exit: one paragraph covering what it does, who uses it, where it runs, and hard constraints (language, hosting, deadline). Ask at most one or two focused questions, only about choices that are costly to reverse; assume defaults for the rest and write the assumptions down. Hand on: the brief.
2. Choose the stack by defaults.
   - Goal: boring, well-supported choices.
   - Apply: software-architecture (shared plugin), technical-design (shared plugin), typescript-conventions (shared plugin), rapid-domain-learning (knowledge plugin) for unfamiliar tools.
   - Exit: language, framework, package manager (pnpm for JavaScript), test runner, and datastore chosen with a one-line reason each; prefer what the user already uses. Hand on: the stack note.
3. Scaffold.
   - Goal: a minimal structure that runs.
   - Apply: build-systems (platform-engineering plugin), monorepo-management (platform-engineering plugin) only if several deployable parts are certain, git-workflows (platform-engineering plugin).
   - Exit: git initialised, ignore file in place, official generator or smallest hand-made layout used, one command starts the app, and an initial commit exists.
4. Quality tooling.
   - Goal: fast local feedback.
   - Apply: software-testing-strategy (shared plugin), backend-testing or frontend-testing as relevant, typescript-conventions (shared plugin).
   - Exit: scripts exist and pass for lint, format, type-check, and test, each runnable by one command; strict type settings on from the start; one real passing test. Hand on: the script names.
5. Environment and secrets.
   - Goal: safe configuration from day one.
   - Apply: environment-configuration and secrets-management (platform-engineering plugin), application-security (shared plugin).
   - Exit: an example env file with placeholder values committed; real env files ignored; config read and validated in one place; no secret ever written to the repo or notes.
6. CI baseline.
   - Goal: the same checks run automatically.
   - Apply: ci-cd-workflows (platform-engineering plugin), containerization (platform-engineering plugin) only if deploying a container.
   - Exit: a pipeline runs install with a frozen lockfile, lint, type-check, test, and build; it passes on the main branch. Hand on: the workflow file.
7. Repo notes file.
   - Goal: let a future session get oriented in a minute.
   - Apply: knowledge-capture (knowledge plugin), technical-documentation (shared plugin), session-handoff (agent-practices plugin).
   - Exit: a short notes file at the repo root with purpose, stack, commands, layout, conventions, assumptions from step 1, and open questions; plus a README with run instructions.
8. First vertical slice.
   - Goal: prove the stack end to end with the thinnest real feature.
   - Apply: task-decomposition (agent-practices plugin), minimal-change-discipline (agent-practices plugin), verify-before-done (agent-practices plugin).
   - Exit: one path works from input through logic and storage to output, with a test, and runs in CI. Hand on: the working slice.
9. Define done and defer the rest.
   - Goal: stop scaffolding and start building.
   - Apply: decision-making (knowledge plugin).
   - Exit: a definition of done for the initial milestone is in the notes, and a "not yet" list is written.

## What not to set up yet
- Microservices, message queues, caches, or multi-region deployment.
- Monorepo tooling for a single package.
- Custom design systems, plugin architectures, or generic abstractions without a second use case.
- Production observability stacks, before there is something in production.

## Skip rules
- Library or script: skip the datastore, containers, and most of step 6 beyond test and build.
- User supplied a template or stack: skip step 2 and follow the template.
- Never skip the notes file, the test script, or secret handling.

## Common failure modes
- Over-asking questions that have safe defaults.
- Gold-plating tooling before any feature works.
- Committing a real env file or key.
- Stack chosen for novelty rather than fit.
- No notes, so the next session rediscovers every decision.

## Checklist
- [ ] Brief and assumptions written.
- [ ] Stack chosen with reasons.
- [ ] One command each: run, lint, type-check, test, build.
- [ ] Secrets handled; example env file only.
- [ ] CI green on the main branch.
- [ ] Repo notes file and README present.
- [ ] First vertical slice working with a test.
- [ ] Done definition and "not yet" list recorded.
