# Squad Skills Registry

This is the centralized skills library for all **@davidbirchall/squad-skills** projects. Skills are reusable prompt patterns, decision frameworks, and operational protocols that empower Squad coordinators and agents.

## Installation

Install in any Squad project:

```bash
npm install @davidbirchall/squad-skills --save-dev
```

The package is available on the public npm registry — no authentication required.

Then reference skills from `node_modules/@davidbirchall/squad-skills/.github/skills/` in your coordinator instructions or `.copilot/mcp-config.json`.

## Skills Directory

### Coordinator Protocol

Core protocols that guide Squad coordinators through decision-making and team orchestration.

| Skill | Purpose | When to load | Location |
|-------|---------|--------------|----------|
| **squad** | Interactive command catalog & routing menu | On `/squad` request | `.github/skills/squad/SKILL.md` |
| **coordinator-init-mode** | Two-phase team setup (propose → confirm → scaffold) | Fresh Squad setup | `.github/skills/coordinator-init-mode/SKILL.md` |
| **coordinator-response-mode** | Decision table: Direct/Lightweight/Standard/Full modes | Before routing work | `.github/skills/coordinator-response-mode/SKILL.md` |
| **coordinator-source-of-truth** | File-by-file source-of-truth hierarchy & conflict resolution | State disputes | `.github/skills/coordinator-source-of-truth/SKILL.md` |

### Team Collaboration

Patterns for how agents collaborate, handoff work, and maintain consistency.

| Skill | Purpose | When to load | Location |
|-------|---------|--------------|----------|
| **agent-collaboration** | Standard collaboration patterns (worktree awareness, decisions, cross-agent comms) | Multi-agent work | `.github/skills/agent-collaboration/SKILL.md` |
| **cross-squad** | Coordinating work across multiple Squad instances (discovery, delegation, disambiguation) | Multi-squad setup | `.github/skills/cross-squad/SKILL.md` |
| **cross-squad-communication** | Protocol for queries, task delegation, context sharing between Squad instances | Inter-squad delegation | `.github/skills/cross-squad-communication/SKILL.md` |
| **error-recovery** | Standard recovery patterns when work fails; adapt rather than just report | On agent failure | `.github/skills/error-recovery/SKILL.md` |

### Process & Discipline

Quality gates, review protocols, and coding discipline practices.

| Skill | Purpose | When to load | Location |
|-------|---------|--------------|----------|
| **reviewer-protocol** | Reviewer rejection workflow & strict lockout semantics | Before review gate | `.github/skills/reviewer-protocol/SKILL.md` |
| **test-discipline** | Design assertions that prove the actual contract & fail on regressions | Before test writing | `.github/skills/test-discipline/SKILL.md` |
| **secret-handling** | Never read .env files or write secrets to committed .squad/ files | Before any state write | `.github/skills/secret-handling/SKILL.md` |

### Git & Workflow

Branching models, version management, and session coordination.

| Skill | Purpose | When to load | Location |
|-------|---------|--------------|----------|
| **git-workflow** | Squad dev-first branching model with insiders preview channel | Branch strategy | `.github/skills/git-workflow/SKILL.md` |
| **squad-version-check** | Internals of version stamping, upgrade mechanics, registry probing | During `squad upgrade` | `.github/skills/squad-version-check/SKILL.md` |
| **session-recovery** | Find and resume interrupted Copilot CLI sessions | On session restart | `.github/skills/session-recovery/SKILL.md` |

### Memory & Learning

Capturing and reusing knowledge across sessions and team members.

| Skill | Purpose | When to load | Location |
|-------|---------|--------------|----------|
| **tiered-memory** | Three-tier agent memory model (hot/cold/wiki) for context reduction | Per spawn config | `.github/skills/tiered-memory/SKILL.md` |
| **reflect** | Learning capture system (HIGH/MED/LOW confidence patterns) to prevent repeating mistakes | After user corrections | `.github/skills/reflect/SKILL.md` |
| **iterative-retrieval** | Max-3-cycle protocol for agent sub-tasks with WHY context & coordinator validation | When spawning sub-agents | `.github/skills/iterative-retrieval/SKILL.md` |

### Convention & Standards

Documented practices, conventions, and decision frameworks used throughout Squad projects.

| Skill | Purpose | When to load | Location |
|-------|---------|--------------|----------|
| **squad-conventions** | Core conventions and patterns used in the Squad codebase | Baseline context | `.github/skills/squad-conventions/SKILL.md` |
| **squad-help** | How to actually use Squad — team setup, commands, initialization | First-time use | `.github/skills/squad-help/SKILL.md` |

### Creative & Ideas

Tools for capturing, developing, and preserving ideas systematically.

| Skill | Purpose | When to load | Location |
|-------|---------|--------------|----------|
| **idea-capture** | Capture, clarify, and develop creative ideas (mechanics, concepts, story, technology, etc.) with enough substance for future revisiting | Recording a new idea | `.github/skills/idea-capture/SKILL.md` |

### Vue 3 Development

Reusable patterns and standards for Vue 3 projects using Composition API, Pinia, TanStack Query, and TypeScript.

| Skill | Purpose | When to load | Location |
|-------|---------|--------------|----------|
| **vue-component-patterns** | Composition API components, TypeScript props/emits, atomic design hierarchy, design-driven development, scoped CSS styling | Starting new Vue component | `.github/skills/vue-component-patterns/SKILL.md` |
| **vue-container-presenter-pattern** | Smart Container / Dumb Presenter split, clear separation of data management and presentation, reusable presenters, testable containers | Structuring feature components | `.github/skills/vue-container-presenter-pattern/SKILL.md` |
| **vue-state-management** | Pinia store patterns, state boundaries (dumb components, smart containers), TanStack Query integration, application vs component state | Implementing state management | `.github/skills/vue-state-management/SKILL.md` |
| **vue-testing-strategy** | Vitest + Vue Testing Library, presenter/container testing, store testing, TanStack Query testing with MSW, Playwright E2E | Writing tests before features | `.github/skills/vue-testing-strategy/SKILL.md` |
| **vue-styling-architecture** | Design token system, CSS variables for theming, scoped CSS patterns, dark mode support via prefers-color-scheme, semantic class naming | Implementing component styles | `.github/skills/vue-styling-architecture/SKILL.md` |
| **vue-form-validation** | Form state management, client + server validation, error display patterns, accessibility, submission flow, multi-step forms | Building forms | `.github/skills/vue-form-validation/SKILL.md` |
| **vue-accessibility** | Semantic HTML, ARIA attributes, keyboard navigation, focus management, accessible components, axe testing, WCAG 2.1 AA compliance | Ensuring component accessibility | `.github/skills/vue-accessibility/SKILL.md` |

## Skill Usage in Projects

### Option 1: Copy Skills into Your Project (Recommended for Private Use)

```bash
# After installing @davidbirchall/squad-skills
cp -r node_modules/@davidbirchall/squad-skills/.github/skills .github/
```

### Option 2: Reference Directly from node_modules

Update your `.github/copilot-instructions.md` or coordinator to load skills from:
```
node_modules/@davidbirchall/squad-skills/.github/skills/{skill-name}/SKILL.md
```

### Option 3: Import into Squad MCP Config

If using an MCP server that supports skill loading, reference:
```json
{
  "skillPaths": [
    "node_modules/@davidbirchall/squad-skills/.github/skills"
  ]
}
```

## Versioning & Updates

This package follows **semantic versioning**:

- **MAJOR** — Breaking changes to skill structure or coordinator contracts
- **MINOR** — New skills or backwards-compatible enhancements
- **PATCH** — Corrections, clarifications, example updates

Check `package.json` version and GitHub releases for update notes.

To update in a project:
```bash
npm update @davidbirchall/squad-skills
```

## Contributing

Skills in this library are authored by:
- **Coordinator** — squad orchestration & decision protocols
- **Agents** — learned patterns from successful work (captured via `reflect` skill)
- **Squad Team** — project-specific playbooks that generalize well

To propose a new skill or update an existing one:
1. Create a feature branch: `git checkout -b squad/new-skill-name`
2. Add or edit the skill in `.github/skills/{skill-name}/SKILL.md`
3. Update this registry
4. Open a PR with rationale
5. On merge, tag a release and publish to npm

## License

MIT — reuse freely within the @davidbirchall scope and with attribution.

---

**Last updated:** 2026-10-28  
**Package:** @davidbirchall/squad-skills  
**Registry:** GitHub Packages  
**Total Skills:** 27 (19 Coordinator + 7 Vue 3 Development + 1 Creative)
