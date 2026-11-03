# squad-skills

A repository of reusable skills, written to guide an AI agent working for one individual, not a team or organisation, for [Squad](https://github.com/bradygaster/squad), the AI team framework for GitHub Copilot.

This is a self-contained, theoretical project for exploring how a domain-organised skill set can work. It is not tied to any employer's architecture, tooling or internal packages.

## Layout

| Path | Purpose |
|------|---------|
| `plugins/<domain>/` | One Copilot CLI plugin: `plugin.json`, `README.md`, `skills/<name>/SKILL.md` |
| `.github/plugin/marketplace.json` | Marketplace catalog listing every plugin |
| `scripts/install-stack.sh` | Installs a named stack of plugins |
| `.squad/skills/` | This repo's own team-earned skills (not distributed) |
| `.github/skills/` | Skills bundled by Squad (managed by `squad init` / `squad upgrade`; don't edit) |
| `.squad/` | Team state: roster, routing, decisions, charters |
| `.github/agents/squad.agent.md` | Squad coordinator (managed by Squad) |

## Plugins

One plugin per domain under `plugins/`, each with its own `plugin.json`, version and README listing its skills.

### Engineering

| Plugin | Skills | Summary |
|--------|--------|---------|
| [`squad-skills-shared`](plugins/shared/README.md) | 13 | Shared engineering capabilities that apply across frontend, backend, AI and game development |
| [`squad-skills-frontend`](plugins/frontend/README.md) | 23 | Frontend skills for Vue 3 / Nuxt 3 / TypeScript |
| [`squad-skills-backend`](plugins/backend/README.md) | 24 | Backend skills for Node.js / NestJS / Fastify / Prisma / TypeScript |
| [`squad-skills-data`](plugins/data/README.md) | 7 | Data engineering skills distinct from general backend work |
| [`squad-skills-platform-engineering`](plugins/platform-engineering/README.md) | 11 | Provider-neutral DevOps and platform engineering skills |
| [`squad-skills-ai-engineering`](plugins/ai-engineering/README.md) | 16 | AI engineering skills for LLM-powered applications and agent systems |

### Game development

| Plugin | Skills | Summary |
|--------|--------|---------|
| [`squad-skills-game-development`](plugins/game-development/README.md) | 24 | Game development engineering skills for Unity and C# |
| [`squad-skills-creative-technology`](plugins/creative-technology/README.md) | 8 | Creative technology and asset pipeline skills for Unity |

### Process

| Plugin | Skills | Summary |
|--------|--------|---------|
| [`squad-skills-product`](plugins/product/README.md) | 6 | Product process skills |
| [`squad-skills-game`](plugins/game/README.md) | 7 | Engine-agnostic game design skills |
| [`squad-skills-creative`](plugins/creative/README.md) | 6 | Creative-process skills for games, film, animation, books, and brands |
| [`squad-skills-production`](plugins/production/README.md) | 7 | Production-process skills for software, games, and creative projects |
| [`squad-skills-agent-practices`](plugins/agent-practices/README.md) | 7 | Working practices for an AI agent serving one person |
| [`squad-skills-business`](plugins/business/README.md) | 5 | Solo-business skills: licensing, privacy, pricing, payments, analytics |
| [`squad-skills-workflows`](plugins/workflows/README.md) | 9 | End-to-end recipe skills that sequence the other plugins |
| [`squad-skills-knowledge`](plugins/knowledge/README.md) | 8 | Domain-agnostic knowledge-work skills |

Plugins are independent. A skill may mention skills in other plugins in a short "See also" note; the one hard dependency is that `frontend-architecture` and `frontend-design-systems` refer to `typescript-conventions` in the shared plugin.


## Skill format

Each skill is a directory containing a `SKILL.md`:

```
.squad/skills/{skill-name}/SKILL.md
```

```markdown
---
name: skill-name
description: What the skill does and when an agent should load it.
---

# Instructions
...
```

Rules:
- The directory name matches `name`.
- The description states when to use the skill.
- One purpose per skill.

## Team

| Member | Role |
|--------|------|
| David Birchall | Product Owner / Creative Director (human) |
| Lead | Design review, triage, scope |
| Skill Author | Writes skills |
| Skill Tester | Validates skills |
| Docs | README and catalog |
| Scribe, Ralph, Rai, Fact Checker | Built-in support members |

Routing rules are in `.squad/routing.md`.

## Install

Single plugin:

```
copilot plugin install ./plugins/frontend
copilot plugin list
```

### Stacks

Copilot plugin marketplaces have no native bundle concept, so stacks are a script over the plugins:

| Stack | Plugins |
|-------|---------|
| `web` | shared, frontend, backend, data, platform-engineering, agent-practices, workflows |
| `game` | shared, game-development, creative-technology, game, agent-practices, workflows |
| `ai` | shared, backend, ai-engineering, platform-engineering, agent-practices, workflows |
| `process` | product, game, creative, production, knowledge, business |

```
scripts/install-stack.sh web        # or game, ai, process, all
scripts/install-stack.sh web --marketplace
```

`--marketplace` installs `<plugin>@squad-skills` from the catalog in `.github/plugin/marketplace.json` (register the marketplace first with `copilot plugin marketplace add <path-or-repo>`; some organisations block marketplace sources by policy, in which case use the local-path install).

Then run `/skills list` in a Copilot CLI session to confirm the skills are loaded. Local plugins are cached, so re-run the install command to pick up changes.

## Contributing

See [docs/skill-design-guide.md](docs/skill-design-guide.md) for how to design, write and check skills.

1. Open an issue with the `squad` label; the Lead triages it.
2. Work on a `squad/{issue-number}-{slug}` branch.
3. Open a PR referencing the issue (`Closes #N`).
