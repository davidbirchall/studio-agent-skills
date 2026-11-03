# squad-skills-platform-engineering

Provider-neutral DevOps and platform engineering skills: git workflows, monorepo management, build systems, CI/CD, environment configuration, secrets management, containerization, deployment patterns, infrastructure as code, monitoring and observability, and release management.

Version `0.1.0`, 11 skills.

## Install

```
copilot plugin install ./plugins/platform-engineering
```

## Skills

| Skill | Purpose | Load when |
|-------|---------|-----------|
| `build-systems` | Deterministic builds, caching, artifacts, dependency pinning | Making builds reliable and fast |
| `ci-cd-workflows` | Pipeline stages, required checks, caching, short-lived credentials | Designing or fixing pipelines |
| `containerization` | Node Dockerfiles, non-root, scanning, health checks, compose | Containerising an app |
| `deployment-patterns` | Rolling, blue/green, canary, migrations, rollback | Planning a deployment |
| `environment-configuration` | Typed config, environment parity, feature flags, .env handling | Adding or changing configuration |
| `git-workflows` | Branching, PR size, merge strategy, hooks, recovery | Defining or applying git practice |
| `infrastructure-as-code` | Modules, remote state, plan-before-apply, drift, policy | Defining infrastructure |
| `monitoring-observability` | Golden signals, SLOs, alert design, incident response | Setting up platform monitoring |
| `monorepo-management` | Workspace layout, dependency direction, versioning, ownership | Organising a multi-package repo |
| `release-management` | Semver, changelogs, hotfixes, rollback, deprecation | Cutting or coordinating a release |
| `secrets-management` | Stores, injection, rotation, leak response | Handling credentials and keys |

## Related plugins

Works well with: shared, backend, frontend, game-development (build and release). Skills may mention skills from other plugins in a short "See also" note; each skill stands on its own if those plugins are not installed.
