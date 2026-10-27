# Contributing to @davidbirchall/squad-skills

Thank you for contributing! This guide explains how to add, update, or improve skills in the centralized library.

## What is a Skill?

A **skill** is a self-contained prompt pattern that teaches Squad coordinators or agents how to handle a specific aspect of AI team coordination. Skills are:

- **Standalone** — readable and useful in isolation
- **Composable** — work alongside other skills without conflicts
- **Evergreen** — remain correct and useful as Squad evolves
- **Examples-rich** — include concrete scenarios, not just theory

## Before You Contribute

1. **Check the registry** — See if your idea already exists in [SKILLS_REGISTRY.md](./SKILLS_REGISTRY.md)
2. **Open an issue** — Describe your skill idea and get feedback before writing
3. **Read existing skills** — Understand the format and depth by reading 2–3 similar skills in `.github/skills/`

## Adding a New Skill

### 1. Create the Skill Directory

```bash
mkdir -p .github/skills/your-skill-name
```

### 2. Write `SKILL.md`

Use this template:

```markdown
# Your Skill Name

**Location:** `.github/skills/your-skill-name/SKILL.md`  
**Domain:** [Coordinator Protocol / Team Collaboration / Process & Discipline / Git & Workflow / Memory & Learning / Convention & Standards]  
**When to load:** [Describe the trigger — e.g., "Before routing work", "On agent spawn", "When decisions conflict"]  

## Overview

One-sentence summary of what this skill teaches.

Paragraph explaining:
- What problem it solves
- When it applies
- How it relates to other Squad concepts
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

- If skill references external docs, standards, or conventions, link them
- Include relevant `.squad/` file paths
- Link to related GitHub issues or discussions if applicable

---

**Version:** 1.0  
**Confidence:** [low / medium / high] — How well-tested this pattern is  
**Last reviewed:** YYYY-MM-DD
```

### 3. Update SKILLS_REGISTRY.md

Add an entry to the appropriate domain in the registry:

```markdown
| **your-skill-name** | Brief description | Trigger (e.g., "Before routing work") | `.github/skills/your-skill-name/SKILL.md` |
```

### 4. Commit & Open PR

```bash
git checkout -b squad/add-your-skill-name
git add .github/skills/your-skill-name/ SKILLS_REGISTRY.md
git commit -m "feat: add 'your-skill-name' skill

- Teaches [what the skill teaches]
- Applies when [trigger condition]
- Relates to [other skills]"
git push origin squad/add-your-skill-name
```

## Updating an Existing Skill

### 1. Edit the skill

Make changes to `.github/skills/{skill-name}/SKILL.md`:
- **Clarifications** — No behavior change, just clearer wording? Use PATCH version
- **Content updates** — Adding examples or edge cases? Use MINOR version
- **Breaking changes** — Changing the core contract or structure? Use MAJOR version

### 2. Update version & date

At the bottom of the skill, bump the version and update "Last reviewed":

```markdown
**Version:** 1.1  
**Confidence:** [update if needed]  
**Last reviewed:** 2026-10-27
```

### 3. Commit & Open PR

```bash
git checkout -b squad/update-{skill-name}
git add .github/skills/{skill-name}/SKILL.md
git commit -m "docs: improve '{skill-name}' skill

- [What changed]
- [Why it matters]"
git push origin squad/update-{skill-name}
```

## Review Checklist (for maintainers)

Before merging a skill PR:

- [ ] Skill is self-contained (readable without external references)
- [ ] Triggers & "when to load" are clear
- [ ] Examples include real-world scenarios
- [ ] Related skills are linked
- [ ] No conflicting instructions with existing skills
- [ ] Domain categorization is correct
- [ ] SKILLS_REGISTRY.md is updated
- [ ] Version follows semver rules
- [ ] No secrets or sensitive examples included

## Publishing a Release

1. **Update package.json version:**
   ```bash
   npm version patch  # or minor, or major
   ```

2. **Commit & push:**
   ```bash
   git add package.json
   git commit -m "chore: release v1.0.1"
   git push
   ```

3. **Create a git tag:**
   ```bash
   git tag v1.0.1
   git push origin v1.0.1
   ```

   The GitHub Actions workflow [`.github/workflows/publish-skills.yml`](./.github/workflows/publish-skills.yml) will automatically:
   - Verify version match
   - Publish to GitHub Packages
   - Create a GitHub Release

## Skill Confidence Levels

Skills use three confidence levels (bottom of each `SKILL.md`):

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

- 📖 Read [SKILLS_REGISTRY.md](./SKILLS_REGISTRY.md) for the full skill catalog
- 🚀 See [README.md](./README.md) for usage patterns and examples
- 💬 Open an issue to discuss ideas before writing

---

**License:** MIT — Contribute freely!
