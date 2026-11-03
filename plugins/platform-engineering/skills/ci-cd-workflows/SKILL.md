---
name: ci-cd-workflows
description: CI/CD pipeline design, tool-neutral with GitHub Actions illustrations - stages (lint, typecheck, test, build, scan, deploy), fail fast ordering, parallel jobs, dependency caching, required checks, path filters, secrets handling in CI, OIDC and short-lived credentials, promotion between environments, flaky test policy, pipeline as code, runner security, concurrency and timeouts. Load when creating or reviewing pipelines, speeding up or debugging CI, setting required checks, handling secrets or cloud credentials in CI, or defining how builds are promoted to production.
---

# CI/CD workflows

Builds on `git-workflows` (protected branches), `build-systems` (frozen installs, artifacts) and `monorepo-management` (affected builds). Deploy mechanics are in `deployment-patterns`; secrets in `secrets-management` and Squad `secret-handling`; test quality in Squad `test-discipline`. Verify syntax against current platform docs.

## Stages
- Order by cost and signal: lint and format, typecheck, unit tests, build, integration tests, security scan, publish, deploy.
- Fail fast: cheap checks first; cancel dependent jobs on failure.
- CI runs the same commands developers run locally (`pnpm lint`, `pnpm typecheck`, `pnpm test`, `pnpm build`); no logic hidden in CI-only scripts.
- Build the artifact once and reuse it in later stages.

## Pipeline as code
- Pipelines live in the repo, reviewed like code. Keep YAML thin and put logic in versioned scripts.
- Reuse via shared workflows or templates; pin them to a tag or commit SHA.
```yaml
on:
  pull_request:
  push: { branches: [main] }
concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true
permissions:
  contents: read
jobs:
  check:
    runs-on: ubuntu-latest
    timeout-minutes: 15
    steps:
      - uses: actions/checkout@<pinned-sha>
      - run: pnpm install --frozen-lockfile
      - run: pnpm lint && pnpm typecheck && pnpm test
```

## Parallelism and caching
- Run independent jobs (lint, typecheck, test shards) in parallel; use a matrix for Node versions or OS only when you support them.
- Shard slow test suites; balance by historic duration.
- Cache the package store keyed on the lockfile hash; use the remote task cache where available.
- Cancel superseded runs on the same branch with concurrency groups; never cancel deploy runs mid-flight.

## Required checks and path filters
- Mark the stable set of jobs as required on protected branches; require up-to-date branches.
- Path filters skip irrelevant work but must not leave a required check pending forever; use an always-running gate job that reports success when skipped.
- Changes to lockfiles, CI config or shared tooling always run the full pipeline.

## Secrets and credentials
- Default permissions to read-only; grant write scopes per job.
- Prefer OIDC federation and short-lived, scoped credentials over stored long-lived keys; the trust policy should limit repo, branch or environment.
- Store remaining secrets in the platform secret store, scoped to environments; never echo them, and rely on log masking only as a backstop.
- Do not expose secrets to workflows triggered from forks or untrusted PRs.
- Never put secrets in artifacts, caches or build args.

## Promotion between environments
- Flow: build once -> dev/preview -> staging -> production, promoting the same immutable artifact.
- Gate production with required checks, smoke tests and, where warranted, manual approval via environment protection rules.
- Deploys must be repeatable and have a documented rollback; see `deployment-patterns` and `release-management`.
- Preview environments per PR are torn down on close.

## Flaky tests
- A flaky test is a bug: quarantine it within a day (tracked issue, deadline), do not silently rerun.
- Automatic retries only at test level, reported visibly; never retry the whole pipeline to hide failures.
- Track failure rate per test and fix root causes (shared state, timing, network, order).

## Runner security
- Treat PR code as untrusted. Use ephemeral runners for untrusted workloads; never run fork PRs on self-hosted runners with network or secret access.
- Pin third-party actions or steps to commit SHAs and review updates.
- Limit outbound network where practical; run dependency installs without extra privileges.
- Scan for secrets, vulnerable dependencies, and misconfiguration as pipeline stages.

## Timeouts and observability
- Set a timeout on every job and a budget on total pipeline time; alert when exceeded.
- Upload test reports and coverage as artifacts with retention limits.
- Track lead time, failure rate and median duration; see `monitoring-observability`.

## See also

Optional, if installed: software-testing-strategy (the shared plugin) for the broader discipline this skill applies. This skill stands on its own.
