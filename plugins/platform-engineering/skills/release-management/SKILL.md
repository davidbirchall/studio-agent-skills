---
name: release-management
description: Provider-neutral release management - semantic versioning and when to bump, changelogs, release branches versus trunk tags, release candidates, release checklists, gates, freeze policy, hotfix process, rollback versus roll-forward, release notes, coordinating multi-package releases, release records, and deprecation policy. Load when planning or cutting a release, choosing a versioning or branching strategy, handling a hotfix or rollback, writing release notes, or deprecating features.
---

# Release management

Builds on `git-workflows`, `monorepo-management`, `build-systems`, `ci-cd-workflows`, `deployment-patterns`, and `monitoring-observability`. Verify tool commands against current docs.

## Versioning
- Use semantic versioning `MAJOR.MINOR.PATCH` for libraries, APIs and packages: MAJOR for breaking changes, MINOR for backward-compatible features, PATCH for backward-compatible fixes.
- Breaking means anything consumers can observe: removed or renamed exports, changed signatures or defaults, stricter validation, dropped runtime support, changed wire format.
- Pre-1.0 and pre-release tags (`1.4.0-rc.1`) signal instability; document what they promise.
- Applications and games may use calendar or build-number versions; keep one authoritative version source and stamp it into the artifact.
- Never reuse or move a published version. Fix forward with a new one.

## Branching
- Prefer trunk-based: merge to main behind flags, release by tagging a commit. Tags are annotated and immutable.
- Use a release branch (`release/1.4`) only when you must support several versions or stabilize while main moves on; cherry-pick fixes from main, not the reverse.
- Build the release artifact once from the tag and promote that same artifact through environments (`deployment-patterns`).
```bash
git tag -a v1.4.0 -m "Release 1.4.0"
git push origin v1.4.0
```

## Changelogs and notes
- Keep a `CHANGELOG.md` grouped by Added, Changed, Deprecated, Removed, Fixed, Security, newest first, dated.
- Generate from structured commit or change-file input where possible, then edit by hand for clarity.
- Release notes speak to users: what changed for them, upgrade steps, breaking changes first, known issues, links to docs.

## Release candidates and checklist
- Cut a release candidate from the proposed tag; soak it in staging with real-like data and monitoring before promotion.
- Checklist before tagging: CI green on the exact commit, changelog updated, version bumped, migrations reviewed and reversible or expand-contract, dependencies audited, flags set, rollback path confirmed, alerting active.
- Automate the checklist in the pipeline (`ci-cd-workflows`); ask the user only for what automation cannot judge.
- Sign or attest artifacts and keep a provenance record where supported.

## Gates and freezes
- Production promotion: risky changes need the agent to ask the user for explicit go-ahead; low-risk patches may auto-promote when gates pass.
- Write freeze windows (store review periods, peak events) in a file in the repo, with an emergency exception path.
- Prefer small, frequent releases; large batches raise risk and make rollback harder.

## Hotfixes
- Branch from the released tag, apply the minimal fix with a test, release as a PATCH, then merge or cherry-pick back to main so the fix is not lost.
- A hotfix uses the same pipeline and gates, possibly with fewer manual steps; never bypass tests entirely (`test-discipline`).

## Rollback and roll-forward
- Decide the default before release. Rollback: redeploy the previous artifact; fast and safe when no irreversible data change shipped. Roll-forward: ship a fix; needed after destructive migrations.
- Make schema changes backward compatible (expand, then contract in a later release) so rollback stays possible.
- Disable a feature via flag first when that is quicker than redeploying.
- Define triggers from SLO burn and error rate (`monitoring-observability`); watch a set window after each release.

## Multi-package releases
- In a monorepo (`monorepo-management`), version independently or in lockstep; choose once and document it.
- Release in dependency order, publish leaves first, and update internal ranges. Use a change-file or release tool to compute bumps; verify against its current docs.
- Test the combined set together before publishing; avoid partial publishes by gating on all packages building.

## Release records
- Mark breaking changes loudly in the changelog with migration notes. If users depend on you, post release notes where they look.
- Keep a release log of version, date, and outcome for future sessions and postmortems.

## Deprecation
- Deprecate before removing: announce, mark in code and docs, emit a warning, offer a replacement, and state the removal version and date.
- Remove only in a MAJOR release, after the stated notice period. Track usage to know who is affected.

## See also

Optional, if installed: technical-documentation (the shared plugin) for the broader discipline this skill applies. This skill stands on its own.
