# Setup Guide: Using @davidbirchall/squad-skills in Your Projects

This guide explains how to install and use the skills and plugins from the centralized library across your Squad projects.

## Prerequisites

- **Node.js 18+** — Required for npm
- **GitHub account** — For authenticating with GitHub Packages
- **Git** — For cloning and pushing updates
- **Copilot CLI** — For managing plugins

## Step 1: Configure GitHub Packages Authentication

GitHub Packages requires authentication. Add this to your `~/.npmrc` file:

```bash
echo '//npm.pkg.github.com/:_authToken=YOUR_GITHUB_TOKEN' >> ~/.npmrc
chmod 600 ~/.npmrc
```

**To create a GitHub token:**

1. Go to [GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)](https://github.com/settings/tokens)
2. Click "Generate new token"
3. Select scope: `read:packages` (Read from GitHub Packages)
4. Click "Generate token"
5. Copy and paste it in the command above

**Better: Use GitHub CLI**

If you have `gh` CLI installed:

```bash
gh auth setup-git
```

This automatically handles authentication.

## Step 2: Install the Skills Package in a Project

In your Squad project root, add the package:

```bash
npm install --save-dev @davidbirchall/squad-skills
```

This adds it to `package.json` and downloads the package to `node_modules/`.

## Step 3: Install Plugins

You now have access to all plugins. Install the ones your project needs.

### Option A: Single Plugin

```bash
# Install a specific plugin
copilot plugin install ./node_modules/@davidbirchall/squad-skills/plugins/frontend

# Verify installation
copilot plugin list
```

### Option B: Use a Stack (Multiple Plugins at Once)

Stacks bundle related plugins for common use cases:

| Stack | Plugins | Use case |
|-------|---------|----------|
| `web` | shared, frontend, backend, data, platform-engineering, agent-practices, workflows | Full-stack web development |
| `game` | shared, game-development, creative-technology, game, agent-practices, workflows | Game development |
| `ai` | shared, backend, ai-engineering, platform-engineering, agent-practices, workflows | LLM and AI systems |
| `process` | product, game, creative, production, knowledge, business | Solo business and creative process |
| `all` | All plugins | Everything (not recommended unless needed) |

Install a stack:

```bash
# Run from your project root
./node_modules/@davidbirchall/squad-skills/scripts/install-stack.sh web
# or: game, ai, process, all
```

## Step 4: Verify Installation

```bash
# List installed plugins
copilot plugin list

# In a Copilot CLI session, see all loaded skills
/skills list
```

## Step 5: Use the Skills and Plugins

### Coordination Skills

Coordination skills (19+) are automatically available to your coordinator. They teach how Squad coordinators and agents work together.

Example skills:
- `coordinator-response-mode` — When to use Direct vs Lightweight vs Standard vs Full mode
- `reviewer-protocol` — How reviewer rejection and lockout work
- `error-recovery` — How to handle agent failures gracefully

Your coordinator loads these on-demand:

```markdown
Before routing work, check the Response Mode Selection protocol:
See `.github/skills/coordinator-response-mode/SKILL.md` for the decision table.
```

### Domain Plugins

Plugins teach domain-specific knowledge and best practices. They're loaded per-project based on your team's needs.

**Frontend plugin example:**
- Vue 3 component patterns
- Testing strategy
- State management with Pinia
- Styling architecture
- Accessibility standards

The frontend engineer on your team reads and follows these skills when building components.

## Step 6: Keep Skills and Plugins Up to Date

### Check for Updates

```bash
npm outdated @davidbirchall/squad-skills
```

### Update to Latest Version

```bash
npm update @davidbirchall/squad-skills

# Reinstall plugins to pick up new versions
./node_modules/@davidbirchall/squad-skills/scripts/install-stack.sh web
# or reinstall individual plugins:
copilot plugin install ./node_modules/@davidbirchall/squad-skills/plugins/frontend
```

When you run `npm update`, it brings in the latest version of all plugins. Reinstalling plugins ensures Copilot CLI loads the new version from that npm package version.

## Directory Structure After Installation

Your project will look like:

```
my-squad-project/
├── package.json                    ← Depends on @davidbirchall/squad-skills
├── .squad/                         ← Project-specific Squad config
│   ├── team.md
│   ├── routing.md
│   ├── agents/
│   └── ...
├── node_modules/
│   └── @davidbirchall/squad-skills/ ← Contains all skills and plugins
│       ├── .github/skills/         ← Coordination skills
│       ├── plugins/                ← Domain plugins
│       └── scripts/
└── .copilot/ or .github/           ← Your project config
```

Copilot CLI automatically discovers and caches plugins when you run `copilot plugin install`.

## Per-Project vs Global Installation

**Why install per-project instead of globally?**

✅ **Version control** — Each project pins the exact version it needs in package.json
✅ **Independence** — Project A can use v1.1.0 while Project B uses v1.2.0
✅ **Reproducibility** — Anyone running `npm install` gets the same versions
✅ **Rollback** — Revert package.json if an update breaks something
✅ **Portability** — Project dependencies are self-contained; no ambient global state

This is the npm standard and scales as your project count grows.

## Customizing Plugins Per Project

If a project needs a custom variant of a plugin:

### Option A: Local Override

1. Install the standard plugin:
   ```bash
   copilot plugin install ./node_modules/@davidbirchall/squad-skills/plugins/frontend
   ```

2. Edit the cached plugin locally (Copilot CLI caches plugins in a local directory)

3. Your customizations only affect this project

### Option B: Create a Local Plugin

If the customization is significant:

1. Copy the plugin into your project:
   ```bash
   cp -r node_modules/@davidbirchall/squad-skills/plugins/frontend .squad/plugins/frontend-custom
   ```

2. Edit `.squad/plugins/frontend-custom/plugin.json` and skills

3. Load your local plugin:
   ```bash
   copilot plugin install ./.squad/plugins/frontend-custom
   ```

4. Other projects continue using the standard version

## Versioning and Semantic Versioning

The package follows **semantic versioning**:

| Change | Version | Action |
|--------|---------|--------|
| Typo fix, clarification | `1.0.0` → `1.0.1` (PATCH) | Safe to update immediately |
| New skill, new plugin | `1.0.0` → `1.1.0` (MINOR) | Safe to update, review new content |
| Breaking change | `1.0.0` → `2.0.0` (MAJOR) | Review carefully before updating |

**Recommendation:** Use `^1.1.0` in package.json to automatically accept PATCH and MINOR updates. Manually review and test MAJOR updates.

## Troubleshooting

### "npm ERR! 404 — Package not found"

You don't have authentication configured. Run:

```bash
gh auth setup-git
# or manually add your token to ~/.npmrc
```

Then try again.

### "copilot plugin install: command not found"

Install Copilot CLI:

```bash
brew install copilot-cli
# or see https://github.com/github/copilot-cli
```

### "Skills aren't loading in my coordinator"

1. Verify the package is installed:
   ```bash
   ls node_modules/@davidbirchall/squad-skills
   ```

2. Verify plugins are installed:
   ```bash
   copilot plugin list
   ```

3. Restart Copilot CLI to pick up plugin changes:
   ```bash
   # Close any running Copilot CLI sessions and restart
   ```

### "Which version am I running?"

Check package-lock.json or run:

```bash
npm list @davidbirchall/squad-skills
```

### "Different versions across projects"

All projects should use the same version for consistency. Update all projects together:

```bash
# In each project
npm update @davidbirchall/squad-skills
./node_modules/@davidbirchall/squad-skills/scripts/install-stack.sh web
git add package-lock.json
git commit -m "chore: update squad skills to v1.1.1"
```

## Coordination Skills vs Domain Plugins

### Coordination Skills (`.github/skills/`)

- Teach how your coordinator and agents work together
- Everyone loads them
- Examples: routing decisions, error recovery, reviewer protocols
- Updates to coordination skills affect all projects

**You don't choose which coordination skills to load** — they're available to your coordinator by default.

### Domain Plugins (`plugins/`)

- Teach how to build things in your stack
- Load only the ones your project needs
- Examples: Vue patterns, NestJS architecture, game design
- Updates to domain plugins are gradual (install when you're ready)

**You choose which domain plugins to install** based on your project's needs.

## Next Steps

1. ✅ Install `@davidbirchall/squad-skills` in a project
2. ✅ Install the plugins your project needs
3. 📖 Read [README.md](../README.md) for the complete plugin catalog
4. 📖 Read [docs/ARCHITECTURE.md](./ARCHITECTURE.md) for the design philosophy
5. 💬 [CONTRIBUTING.md](../CONTRIBUTING.md) if you want to add new skills or plugins

---

**Questions?** Open an issue in the [studio-agent-skills](https://github.com/davidbirchall/studio-agent-skills) repo.
