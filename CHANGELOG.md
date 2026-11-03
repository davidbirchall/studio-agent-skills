# Changelog

All notable changes to @davidbirchall/squad-skills are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.3] - 2026-11-03

### Added
- **scripts/install-stack.sh** — Convenience installer for plugin stacks
  - Install predefined plugin bundles: `web`, `game`, `ai`, `process`, `all`
  - Provides verification steps and error handling
  - Simplifies multi-plugin setup in projects

### Changed
- **package.json** — Updated "files" array to include:
  - `docs/` (ARCHITECTURE.md, SETUP_GUIDE.md, skill-design-guide.md)
  - `scripts/install-stack.sh`
  - `CONTRIBUTING.md`
  - Ensures users get complete documentation when installing npm package

- **docs/** — All documentation updated to reflect per-project plugin installation approach
  - Better explanation of version control and independence per-project
  - Troubleshooting section added
  - Clear distinction between Coordination Skills (automatic) and Domain Plugins (selective)

### Removed
- **PUBLISH_READY.md** — Obsolete v1.0.0 publishing checklist
  - Assumed NPM_TOKEN + npm.npmjs.com (old model)
  - Current publishing flow is GitHub Packages + OIDC Trusted Publishing (automated via GitHub Actions)
  - Publishing process now documented in CONTRIBUTING.md

### Fixed
- **.gitignore** — Stopped ignoring `docs/` folder
  - Documentation is published to npm, so it should be version-controlled
  - Was incorrectly marked as "internal documentation"

## [1.1.2] - 2026-11-02

### Changed
- **Complete documentation rewrite** for plugin-based architecture:
  - **README.md** — Installation now emphasizes per-project npm install + plugin install from node_modules
  - **CONTRIBUTING.md** — Full rewrite for plugin-centric workflow
    - How to add skills to existing plugins
    - How to create new plugins
    - Publishing flow (semantic versioning, npm release via git tags)
  - **docs/ARCHITECTURE.md** — Comprehensive redesign explaining:
    - Three-layer architecture (library → distribution → projects)
    - Per-project installation benefits (version control, independence, reproducibility, rollback)
    - Why per-project > global installation
    - Clear boundaries: Skills vs Plugins vs Capabilities
    - Use cases from project setup to scaling across 12+ projects
  - **docs/SETUP_GUIDE.md** — Step-by-step per-project setup guide:
    - Configure auth → Install package → Choose plugins → Verify → Keep updated
    - Per-project vs global installation rationale
    - Local customization options
    - Comprehensive troubleshooting

### Added
- **docs/** now included in npm package (see package.json "files" array)
- Complete architecture and setup documentation for npm consumers

## [1.1.1] - 2026-11-02

### Fixed
- **package.json version mismatch** — Version bumped from 1.1.0 to 1.1.1
  - Git tag v1.1.1 had been pushed without corresponding package.json update
  - GitHub Actions publish workflow validates exact tag-to-version match
  - Re-tagged v1.1.1 after version fix to trigger publish workflow

## [1.1.0] - 2026-11-02

### Major Change: Transition to Plugin-Based Architecture

#### Added
- **15 domain plugins** organized by discipline:
  - **Engineering:** shared, frontend, backend, data, platform-engineering, ai-engineering
  - **Game development:** game-development, creative-technology
  - **Process:** product, game, creative, production, agent-practices, business, knowledge, workflows
  - Each plugin contains multiple related skills (100+ total skills across plugins)

- **Stack bundles** for common use cases:
  - `web` — Frontend, backend, data, platform engineering
  - `game` — Game development, creative technology
  - `ai` — Backend, AI engineering, platform engineering
  - `process` — Product, game design, creative, production
  - `all` — All plugins

- **Plugin metadata:** Each plugin has:
  - `plugin.json` (version, name, description, skills list)
  - `README.md` (skill descriptions and usage guide)
  - `skills/` subdirectory (individual skill files)

#### Changed
- **Distribution model** — From monolithic skills package to modular plugins:
  - Old: Single `.github/skills/` folder with all 19 coordination skills
  - New: Coordination skills + 15 domain plugins, selectively installable per-project
  - Plugins installed via `copilot plugin install ./plugins/{name}` from npm package

- **Installation pattern** — Per-project, not global:
  - Each project: `npm install --save-dev @davidbirchall/squad-skills`
  - Then: `copilot plugin install ./node_modules/@davidbirchall/squad-skills/plugins/{name}`
  - Version control at project level (package.json pins exact version)

- **Documentation strategy:**
  - README.md now documents plugin catalog (replaces SKILLS_REGISTRY.md)
  - CONTRIBUTING.md updated for plugin-centric workflow
  - ARCHITECTURE.md explains three-layer design (library → distribution → projects)

#### Removed
- **SKILLS_REGISTRY.md** — Consolidated into README.md plugin catalog
- **scripts/sync-skills.sh** — No longer needed (npm handles versioning)
  - Old model: Install package, run sync script to copy skills to all 12+ projects
  - New model: Each project independently installs npm package, selects plugins
- **Old Vue and idea-capture skills** (moved to plugins):
  - Moved from `.github/skills/vue-*` to `plugins/frontend/skills/vue-*`
  - Moved from `.github/skills/idea-capture/` to `plugins/product/skills/idea/`
  - Now discoverable per-domain instead of in monolithic skills library

- **Coordination skills** from npm package publication (still available locally):
  - 19 coordination skills remain in `.github/skills/` for this project's own use
  - Not published to npm (too tightly coupled to Squad ecosystem)
  - Only plugins and docs published to npm

### Technical Details
- Automatic publishing via GitHub Actions on git tag (OIDC Trusted Publishing)
- No NPM_TOKEN required (uses Trusted Publishing with GITHUB_TOKEN)
- Published to GitHub Packages (npm.pkg.github.com)

## [1.0.5] - 2026-10-27

### Added
- **idea-capture skill** — Preserve and develop creative ideas with structured workflow
  - Four-phase workflow: Capture → Clarify → Develop → Preserve
  - Lightweight template with optional sections (Summary, Why It Matters, Concept, Possibilities, Open Questions, Related)
  - Core filter: "Six months from now, would future-me care about this?"
  - Distinguishes idea from exploration from decision from artifact
  - Emphasis on AI as thinking partner, not wiki-builder

## [1.0.4] - 2026-10-27

### Added
- **vue-accessibility skill** (~850 lines) — Accessibility standards and practices for Vue applications
  - Semantic HTML foundation
  - ARIA attributes and patterns
  - Keyboard navigation and focus management
  - WCAG 2.1 AA compliance
  - axe-core testing integration

## [1.0.3] - 2026-10-27

### Added
- **vue-styling-architecture skill** (~700 lines) — Scalable CSS organization for Vue projects
  - Design tokens via CSS variables
  - Dark mode support (@media prefers-color-scheme)
  - Scoped CSS (no Tailwind philosophy)
  - Design system integration

- **vue-container-presenter-pattern skill** (~818 lines) — Smart container / dumb presenter component split
  - Clear separation of state/logic from render/events
  - File organization and naming conventions
  - Props interface sharing between container and presenter
  - Data flow and event handling patterns

## [1.0.2] - 2026-10-27

### Added
- **vue-testing-strategy skill** (~963 lines) — Comprehensive testing approach for Vue 3
  - Vitest as test runner
  - Vue Testing Library for component testing
  - Mock Service Worker (MSW) for API mocking
  - Playwright for end-to-end testing
  - 90%+ statement coverage target
  - Test categorization (unit, integration, E2E)
  - Common patterns and anti-patterns

## [1.0.1] - 2026-10-27

### Added
- **vue-component-patterns skill** (~968 lines) — Atomic design and component architecture for Vue 3
  - Atomic design principles (atoms → molecules → organisms → templates → pages)
  - Design as source of truth
  - Composition API + TypeScript patterns
  - Scoped CSS styling (no Tailwind)
  - Real-world examples

- **vue-state-management skill** (~713 lines) — Pinia + TanStack Query patterns for Vue applications
  - Pinia store organization and boundaries
  - TanStack Query for server state
  - Dumb component vs smart container distinction
  - State location decision tree

## [1.0.0] - 2026-10-27

### Added
- Initial release with 19 coordination skills for Squad:
  - **agent-collaboration** — Standard collaboration patterns for squad agents
  - **coordinator-init-mode** — Init Mode protocol when no team exists
  - **coordinator-response-mode** — Response Mode selection (Direct, Lightweight, Standard, Full)
  - **coordinator-source-of-truth** — File-by-file source-of-truth hierarchy
  - **cross-squad** — Coordinating work across multiple Squad instances
  - **cross-squad-communication** — Protocol for peer squad delegation
  - **error-recovery** — Standard recovery patterns for all squad agents
  - **git-workflow** — Squad branching model (dev-first, insiders preview)
  - **iterative-retrieval** — Max-3-cycle protocol for agent sub-tasks
  - **reflect** — Learning capture system for agent mistakes and patterns
  - **reviewer-protocol** — Reviewer rejection workflow and lockout semantics
  - **secret-handling** — Never read .env files or write secrets to committed files
  - **session-recovery** — Find and resume interrupted Copilot CLI sessions
  - **squad-conventions** — Core conventions and patterns used in Squad codebase
  - **squad-help** — How to actually use Squad
  - **squad-version-check** — Internals of squad version stamping and upgrade
  - **squad** — Squad's command catalog and interactive menu
  - **test-discipline** — Design assertions that prove contract and fail on regressions
  - **tiered-memory** — Three-tier agent memory model (hot/cold/wiki)

- **Project structure:**
  - Distributed via npm as @davidbirchall/squad-skills
  - Published to GitHub Packages (npm.pkg.github.com)
  - Included in `.github/skills/` directory
  - SKILLS_REGISTRY.md documenting all skills
  - GitHub Actions workflow for automatic publishing on git tag

- **Documentation:**
  - README.md with quick start guide
  - SKILLS_REGISTRY.md with complete skill catalog
  - CONTRIBUTING.md with contribution guidelines
  - docs/ARCHITECTURE.md explaining design and distribution
  - docs/SETUP_GUIDE.md with installation and usage instructions

---

## Legend

- **Added** — New features, skills, or plugins
- **Changed** — Changes in existing functionality or documentation
- **Deprecated** — Features marked for future removal
- **Removed** — Removed features, skills, or scripts
- **Fixed** — Bug fixes or corrections
- **Security** — Security-related changes

---

## Installation

Install the latest version:

```bash
npm install --save-dev @davidbirchall/squad-skills
```

See [docs/SETUP_GUIDE.md](./docs/SETUP_GUIDE.md) for per-project installation and plugin selection instructions.

## Versioning

This project follows [Semantic Versioning](https://semver.org/):
- **MAJOR** — Breaking changes to skill contracts or core architecture
- **MINOR** — New skills or plugins added, backwards compatible
- **PATCH** — Typos, clarifications, documentation updates

---

## Contributing

Contributions are welcome! See [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines on:
- Adding new skills to existing plugins
- Creating new plugins
- Publishing releases

---

**Maintainer:** [@davidbirchall](https://github.com/davidbirchall)

**License:** MIT
