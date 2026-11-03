---
name: upgrade-dependencies
description: Recipe for upgrading packages safely - inventory outdated and vulnerable dependencies, read changelogs, upgrade one at a time or grouped by ecosystem, keep the pnpm lockfile disciplined, work through a breaking-change checklist, run build, tests, and type-check, smoke test the runtime, triage security advisories, pin and plan rollback, plan major-version migrations, and record decisions. Names the skills to apply at each step, the exit check, and what to hand forward. Load when asked to update, bump, or upgrade dependencies, resolve audit findings, or migrate to a new major version.
---

# Upgrade dependencies

An ordered recipe, not a reference. Each named skill is optional: if its plugin is not installed, do the step anyway using general good practice. Do not copy skill content here; apply the skill and record only the output.

## When to use / when not to
- Use for routine bumps, audit fixes, or a major-version migration of a library, framework, or runtime.
- Not for swapping one library for another (that is a design decision; use decision-making and technical-design), or for fixing a bug that happens to involve a package (use fix-a-bug).

## Steps
1. Inventory.
   - Goal: know what is outdated, vulnerable, and unused.
   - Apply: dependency-management (shared plugin), monorepo-management and build-systems (platform-engineering plugin) if workspaces exist.
   - Exit: a list with current version, target version, and whether each is a patch, minor, or major bump; direct dependencies separated from transitive ones. Hand on: the list.
2. Triage security advisories.
   - Goal: order the work by risk.
   - Apply: application-security (shared plugin), dependency-management (shared plugin).
   - Exit: each advisory marked reachable or not reachable in this codebase, with a fix version or mitigation. Fix reachable high-severity items first. Hand on: the ordered list.
3. Read the changelogs.
   - Goal: predict breakage before it happens.
   - Apply: research-practice (knowledge plugin), source-summarisation (knowledge plugin).
   - Exit: for every major bump and any minor with notable notes, a short list of breaking changes, removed APIs, and new minimum runtime versions. Hand on: the breaking-change checklist.
4. Plan the batches.
   - Goal: small, bisectable changes.
   - Apply: task-decomposition (agent-practices plugin), git-workflows (platform-engineering plugin).
   - Exit: patch and minor bumps grouped by ecosystem (for example, all linting packages together); each major bump alone; one commit per batch. Ask the user one question only if a major migration carries a real tradeoff, such as staying on a supported older line. Hand on: the batch plan.
5. Upgrade one batch with lockfile discipline.
   - Goal: reproducible installs.
   - Apply: dependency-management (shared plugin), build-systems (platform-engineering plugin).
   - Exit: changes made with pnpm (pnpm update or pnpm add), the lockfile committed with the manifest, install run with a frozen lockfile to prove it is consistent, no hand-edited lockfile, no stray second lockfile. Hand on: the commit.
6. Fix breakage against the checklist.
   - Goal: restore green without changing behaviour.
   - Apply: debugging (shared plugin), minimal-change-discipline (agent-practices plugin), typescript-conventions (shared plugin).
   - Exit: build, type-check, lint, and the test suite pass; deprecation warnings are noted; no tests were weakened to pass.
7. Runtime smoke test.
   - Goal: catch what tests miss.
   - Apply: verify-before-done (agent-practices plugin), backend-testing or frontend-testing as relevant.
   - Exit: the app starts, one main flow is exercised, and a production build runs; bundle size or start time is compared if the package is large. Hand on: the observations.
8. Pin and prepare rollback.
   - Goal: be able to undo.
   - Apply: release-management (platform-engineering plugin), git-workflows (platform-engineering plugin).
   - Exit: risky packages use exact versions with a reason noted; reverting the batch commit restores the previous state cleanly.
9. Plan major migrations.
   - Goal: handle large jumps in stages.
   - Apply: technical-design (shared plugin), software-architecture (shared plugin).
   - Exit: for a major jump, an ordered plan (compatibility shims, codemods, step through intermediate versions if required), each stage green before the next.
10. Record decisions.
   - Goal: stop repeating the same research.
   - Apply: knowledge-capture (knowledge plugin), technical-documentation (shared plugin), session-handoff (agent-practices plugin).
   - Exit: notes list what was upgraded, what was deliberately held back and why, and the next review date.

## Skip rules
- Single patch bump with green tests: skip steps 3 and 9.
- Advisory-only fix with a patched release: do steps 2, 5, 6, and 7 only.
- Never skip the frozen-lockfile check or the test run.

## Common failure modes
- Upgrading everything at once, then being unable to find the culprit.
- Lockfile drift from mixing package managers.
- Treating audit output as a to-do list without checking reachability.
- Passing tests but a broken production build.
- Silent major bump through a loose version range.

## Checklist
- [ ] Inventory and advisory triage done.
- [ ] Changelogs read for majors.
- [ ] Batches small, one commit each.
- [ ] Lockfile consistent and committed.
- [ ] Build, type-check, lint, tests pass.
- [ ] Runtime smoke test done.
- [ ] Rollback is a clean revert.
- [ ] Held-back packages and decisions recorded.
