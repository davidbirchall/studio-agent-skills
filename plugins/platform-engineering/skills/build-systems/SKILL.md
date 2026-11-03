---
name: build-systems
description: Build system principles for TypeScript/Node, Nuxt and Unity projects - deterministic and hermetic builds, lockfiles and frozen installs, dependency pinning and automated updates, caching and incremental builds, build-time vs runtime configuration, artifact naming, checksums and provenance, reproducibility checks, and measuring build speed. Tool-neutral with pnpm examples. Load when making builds repeatable, fixing works-on-my-machine failures, tuning caches, separating build and runtime config, producing release artifacts, or slowing-build investigations.
---

# Build systems

Used by `ci-cd-workflows`, `monorepo-management` and `containerization`. Config separation details in `environment-configuration`. Verify flags against the installed tool versions.

## Determinism
- Same inputs must give the same output. Inputs: source, lockfile, toolchain versions, build config, and declared env vars.
- Pin the toolchain: Node version in `.nvmrc` or `engines`, package manager via the `packageManager` field, Unity version in `ProjectVersion.txt`.
- Do not embed timestamps, hostnames, random IDs or absolute paths in outputs; if needed, inject a commit SHA instead.
- Build in a clean checkout in CI; never from a dirty working tree.

## Lockfiles
- Commit the lockfile and review its diff.
- Install frozen in CI so drift fails the build: `pnpm install --frozen-lockfile`.
- Never edit lockfiles by hand; regenerate with the package manager.
- One package manager per repo; block others (for example via `engines` and CI check).

## Dependency pinning and updates
- Applications: exact or lockfile-pinned versions. Libraries: ranges in package.json, lockfile for development.
- Automate updates with a bot in small grouped PRs; CI must pass before merge.
- Scan dependencies for known vulnerabilities in CI; triage by reachability and severity.
- Prefer few, well-maintained dependencies; check install scripts before adding a package.
- Pin CI actions or build images to immutable references (digest or commit SHA) where supported.

## Hermetic builds
- Declare every input; a build must not reach the network after dependencies are fetched, except via a locked, cached source.
- Do not read from global state: home-directory configs, ambient env vars, system-installed tools not pinned.
- Use containers or pinned toolchain images when the host cannot be controlled.

## Caching and incremental builds
- Cache key = hash of lockfile + toolchain version + relevant config. Include the OS and architecture.
- Cache the package store and task outputs, not `node_modules` wholesale unless verified safe.
- Use incremental compilation (TypeScript `incremental`, project references; Unity Library cache) and keep their cache files out of git.
- Invalidate on toolchain change. A stale cache that hides errors is worse than no cache; periodically run an uncached build to compare.

## Build vs runtime config
- Build once, deploy many: artifacts must not contain environment-specific values.
- Server apps read config from the environment at startup. Client bundles inline values at build time, so only public, non-secret values go there.
- Never bake secrets into artifacts, images or source maps; see `secrets-management`.
- Validate required config at startup and fail fast.

## Artifacts and provenance
- Name artifacts with version and commit SHA; one immutable artifact per commit.
- Record a checksum (for example SHA-256) and publish it alongside the artifact.
- Generate a dependency inventory (SBOM) and build provenance attestation where the platform supports it; sign artifacts per the platform's current docs.
- Promote the same artifact through environments rather than rebuilding; see `deployment-patterns`.

## Reproducibility check
- Build twice from the same commit in separate clean environments and compare checksums; investigate differences (timestamps, ordering, paths).
- Document the one command that builds everything: `pnpm install --frozen-lockfile && pnpm build`.

## Build speed
- Measure first: record wall time per task and cache hit rate per run; track over time.
- Fix in order: cache hits, parallelism, doing less (affected-only), then faster hardware.
- Use per-task timing output from your tool; set a budget and alert on regressions.
- Split slow tasks, remove unused dependencies, and avoid barrel files that defeat incremental builds.
