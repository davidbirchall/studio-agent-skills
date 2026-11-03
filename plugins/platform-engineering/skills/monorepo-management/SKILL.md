---
name: monorepo-management
description: Monorepo management for TypeScript/Node and multi-project stacks - apps/packages/tooling layout, workspace boundaries, one-way dependency direction rules, shared config packages, internal package conventions, fixed vs independent versioning, affected-only builds and tests, task graph and cache principles, code ownership, and when not to use a monorepo. Tool-neutral; tool-specific task-runner configuration belongs in a separate tool skill. Load when structuring a repo with multiple apps or packages, setting dependency rules, sharing config, choosing a versioning strategy, speeding up CI with affected builds, or deciding monorepo vs polyrepo.
---

# Monorepo management

Builds on `build-systems` (caching, lockfiles), `ci-cd-workflows` (affected checks) and `git-workflows` (ownership and review). Task-runner specifics (for example Turbo or Nx config) belong in a separate tool skill, not here.

## Layout
- Top-level split by role: `apps/` (deployables), `packages/` (shared libraries), `tooling/` (shared configs and scripts).
```
apps/api  apps/web  apps/worker
packages/domain  packages/ui  packages/sdk
tooling/eslint-config  tooling/tsconfig  tooling/scripts
pnpm-workspace.yaml
```
- Declare workspaces once: `packages: ['apps/*', 'packages/*', 'tooling/*']` in `pnpm-workspace.yaml`.
- A Unity project can live in the repo as its own app; keep it out of the Node workspace globs and give it its own build.

## Boundaries
- Every package has a name, a single purpose, an explicit public entry point (`exports` in package.json) and its own tests.
- Consumers import only the public entry; deep imports into another package's `src` are forbidden.
- Reference internal packages with the workspace protocol: `"@acme/domain": "workspace:*"`.
- Each package declares all of its own dependencies; no relying on hoisted ones (pnpm strictness helps enforce this).

## Dependency direction
- Rule: apps depend on packages; packages depend on lower-level packages; never the reverse, never cycles.
- Layers example: `apps` -> `feature packages` -> `domain/util packages` -> nothing.
- Apps never import from other apps; extract shared code into a package.
- Enforce in CI with a lint rule or dependency-graph check that fails on cycles and forbidden edges.

## Shared config
- Publish shared ESLint, TypeScript, formatter and test configs as `tooling/*` packages and extend them; no copy-paste per package.
- Use TypeScript project references or per-package builds so type checking is incremental.
- Keep root scripts thin: they delegate to per-package scripts of the same name (`build`, `test`, `lint`, `typecheck`).

## Versioning
- Fixed (lockstep): all packages share one version; simple, good for tightly coupled libraries released together.
- Independent: each package versions by its own changes; good for libraries consumed externally. Needs change files and automated changelogs.
- Private apps and internal-only packages usually need no version bumps; version what you publish. See `release-management`.

## Affected-only work
- Compute changed packages from the git diff against the merge base, then add their dependents via the graph.
- Run lint, typecheck, test and build for affected packages only on PRs; run everything on main and on root config or lockfile changes.
- Treat changes to shared tooling, lockfile or CI config as affecting everything.

## Task graph and caching
- Declare task dependencies (build a package's dependencies before it) so order and parallelism come from the graph.
- Cache by inputs: source, dependency versions, config, env vars that affect output. Cache only deterministic tasks.
- Declare outputs explicitly; undeclared outputs make cache hits incorrect.
- Share the cache between CI and developers via a remote cache with access control.

## Ownership
- Optionally add a CODEOWNERS file mapping paths to owners. If you work with others: require owner review on protected branches.
- Every package has a README stating purpose and public API.

## When not to use
- Skip a monorepo for unrelated projects with separate release cadences or access policies, or when tooling cost exceeds the sharing benefit.
- Warning signs: constant cross-package breakage, CI minutes dominated by unaffected work, a single failure blocking all packages. Fix the graph and caching first, then reconsider the split.

## See also

Optional, if installed: software-architecture (the shared plugin) for the broader discipline this skill applies. This skill stands on its own.
