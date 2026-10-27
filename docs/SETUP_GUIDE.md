# Setup Guide: Using @davidbirchall/squad-skills in Your Projects

This guide explains how to install and use the centralized skills library across your Squad projects.

## Prerequisites

- **Node.js 18+** — Required for npm
- **GitHub account** — For authenticating with GitHub Packages
- **Git** — For cloning and pushing updates

## Step 1: Configure GitHub Packages Authentication

GitHub Packages requires authentication. Add this to your `~/.npmrc` file:

```bash
echo '//npm.pkg.github.com/:_authToken=YOUR_GITHUB_TOKEN' >> ~/.npmrc
chmod 600 ~/.npmrc
```

**To create a GitHub token:**

1. Go to [GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)](https://github.com/settings/tokens)
2. Click "Generate new token"
3. Select scopes:
   - ✅ `read:packages` — Read from GitHub Packages
4. Click "Generate token"
5. Copy the token and paste it in the command above

**Better: Use GitHub CLI**

If you have `gh` installed:

```bash
gh auth setup-git
```

This automatically handles authentication.

## Step 2: Install Skills in a Project

In your Squad project, add the package:

```bash
npm install @davidbirchall/squad-skills --save-dev
```

This adds it to `package.json` and downloads skills to `node_modules/`.

## Step 3: Copy Skills to Your Project

Option A (Recommended): Copy skills into your project's version control:

```bash
# From your project root
cp -r node_modules/@davidbirchall/squad-skills/.github/skills .github/

# Commit them
git add .github/skills
git commit -m "chore: import squad skills v1.0.0"
```

Option B (Dynamic): Reference from node_modules in coordinator instructions:

```markdown
Relevant skill: node_modules/@davidbirchall/squad-skills/.github/skills/squad/SKILL.md
```

**Recommendation:** Use Option A for most projects. It ensures skills are available even if `node_modules` is cleaned, and you can customize them per-project if needed.

## Step 4: Use the Skills in Your Coordinator

Skills are now available in `.github/skills/`. Your Squad coordinator automatically discovers them.

To explicitly load a skill:

```markdown
Before routing work, check the Response Mode Selection protocol:
See `.github/skills/coordinator-response-mode/SKILL.md` for the decision table.
```

## Step 5: Keep Skills Up to Date

### Option A: Manual Update (Simple)

```bash
# In your project
npm update @davidbirchall/squad-skills
cp -r node_modules/@davidbirchall/squad-skills/.github/skills .github/
git add .github/skills
git commit -m "chore: update squad skills to v1.0.1"
git push
```

### Option B: Batch Update (All Projects)

Use the sync script from this repository to update all your projects at once:

```bash
# In the studio-agent-skills directory
./scripts/sync-skills.sh /path/to/your/projects
```

The script will:
- Scan for projects that depend on `@davidbirchall/squad-skills`
- Update the dependency
- Copy `.github/skills/` into each project
- Report which projects were updated

**Check without applying:**

```bash
./scripts/sync-skills.sh --check /path/to/your/projects
```

Shows which projects are out of sync without making changes.

## Directory Structure After Installation

Your project will look like:

```
my-squad-project/
├── .github/
│   └── skills/                    ← Skills copied here
│       ├── squad/
│       ├── coordinator-response-mode/
│       ├── agent-collaboration/
│       └── ... (19+ skills)
├── .squad/                        ← Your project-specific Squad config
│   ├── team.md
│   ├── routing.md
│   ├── agents/
│   └── ...
├── package.json                   ← Contains @davidbirchall/squad-skills dependency
└── node_modules/
    └── @davidbirchall/squad-skills/
```

## Customizing Skills Per Project

If you need to customize a skill for a specific project:

1. **Copy the skill** from `.github/skills/{skill-name}/` into your own project
2. **Edit it** as needed
3. **Your coordinator** will use the local version first

The coordinator loads skills with this precedence:
1. **Local** — `.github/skills/` in your project (highest)
2. **Fallback** — `node_modules/@davidbirchall/squad-skills/.github/skills/`

## Versioning

The package follows **semantic versioning**:

| Version Change | Meaning | Action |
|---|---|---|
| `1.0.0` → `1.0.1` | Patch (typos, clarifications) | Safe to update immediately |
| `1.0.0` → `1.1.0` | Minor (new skills, backwards compatible) | Safe to update, review new skills |
| `1.0.0` → `2.0.0` | Major (breaking changes) | Review carefully before updating |

**Check for updates:**

```bash
npm outdated @davidbirchall/squad-skills
```

## Troubleshooting

### "npm ERR! 404 — Package not found"

You likely don't have authentication configured. Run:

```bash
gh auth setup-git
```

Then try again.

### "Permission denied" error on sync script

Make the script executable:

```bash
chmod +x scripts/sync-skills.sh
```

### Skills aren't loading in my coordinator

1. Verify skills are in `.github/skills/`:
   ```bash
   ls .github/skills/
   ```

2. Check that your coordinator is in `.github/copilot-instructions.md` or `.squad/`:
   ```bash
   ls -la .github/copilot-instructions.md
   ```

3. If using dynamic references, verify `node_modules/` is intact:
   ```bash
   ls node_modules/@davidbirchall/squad-skills/.github/skills/
   ```

### "Different version across projects" warning

Use the sync script to bring all projects in sync:

```bash
./scripts/sync-skills.sh --check /path/to/projects
./scripts/sync-skills.sh /path/to/projects
```

## Skills vs Plugins: What's the Difference?

This library is a **Skills library**, not a Plugin marketplace. Here's why that matters:

### Skills (What You're Using)
- **Purpose:** Teach the **coordinator** and all agents **how to work together consistently**
- **Scope:** Universal operational patterns (routing decisions, error recovery, review protocols)
- **Discovery:** Loaded by coordinator on-demand from `.github/skills/`
- **Reusability:** Used by every project, every agent, every role
- **Example:** "Define how we handle reviewer rejections" or "Teach error recovery patterns"

### Plugins (Different Purpose)
- **Purpose:** Add domain expertise to **individual agents** during team setup
- **Scope:** Role-specific knowledge (Kubernetes for DevOps, React for frontend, Azure for cloud)
- **Discovery:** Marketplace search by role during "Add Team Member" flow
- **Reusability:** Per-domain (Kubernetes plugin for DevOps agent only)
- **Example:** "When adding a DevOps engineer, give them Kubernetes expertise" or "Give the frontend engineer React patterns"

**Your library is correct as a Skills package.** It teaches "How do we coordinate?" not "How do we build Kubernetes systems?"

If you want to centralize domain expertise later (organizational testing standards, your Azure guidelines, etc.), you could create a **separate plugin marketplace** — but that's optional and independent.

## Next Steps

- 📖 Read [SKILLS_REGISTRY.md](../SKILLS_REGISTRY.md) for a complete skill catalog
- 🚀 Check [README.md](../README.md) for usage patterns
- 💬 [Contributing](../CONTRIBUTING.md) to add or improve skills

---

**Questions?** Open an issue in the [studio-agent-skills](https://github.com/davidbirchall/studio-agent-skills) repo.
