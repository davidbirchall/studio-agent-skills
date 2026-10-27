# @davidbirchall/squad-skills

> Centralized Squad skills library for AI team coordination — reusable prompt patterns, decision frameworks, and operational protocols.

This package contains **19+ battle-tested skills** for [Squad](https://github.com/bradygaster/squad), the AI team framework. Skills empower coordinators to orchestrate specialized agents and help agents collaborate effectively.

## Quick Start

### 1. Install

```bash
npm install @davidbirchall/squad-skills --save-dev
```

### 2. Add to Your Squad Project

Copy skills into your `.github/skills/` directory:

```bash
cp -r node_modules/@davidbirchall/squad-skills/.github/skills .github/
```

Or reference directly in your coordinator instructions:

```markdown
<!-- Load from centralized library -->
See `.github/skills/squad/SKILL.md` for the interactive command catalog.
```

### 3. Start Using Skills

Skills are loaded on-demand by your Squad coordinator. For example:

```markdown
Relevant skill: node_modules/@davidbirchall/squad-skills/.github/skills/coordinator-response-mode/SKILL.md
```

The coordinator reads the skill before making routing decisions.

## What's Included

This library includes 19+ skills organized into 6 domains:

### 🏗️ **Coordinator Protocol** (4 skills)
Core Squad orchestration: team initialization, routing modes, source-of-truth hierarchy.
- `squad` — Interactive command catalog
- `coordinator-init-mode` — Two-phase team setup
- `coordinator-response-mode` — Work routing decision table
- `coordinator-source-of-truth` — File governance & conflict resolution

### 🤝 **Team Collaboration** (4 skills)
Multi-agent patterns: worktree awareness, cross-squad delegation, error recovery.
- `agent-collaboration` — Standard collaboration patterns
- `cross-squad` — Multi-squad instance coordination
- `cross-squad-communication` — Inter-squad delegation protocols
- `error-recovery` — Failure & adaptation patterns

### ✅ **Process & Discipline** (3 skills)
Quality gates: review protocols, test design, security practices.
- `reviewer-protocol` — Rejection workflow & lockout semantics
- `test-discipline` — Contract-driven assertion design
- `secret-handling` — Credential & sensitive-data protection

### 🔀 **Git & Workflow** (3 skills)
Branching strategy, version management, session recovery.
- `git-workflow` — Dev-first branching model
- `squad-version-check` — Upgrade & versioning mechanics
- `session-recovery` — Resume interrupted sessions

### 🧠 **Memory & Learning** (3 skills)
Knowledge capture and reuse: tiered memory, reflection, iterative retrieval.
- `tiered-memory` — Three-tier memory model
- `reflect` — Learning capture system
- `iterative-retrieval` — Sub-task protocol with validation

### 📖 **Convention & Standards** (2 skills)
Documented practices and baseline knowledge.
- `squad-conventions` — Core patterns & naming rules
- `squad-help` — Comprehensive Squad usage guide

**Full registry:** See [SKILLS_REGISTRY.md](./SKILLS_REGISTRY.md) for detailed descriptions, when to load each skill, and usage examples.

## Design

Each skill is a standalone `.md` file that:
- **Defines scope** — what the skill teaches (1-line description)
- **Explains when to load it** — triggers and decision points
- **Provides full context** — no placeholder references
- **Remains self-contained** — readable in isolation, but composable with others

Skills are *not* code libraries. They're **prompt patterns** — structured text that encodes decision logic, processes, and conventions. They work with any LLM running Squad.

## Usage Patterns

### Pattern 1: Copy into Your Project (Recommended)

Best for: Private projects, most control, local modifications.

```bash
cp -r node_modules/@davidbirchall/squad-skills/.github/skills .github/
git add .github/skills
git commit -m "chore: import @davidbirchall/squad-skills v1.0.0"
```

Your coordinator reads skills from the local `.github/skills/` directory.

### Pattern 2: Reference from node_modules

Best for: Minimal disk footprint, always in sync with package version.

In your coordinator instructions or agent spawn prompts:

```
Relevant skill: node_modules/@davidbirchall/squad-skills/.github/skills/squad/SKILL.md
```

The coordinator loads it dynamically. Requires running `npm install` before use.

### Pattern 3: MCP Server Integration

Best for: Tool-based loading, advanced workflows.

If you're using an MCP server that supports skill discovery:

```json
{
  "skillPaths": [
    "node_modules/@davidbirchall/squad-skills/.github/skills"
  ]
}
```

The MCP server exposes skills as discoverable tools.

## Versioning

This package follows **semantic versioning**:

| Change | Bump | Notes |
|--------|------|-------|
| New skills added | Minor | Backwards compatible |
| Skill content clarified/updated | Patch | No behavior change |
| Skill contract or structure changed | Major | Review required before upgrade |
| Breaking change to Squad coordinator interface | Major | Update your coordinator instructions |

Check [GitHub Releases](https://github.com/davidbirchall/studio-agent-skills/releases) for detailed release notes.

### Upgrading

```bash
npm update @davidbirchall/squad-skills
```

Then re-copy skills to your project (Pattern 1) or verify node_modules references (Pattern 2).

## Contributing

Found a bug? Have a skill to contribute? Ideas for improvements?

1. **Open an issue** to discuss (don't surprise with a large PR)
2. **Create a feature branch:** `git checkout -b squad/your-skill-name`
3. **Add or edit skills** in `.github/skills/{skill-name}/SKILL.md`
4. **Update SKILLS_REGISTRY.md** with new entries
5. **Open a PR** with rationale and examples
6. **After merge**, a release is tagged and published to npm

Skills are authored by:
- **Coordinator team** — squad orchestration & routing protocols
- **Agents** — patterns learned from successful work (via the `reflect` skill)
- **Community** — project-specific playbooks that generalize well

## License

MIT — Reuse freely with attribution.

## Support

- 📖 [SKILLS_REGISTRY.md](./SKILLS_REGISTRY.md) — Complete skill catalog
- 🚀 [Squad Documentation](https://github.com/bradygaster/squad) — Using Squad in your projects
- 💬 Open an issue for questions or suggestions

---

**Package:** @davidbirchall/squad-skills  
**Repository:** https://github.com/davidbirchall/studio-agent-skills  
**Registry:** GitHub Packages (`npm.pkg.github.com`)  
**License:** MIT
