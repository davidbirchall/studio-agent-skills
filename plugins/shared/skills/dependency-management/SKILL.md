---
name: dependency-management
description: Dependency management for any stack - choosing dependencies (need, maintenance health, licence, size, security record, transitive cost), committed lockfiles, pinning vs ranges, reading semver, update cadence and automated update PRs (Renovate and Dependabot principles), batching and grouping, major upgrade process with changelog reading and tests, audit and vulnerability triage by reachability and severity, licence compliance, removing unused dependencies, supply chain risks (typosquatting, install scripts, provenance), vendoring and forks, peer dependencies, deprecations, monorepo single-version policy, and Unity packages. Load when adding, upgrading, auditing or removing a dependency, configuring update bots, or responding to a vulnerability report.
---

# Dependency management

Every dependency is code you own the risk of but do not control. Security handling is in `application-security`; test strategy for upgrades is in `software-testing-strategy`; record significant choices in `technical-design`.

## Choosing a dependency
- Justify the need first. If the platform or a few lines of code cover it, do not add a package.
- Check maintenance: recent releases, responsive issues, more than one maintainer, a documented release process.
- Check licence compatibility with how you ship (permissive MIT/Apache-2.0/BSD vs copyleft GPL/AGPL). Unknown or missing licence means do not use.
- Check size and cost: install size, bundle impact for client code, and the transitive tree (`pnpm why <pkg>`, `npm ls`, `dotnet list package --include-transitive`).
- Check the security record: past advisories and how fast they were fixed.
- Prefer widely used, boring libraries over novel ones. Wrap third-party APIs behind a thin interface of your own when swapping later is plausible.

## Lockfiles and pinning
- Commit the lockfile (`pnpm-lock.yaml`, `package-lock.json`, `packages.lock.json`). Never hand-edit it. Resolve merge conflicts by regenerating.
- CI installs from the lockfile only (`pnpm install --frozen-lockfile`, `npm ci`, `dotnet restore --locked-mode`) so builds are reproducible and drift fails loudly.
- Applications: lockfile plus ranges is fine; the lockfile pins the real versions. Libraries: use ranges as wide as you have tested so consumers can dedupe.
- Pin exact versions for tools where patch changes break output (formatters, code generators, build tools) and for GitHub Actions (by commit SHA).

## Reading semver
- `MAJOR.MINOR.PATCH`: major may break, minor adds, patch fixes. Treat it as intent, not a guarantee.
- `^1.2.3` allows minor and patch; `~1.2.3` allows patch only. `0.x` versions can break on any release.
- Prerelease tags (`-beta`, `-rc`) are not for production unless deliberately chosen.

## Update cadence and bots
- Update continuously in small steps; large version gaps cost more than steady upgrades.
- Run Renovate or Dependabot. Schedule runs (weekly, off-hours), limit open PRs, and require CI to pass before review.
- Group related updates (a framework and its plugins, all `@types/*`, all dev tooling); keep majors in separate PRs; auto-merge only patch and minor of dev dependencies with green tests.
- Add a minimum release age (a few days) so freshly published or hijacked releases are not adopted immediately.
- Process bot PRs on a fixed cadence (for example at the start of a work session); unprocessed PRs mean the process is dead. Self-review or have the AI review each update against the changelog.

## Major upgrades
- Read the changelog and migration guide fully before starting; list breaking changes that touch your usage.
- Upgrade one major at a time, never skip several. Branch, upgrade, fix, run full tests, typecheck and a smoke test of the real app.
- Remove deprecated API usage before the upgrade when the old version still supports the replacement.
- Ship major upgrades alone so a rollback is one revert.

## Audit and vulnerability triage
- Run `pnpm audit`, `npm audit` or `dotnet list package --vulnerable` in CI and on a schedule.
- Triage by severity and reachability: is the vulnerable code path used, is input attacker-controlled, is it runtime or dev-only?
- Fix order: reachable and exploitable, then high/critical, then the rest. Upgrade the direct dependency; use overrides/resolutions only as a temporary bridge with a comment and expiry.
- Record accepted risks with a reason and review date. Do not silence audits wholesale.

## Licence compliance
- Generate a licence inventory in CI and fail on disallowed licences. Include transitive packages.
- Escalate copyleft or non-commercial licences before adoption, not after release.

## Removing dependencies
- Remove unused packages (`knip`, `depcheck`, .NET analyzers). Check that each import is declared and each declaration is imported.
- Keep `dependencies` vs `devDependencies` correct; test and build tools never ship.

## Supply chain
- Watch for typosquats: verify the exact name, publisher and download history before installing.
- Install scripts run arbitrary code. Disable by default (pnpm blocks unreviewed build scripts; `--ignore-scripts`) and allowlist the few that need them.
- Prefer packages with provenance attestations and signed releases. Use a private registry or scoped proxy for internal packages to prevent dependency confusion.
- Never run `curl | sh` installers in CI. Pin and review CI actions.

## Vendoring, forks and peers
- Vendor or fork only when upstream is abandoned or you need an urgent patch. Record why, the upstream version, and the plan to upstream the fix and return.
- Peer dependencies: declare them in libraries instead of bundling a second copy; satisfy them in the consuming app and fix unmet-peer warnings rather than ignoring them.
- Deprecated packages: plan replacement as soon as the notice appears; track it as a ticket.

## Monorepos and Unity
- One version of each dependency across the workspace. Centralise with pnpm catalogs, shared constraints, or `Directory.Packages.props`. Different versions need a recorded reason.
- Unity packages (UPM): pin versions in `Packages/manifest.json`, commit `packages-lock.json`, prefer registry versions over git URLs, and upgrade the editor and packages together.
