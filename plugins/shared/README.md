# squad-skills-shared

Shared engineering capabilities that apply across frontend, backend, AI and game development: software architecture, technical design, TypeScript conventions, testing strategy, application security, performance engineering, code review, debugging, dependency management, and technical documentation.

Version `0.4.0`, 13 skills.

## Install

```
copilot plugin install ./plugins/shared
```

## Skills

| Skill | Purpose | Load when |
|-------|---------|-----------|
| `accessibility-baseline` | Cross-platform accessibility baseline for any user interface other than a Vue/Nuxt web page - CLIs, documents, native and desktop apps, mobile apps,... | Building or reviewing a non-web UI, CLI output, document, email template, or any deliverable a person must read or operate |
| `application-security` | Threat modelling, OWASP categories, validation, least privilege | Reviewing or building secure code |
| `code-review` | Author and reviewer checklists, comment severity, AI-generated code | Reviewing or preparing a PR |
| `debugging` | Reproduce, bisect, hypothesis-driven, root cause, regression test | Diagnosing a bug |
| `dependency-management` | Choosing, pinning, update cadence, audits, supply chain | Adding or upgrading dependencies |
| `incident-response` | Provider-neutral incident response - severity levels, the lifecycle from detection to resolution, roles (incident commander, communications,... | Handling a production incident, setting up on-call, writing a runbook or postmortem, or defining severity and escalation |
| `performance-engineering` | Measure first, budgets, bottlenecks, regression guards | Investigating or preventing slowness |
| `scripting-cli-automation` | Writing small scripts and command-line tools to automate repeatable tasks in Node and TypeScript (default) or shell - when to script versus do by... | Automating a repeated task, adding a script or CLI to a project, or reviewing a script for safety |
| `software-architecture` | Quality attributes, boundaries, dependency direction, C4, decision records | Shaping system structure |
| `software-testing-strategy` | Test levels, risk-based testing, flakiness, coverage as a signal | Deciding how to test |
| `technical-design` | Design doc process, options and trade-offs, rollout, template | Designing a non-trivial change |
| `technical-documentation` | Audience, doc types, docs-as-code, runbooks, Mermaid | Writing or reviewing docs |
| `typescript-conventions` | Strictness, unknown over any, no enums, unions, schema-derived types | Writing or reviewing TypeScript |

## Related plugins

Works well with: frontend, backend, ai-engineering, game-development apply these disciplines to their stacks. Skills may mention skills from other plugins in a short "See also" note; each skill stands on its own if those plugins are not installed.
