# Architecture: @davidbirchall/squad-skills Library

This document explains the plugin-based architecture, distribution model, and design patterns for the centralized Squad skills and plugins library.

## Overview

**@davidbirchall/squad-skills** is a **reusable plugin library** organized by domain. It contains:

1. **19+ coordination skills** (`.github/skills/`) — Decision frameworks and protocols for how Squad coordinators and agents work together
2. **15+ domain plugins** (`plugins/`) — Skill collections organized by engineering discipline, game development, creative process, and business practices
3. **Stack installers** — Pre-configured bundles of plugins for common use cases (web, game, ai, process)

It is **NOT** a monolithic toolkit. Each plugin is independent and can be installed in any project that needs it.

## Distribution Model: Per-Project Installation

Each of your projects installs the plugins it needs:

```
my-squad-project/
├── package.json                              (depends on @davidbirchall/squad-skills)
├── node_modules/@davidbirchall/squad-skills/ (contains all plugins + skills)
└── Copilot CLI loads plugins from here
```

**Key principle:** Plugins are installed **per-project**, not globally. This gives each project:
- ✅ Version control over which plugin versions it uses
- ✅ Independence from other projects' plugin updates
- ✅ Ability to pin versions in package.json
- ✅ Easy rollback if a plugin update breaks something

## What Problems Does It Solve?

### Problem 1: Inconsistent Coordinator Behavior
**Without:** Each project invents its own routing logic and error-recovery patterns.

**With:** All projects load the same coordination skills, ensuring consistent behavior.

### Problem 2: Duplicated Domain Expertise
**Without:** You write the same "Vue component patterns" guide in every project.

**With:** Write it once as a plugin. All projects load it when they need it.

### Problem 3: Organizational Scaling
**Without:** You manage skills manually across 12+ projects. Updates are error-prone.

**With:** Bump the version in `package.json`, reinstall plugins, and all projects are in sync.

### Problem 4: Single Developer Scaling
**Without:** As you add more projects and refine your practices, keeping them aligned is manual.

**With:** Centralized library + per-project installation = scale without overhead.

## Architecture Layers

### Layer 1: This Repository (Source of Truth)

```
studio-agent-skills/
├── .github/skills/           ← 19+ coordination skills (Squad protocols)
├── plugins/                  ← 15+ domain plugins
│   ├── frontend/
│   ├── backend/
│   ├── game-development/
│   └── ... (12 more)
├── package.json              ← Version metadata
├── scripts/install-stack.sh  ← Convenience installer
└── .github/workflows/        ← Auto-publish on tag
```

**Responsibility:** Author, version, publish skills and plugins.

### Layer 2: Distribution (GitHub Packages)

```
Published as: npm package @davidbirchall/squad-skills

npm install @davidbirchall/squad-skills
```

Contains the complete library: all coordination skills + all plugins.

**Responsibility:** Provide reliable, versioned access via npm.

### Layer 3: Individual Projects (Your 12+ Squad Projects)

Each project independently installs and pins plugins:

```
my-squad-project/
├── package.json              ← Pins @davidbirchall/squad-skills@^1.1.0
├── node_modules/
│   └── @davidbirchall/squad-skills/
│       ├── .github/skills/   ← Available to load via Copilot CLI
│       └── plugins/          ← Available to install via copilot plugin install
├── .squad/                   ← Project-specific config (team.md, routing.md, agents)
└── (installed plugins are cached by Copilot CLI)
```

**Responsibility:** Install the package, choose which plugins to load, keep in sync.

## Plugins vs Coordination Skills

This library contains two types of resources:

### Coordination Skills (`.github/skills/`)

- **Scope:** How Squad coordinators and agents work together
- **Audience:** All projects, all agents
- **Examples:** Routing decisions, error recovery, reviewer protocols, decision capture
- **Discovery:** Loaded by coordinator on-demand
- **Reusability:** Universal (used by every agent across all projects)
- **Installation:** Shipped with `@davidbirchall/squad-skills` npm package; available in `.github/skills/`

### Domain Plugins (`plugins/`)

- **Scope:** Engineering expertise, domain knowledge, best practices per discipline
- **Audience:** Agents working in that domain
- **Examples:** Vue component patterns, NestJS architecture, game design, creative process
- **Discovery:** Marketplace or local file path
- **Reusability:** Per-domain (frontend engineer loads frontend plugin; game designer loads game-development plugin)
- **Installation:** `copilot plugin install ./node_modules/@davidbirchall/squad-skills/plugins/frontend`

**Think of it this way:**
- **Skills** teach "how we work as a team"
- **Plugins** teach "how to build X in our stack"

## Versioning Strategy

### Semantic Versioning

```
1.1.0
↑ ↑ ↑
│ │ └─ PATCH: Typo fix, clarification (safe to auto-update)
│ └─── MINOR: New skill added, new plugin, backwards compatible (review but safe)
└───── MAJOR: Breaking change to a skill contract or plugin behavior (review carefully)
```

### Release Process

1. Make changes to skills (`.github/skills/`) or plugins (`plugins/`)
2. Update version in affected `plugin.json` files
3. Update `package.json` if needed (matches highest plugin version or breaking change)
4. Commit and push
5. Create a git tag: `git tag v1.1.0`
6. GitHub Actions automatically publishes to GitHub Packages
7. Projects update with `npm update @davidbirchall/squad-skills`

## File Structure Explained

```
studio-agent-skills/
│
├── .github/skills/                       ← Coordination skills (published with npm package)
│   ├── coordinator-response-mode/SKILL.md
│   ├── reviewer-protocol/SKILL.md
│   ├── agent-collaboration/SKILL.md
│   └── ... (16 more skills)
│
├── plugins/                              ← Domain plugins (published with npm package)
│   ├── shared/
│   │   ├── plugin.json
│   │   ├── README.md
│   │   └── skills/
│   ├── frontend/
│   ├── backend/
│   ├── game-development/
│   └── ... (12 more plugins)
│
├── scripts/
│   └── install-stack.sh                  ← Convenience installer for plugin bundles
│
├── docs/
│   ├── ARCHITECTURE.md                   ← This file
│   ├── SETUP_GUIDE.md                    ← Per-project installation instructions
│   └── skill-design-guide.md             ← How to write skills
│
├── package.json                          ← Package metadata & version
├── README.md                             ← Quick start & plugin catalog
├── CONTRIBUTING.md                       ← How to add/improve skills & plugins
└── .github/workflows/
    └── publish-skills.yml                ← Auto-publish on git tag
```

The `"files"` field in `package.json` controls what npm publishes:

```json
"files": [
  ".github/skills",
  "plugins",
  "scripts/install-stack.sh",
  "README.md"
]
```

Everything else (`.squad/`, `docs/`, internal templates) stays in the repo but doesn't ship in the npm tarball.

## Use Cases

### Use Case 1: New Project Setup

```bash
cd my-new-squad-project
npm init -y
npm install --save-dev @davidbirchall/squad-skills
copilot plugin install ./node_modules/@davidbirchall/squad-skills/plugins/frontend
copilot plugin install ./node_modules/@davidbirchall/squad-skills/plugins/backend
# Get 40+ skills immediately; no need to invent your own
```

### Use Case 2: Consistency Across All Projects

1. All 12 projects depend on `@davidbirchall/squad-skills@^1.1.0`
2. All coordinators behave consistently (same routing logic, error recovery)
3. All frontend engineers have access to the same component patterns
4. All game developers follow the same design process
5. Update once → all projects pick it up on `npm update`

### Use Case 3: Major Update to Your Practices

```bash
# Update error-recovery/SKILL.md with a better pattern
# Bump version in package.json to 1.2.0
git tag v1.2.0 && git push origin v1.2.0
# GitHub Actions publishes automatically

# In all projects:
npm update @davidbirchall/squad-skills
# copilot plugin install ... if plugin versions changed
```

All projects now use the new pattern instantly.

### Use Case 4: Project-Specific Plugin Variant

If Project A needs a stricter version of a plugin:

```bash
# In Project A
copilot plugin install ./node_modules/@davidbirchall/squad-skills/plugins/frontend
# Edit the cached plugin locally (temporary customization)
# Or keep a local override in .squad/skills/
```

Other projects continue using the standard version from npm.

## Installation Flow Explained

### First Time (Developer Perspective)

```bash
# 1. Add the package to project
npm install --save-dev @davidbirchall/squad-skills

# 2. Choose plugins to install
copilot plugin install ./node_modules/@davidbirchall/squad-skills/plugins/frontend

# 3. Copilot CLI caches the plugin locally and loads it
copilot plugin list  # Verify it's installed
```

### Updating (Quarterly or As-Needed)

```bash
# 1. Update the npm package
npm update @davidbirchall/squad-skills

# 2. Reinstall plugins to pick up new versions
copilot plugin install ./node_modules/@davidbirchall/squad-skills/plugins/frontend

# 3. Done—Copilot CLI now uses the latest plugin version
```

## Skills vs Plugins vs Capabilities — Clear Boundaries

| Aspect | Skills | Plugins | Capabilities |
|--------|--------|---------|--------------|
| **Purpose** | Teach how to coordinate | Teach domain expertise | Define agent boundaries |
| **Scope** | Universal team behavior | Role-specific knowledge | Single agent rules |
| **Audience** | All coordinators & agents | Agents in that domain | One agent |
| **Discovery** | Loaded by coordinator | Marketplace or local path | In agent's charter.md |
| **Example** | "How do we route work?" | "Vue 3 component patterns" | "You review; you don't write" |
| **Storage** | `.github/skills/` | `plugins/` or marketplace | `.squad/agents/{name}/charter.md` |
| **Reusability** | 100% across all projects | Per-domain (not all agents load it) | Only applies to one agent |

**This library is both Skills + Plugins.** That's intentional and correct.

## Maintenance Model

### You (Single Developer)

1. Refine practices as you work
2. When a pattern is stable, add it as a skill
3. When you specialize in a domain, add a plugin
4. Version releases using semver
5. Update npm package regularly

### Your Projects (12+)

1. Install `@davidbirchall/squad-skills` once
2. Choose which plugins to load per-project
3. Stay in sync via periodic `npm update`
4. Can override locally if a project needs a variant
5. Always have access to latest coordination skills

### Future: Marketplace (Optional)

If you want to share plugins beyond your personal projects:

```bash
copilot plugin marketplace add @davidbirchall/squad-skills
copilot plugin install squad-skills/frontend --marketplace
```

But this is optional. Per-project npm installation is fully sufficient for your use case.

## Why Per-Project Installation?

You might wonder: "Why not install globally and have all projects reference it?"

**Because:**

1. **Version independence** — Project A can use v1.1.0 while Project B uses v1.2.0 without conflict
2. **Offline access** — Projects work even if the npm registry is down (plugins are in node_modules)
3. **Rollback safety** — Revert package.json and rebuild node_modules if a version breaks something
4. **Explicit control** — Project's package.json declares exactly what it depends on (not ambient global state)
5. **Team collaboration** — When you share a project, all dependencies are reproducible (anyone running `npm install` gets the same versions)

This is the **npm standard distribution model**. It's proven, scalable, and works across solo dev → teams.

## Summary

You've structured your library correctly as:

✅ A centralized npm package containing both coordination skills and domain plugins
✅ Versioned with semantic versioning
✅ Distributed via GitHub Packages
✅ Installed per-project using standard npm tooling
✅ Plugins loaded selectively via Copilot CLI per-project

This gives you **consistency at scale** (all projects follow the same coordination patterns) **without overhead** (npm handles versioning and distribution).

---

**Next:** Read [SETUP_GUIDE.md](./SETUP_GUIDE.md) to install in a project, or [CONTRIBUTING.md](../CONTRIBUTING.md) to add new skills and plugins.
