# Contributing to @davidbirchall/squad-skills

Thank you for contributing! This guide explains how to add or update plugins and skills.

## What is a Plugin?

A **plugin** is a collection of related skills organized by domain. Each plugin lives in `plugins/{domain}/` with its own `plugin.json`, README, and skills subdirectory.

See [README.md](./README.md) for the complete plugin catalog.

## What is a Skill?

A **skill** is a self-contained prompt pattern that teaches Squad coordinators or agents how to handle a specific aspect of their domain. Skills are:

- **Standalone** — readable and useful in isolation
- **Composable** — work alongside other skills without conflicts
- **Evergreen** — remain correct and useful over time
- **Examples-rich** — include concrete scenarios, not just theory

## Before You Contribute

1. **Check the plugin list** — See if your skill fits in an existing plugin in [README.md](./README.md)
2. **Open an issue** — Describe your skill idea and get feedback before writing
3. **Read existing skills** — Understand the format and depth by reading 2–3 similar skills in the plugin's `skills/` directory

## Adding a New Skill to a Plugin

### 1. Create the Skill Directory

```bash
mkdir -p plugins/{plugin-name}/skills/your-skill-name
```

### 2. Write `SKILL.md`

Use this template:

```markdown
---
name: your-skill-name
description: What this skill teaches and when an agent should load it.
confidence: [low/medium/high]
---

# Your Skill Name

## Overview

One-sentence summary of what this skill teaches.

Paragraph explaining:
- What problem it solves
- When it applies
- How it relates to other skills
- Why it matters

## Core Concepts

### Concept 1: [Name]
[Definition and explanation with examples]

### Concept 2: [Name]
[Definition and explanation with examples]

## Workflow / Decision Tree

[Step-by-step procedure OR decision logic. Format as numbered steps, decision trees, tables, or state diagrams as fits.]

## Example Scenarios

### Scenario 1: [Real-world situation]
[How to apply this skill in context; what the coordinator or agent does]

### Scenario 2: [Another real-world situation]
[How to apply this skill differently]

## Edge Cases & Exceptions

[When this skill does NOT apply, or when to deviate from it]

## Related Skills

- **Skill Name** — How this connects to another skill
- **Skill Name** — Prerequisite or alternative

## References

[External docs, standards, or conventions that inform this skill]
```

### 3. Update Plugin README

Add your skill to the plugin's README.md skill list.

### 4. Commit & Open PR

```bash
git checkout -b squad/{plugin-name}-add-{skill-name}
git add plugins/{plugin-name}/skills/{skill-name}/
git commit -m "feat({plugin-name}): add '{skill-name}' skill

- Teaches [what the skill teaches]
- Applies when [trigger condition]
- Relates to [other skills]"
git push origin squad/{plugin-name}-add-{skill-name}
```

## Updating an Existing Skill

### 1. Edit the skill

Make changes to `plugins/{plugin-name}/skills/{skill-name}/SKILL.md`:
- **Clarifications** — No behavior change, just clearer wording? Use PATCH version
- **Content updates** — Adding examples or edge cases? Use MINOR version
- **Breaking changes** — Changing the core contract? Use MAJOR version

### 2. Update version & confidence

At the top of the skill (YAML frontmatter):

```markdown
---
name: skill-name
description: Updated description
confidence: [low/medium/high]  # Update if needed
---
```

### 3. Commit & Open PR

```bash
git checkout -b squad/{plugin-name}-update-{skill-name}
git add plugins/{plugin-name}/skills/{skill-name}/SKILL.md
git commit -m "docs({plugin-name}): improve '{skill-name}' skill

- [What changed]
- [Why it matters]"
git push origin squad/{plugin-name}-update-{skill-name}
```

## Adding a New Plugin

### 1. Create plugin structure

```bash
mkdir -p plugins/your-plugin-name/skills
```

### 2. Create `plugin.json`

```json
{
  "name": "squad-skills-your-plugin-name",
  "version": "1.0.0",
  "description": "Your plugin description",
  "author": "davidbirchall",
  "skills": ["skill-one", "skill-two", "skill-three"]
}
```

### 3. Create `README.md`

Document the plugin's purpose and list its skills.

### 4. Add skills

Create skill directories under `skills/` following the SKILL.md template above.

### 5. Update root README.md

Add your plugin to the appropriate section in [README.md](./README.md).

## Review Checklist (for maintainers)

Before merging a skill PR:

- [ ] Skill is self-contained (readable without external references)
- [ ] Description states when to load the skill clearly
- [ ] Examples include real-world scenarios
- [ ] Related skills are linked
- [ ] No conflicting instructions with existing skills
- [ ] No secrets or sensitive examples included
- [ ] Plugin README.md is updated
- [ ] Confidence level is accurate

## Installing Plugins

Single plugin:

```bash
copilot plugin install ./plugins/your-plugin-name
copilot plugin list
```

Stack of plugins:

```bash
scripts/install-stack.sh web      # or game, ai, process, all
```

See [README.md](./README.md) for available stacks.

## Publishing a Release

1. **Update versions** in all modified plugin `plugin.json` files

2. **Update root package.json** if needed

3. **Commit & push:**
   ```bash
   git add plugins/ package.json
   git commit -m "chore: release updates"
   git push
   ```

4. **Create a git tag:**
   ```bash
   git tag v1.1.0
   git push origin v1.1.0
   ```

   The GitHub Actions workflow automatically publishes to GitHub Packages.

## Skill Confidence Levels

Skills use three confidence levels (in frontmatter):

| Level | Meaning | When to apply |
|-------|---------|---------------|
| **low** | First observation | Pattern noticed but not yet validated across multiple projects |
| **medium** | Confirmed | Tested independently by 2+ agents or projects; consistent results |
| **high** | Established | Widely used, well-tested, team-agreed as a standard pattern |

When updating a skill, bump confidence only when:
- Multiple independent teams validated it
- It's been used successfully in 3+ projects
- No contradictory evidence has emerged

## Questions?

- 📖 Read [README.md](./README.md) for the plugin catalog
- 🚀 See individual plugin READMEs for skill details
- 💬 Open an issue to discuss ideas before writing

---

**License:** MIT — Contribute freely!
