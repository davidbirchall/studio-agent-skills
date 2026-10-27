# Architecture: @davidbirchall/squad-skills Library

This document explains the design, distribution model, and use cases for the centralized Squad skills library.

## Overview

**@davidbirchall/squad-skills** is a **reusable prompt library** containing 19+ decision frameworks, protocols, and operational patterns that teach Squad coordinators and agents how to work together consistently across all your projects.

It is **NOT** a domain expertise library, plugin marketplace, or domain-specific toolkit. It's **coordination software encoded as prose**.

## What Problems Does It Solve?

### Problem 1: Inconsistent Coordinator Behavior
**Without:** Each project has its own coordinator instructions. Over time, they drift. One project decides errors should be escalated, another decides to retry. No consistency.

**With:** All projects load the same routing logic, error recovery patterns, and decision frameworks.

### Problem 2: Duplicate Decision Logic
**Without:** You write the same "how do we handle reviewer rejections?" logic in every project's coordinator.

**With:** Write it once in a skill. All projects reference it.

### Problem 3: No Shared Vocabulary
**Without:** One team calls it "Direct Mode," another calls it "Quick Fix," another has no concept at all.

**With:** All projects speak the same language: "Direct Mode," "Lightweight," "Standard," "Full."

### Problem 4: Single Developer Scaling
**Without:** As you add more projects (12, 20, 30), keeping them aligned becomes manual and error-prone.

**With:** One `npm install` and one sync command brings all projects in sync.

## Architecture

### Layer 1: Skills Library (This Repo)

```
studio-agent-skills/  ← The source of truth
├── .github/skills/   ← 19+ skills organized by domain
│   ├── coordinator-response-mode/SKILL.md
│   ├── reviewer-protocol/SKILL.md
│   ├── error-recovery/SKILL.md
│   └── ... (16 more)
├── package.json      ← Metadata & versioning
├── SKILLS_REGISTRY.md     ← Catalog & descriptions
└── scripts/sync-skills.sh ← Bulk update tool
```

**Responsibility:** Author, test, version, and publish skills.

### Layer 2: Distribution (npm + GitHub Packages)

```
Published to: npm.pkg.github.com/@davidbirchall/squad-skills

Available as:
  - npm package (v1.0.0 semver)
  - Installable in any project
  - Versioned & updateable
```

**Responsibility:** Provide reliable, versioned access to skills.

### Layer 3: Projects (Your 12+ Squad Projects)

```
my-squad-project/
├── package.json (depends on @davidbirchall/squad-skills)
├── .github/skills/ (copied from library)
├── .squad/ (project-specific config & agents)
└── coordinator.md (loads global skills + project overrides)
```

**Responsibility:** Install, customize, stay in sync.

## Use Cases

### Use Case 1: New Project Setup

1. Create a new Squad project
2. `npm install @davidbirchall/squad-skills`
3. `cp -r node_modules/@davidbirchall/squad-skills/.github/skills .github/`
4. Get 19+ skills immediately; no need to invent your own decision frameworks

### Use Case 2: Consistency Across Teams

1. All 12 projects reference the same `coordinator-response-mode` skill
2. Same routing decisions everywhere
3. Agent behavior is predictable across projects
4. New team members onboard faster because patterns are consistent

### Use Case 3: Major Update to Processes

1. You discover a better error-recovery strategy
2. Update `error-recovery/SKILL.md` once
3. Run `./scripts/sync-skills.sh /path/to/projects`
4. All projects get the new pattern in minutes

### Use Case 4: Project-Specific Customization

1. Project A needs a stricter review protocol for compliance
2. Copy `reviewer-protocol/SKILL.md` into Project A's `.github/skills/`
3. Edit the local copy
4. Project A uses local version; all others get the shared version

## Versioning Strategy

### Semantic Versioning

```
1.0.0
↑ ↑ ↑
│ │ └─ PATCH: typo, clarification (safe to auto-update)
│ └─── MINOR: new skill added, backwards compatible (review but safe)
└───── MAJOR: breaking change to a skill contract (requires review)
```

### Release Process

1. Make changes to skills in `.github/skills/`
2. Update `SKILLS_REGISTRY.md` if adding/removing skills
3. Bump `package.json` version
4. Create a git tag: `git tag v1.0.1`
5. GitHub Actions publishes to npm automatically
6. Projects update with `npm update @davidbirchall/squad-skills`

## Skills Are Not Code

This is important: **Skills are prose, not code.**

- ✅ Skills teach **concepts** and **decision logic**
- ✅ Skills encode **processes** and **patterns**
- ✅ Skills are **human-readable** and **LLM-compatible**
- ❌ Skills are not executable code
- ❌ Skills are not JavaScript/Python/Go libraries
- ❌ Skills don't require compilation or a build step

They work like documentation that the coordinator and agents read and follow. They're distributed as markdown files inside an npm package.

## Skills vs Plugins vs Capabilities

### Skills (This Library)
- **Scope:** Coordination & team behavior
- **Audience:** All agents & coordinator
- **Discovery:** Coordinator loads on-demand
- **Installation:** `.github/skills/`
- **Example:** "How do we route work?"

### Plugins (Squad Plugin Marketplace)
- **Scope:** Domain expertise per agent
- **Audience:** Individual agents during team setup
- **Discovery:** Marketplace search by role
- **Installation:** `.squad/agents/{name}/skills/`
- **Example:** "Azure patterns for a cloud engineer"

### Capabilities (Agent Charter)
- **Scope:** Individual agent boundaries
- **Audience:** Single agent
- **Discovery:** Embedded in agent's charter.md
- **Installation:** `.squad/agents/{name}/charter.md`
- **Example:** "This agent reviews code. It does NOT write code."

**Your library is Skills. It's the right choice.**

## Maintenance Model

### You (Single Developer)

- Author and update skills based on what works
- Version releases (semver)
- Review contributions (if open-sourced)

### Your Projects (12+)

- Stay in sync via periodic `npm update`
- Can override locally if needed
- Always have access to latest patterns

### Future: Maybe Plugins

If you build domain libraries (Kubernetes patterns, Azure guidelines, organizational testing standards), those would be **plugins**, registered in a separate marketplace. Skills and plugins are complementary, not competing.

## File Structure Explained

```
studio-agent-skills/
├── .github/skills/                 ← What gets published
│   ├── squad/
│   │   └── SKILL.md                ← Interactive command catalog
│   ├── coordinator-response-mode/
│   │   └── SKILL.md                ← Routing mode decision table
│   ├── error-recovery/
│   │   └── SKILL.md                ← Error handling protocols
│   └── ... (16 more skills)
│
├── .squad/                         ← Project's own Squad config (NOT published)
│   ├── team.md
│   ├── routing.md
│   ├── agents/
│   └── templates/                  ← Reference docs, not published
│
├── scripts/
│   └── sync-skills.sh              ← Helper for bulk updates
│
├── docs/
│   ├── SETUP_GUIDE.md              ← How to install & use
│   ├── ARCHITECTURE.md             ← This file
│   └── PLUGINS_vs_SKILLS.md        ← Architectural clarification
│
├── package.json                    ← Metadata, version, publish config
├── README.md                       ← Quick start & overview
├── SKILLS_REGISTRY.md              ← Full catalog with descriptions
├── CONTRIBUTING.md                 ← How to add/improve skills
└── .github/workflows/
    └── publish-skills.yml          ← Auto-publish on tag
```

The `files` field in `package.json` controls what gets published:

```json
"files": [
  ".github/skills",           ← Publish only the skills
  "SKILLS_REGISTRY.md"        ← Catalog
]
```

Everything else (`.squad/`, `docs/`, tests, etc.) stays in the repo but doesn't get shipped in the npm package.

## Distribution Channels

### GitHub Packages (Private, Recommended for Solo Dev)

```bash
npm install @davidbirchall/squad-skills
# Requires authentication via ~/.npmrc or gh auth setup-git
```

**Pros:** No public registry needed, stays private, free tier available
**Cons:** Requires GitHub auth

### Public npm Registry (Future Option)

```bash
npm install @davidbirchall/squad-skills
# Anyone can install
```

**Pros:** Discoverable, no auth needed, standard distribution
**Cons:** Makes it public (you can always do this later)

### Git Submodule (Alternative for Projects)

```bash
git submodule add https://github.com/davidbirchall/studio-agent-skills
```

**Pros:** Always latest, no npm needed
**Cons:** Manual updates, harder to version lock

**Recommended:** Start with GitHub Packages (private, versioned). If you want broader sharing, switch to public npm later.

## Future Enhancements

### Option 1: Local CLI Helper

```bash
squad-skills list        # List all skills
squad-skills show coordinator-response-mode
squad-skills sync        # Sync to current project
```

### Option 2: Web Discovery

```
https://davidbirchall.dev/squad-skills/
  ├── Coordinator Protocol
  ├── Team Collaboration
  ├── Process & Discipline
  └── ...
```

Browse and search all skills with examples and linking.

### Option 3: Companion Plugin Marketplace

If you centralize domain expertise, create `@davidbirchall/squad-plugins`:

```
plugins/
├── azure-cloud/SKILL.md
├── python-testing/SKILL.md
├── react-component-patterns/SKILL.md
└── ...
```

Register: `squad plugin marketplace add @davidbirchall/squad-plugins`

But this is **separate from skills**. One does "how we coordinate," the other does "patterns for Azure/Python/React."

## Summary

**You've built the right thing.** A centralized library of:
- ✅ Coordination patterns
- ✅ Decision frameworks
- ✅ Operational protocols
- ✅ Team conventions

Packaged as an **npm package** with **semantic versioning**, distributed via **GitHub Packages**, and installable across your **12+ Squad projects**.

This gives you **consistency at scale** without the overhead of a complex system.

---

**Next:** Read [SETUP_GUIDE.md](./SETUP_GUIDE.md) to install in your first project, or [CONTRIBUTING.md](../CONTRIBUTING.md) to add new skills.
