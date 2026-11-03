---
name: git-workflows
description: Git workflows for solo and agent-driven development - trunk-based development with short-lived branches, branch naming, small focused changes, rebase vs merge vs squash, conventional-commit style messages, branch protection driven by automated checks (no approval chains), client and server hooks, force-push safety with lease, recovering mistakes with reflog, worktrees for parallel work, and handling large files and secrets in history. Load when choosing a branching model, naming branches, writing commits, configuring branch protection or hooks, resolving history problems, or running parallel agents on one repo.
---

# Git workflows

Pairs with `ci-cd-workflows` (required checks), `release-management` (tags and versions), `monorepo-management` and Squad `secret-handling`. Verify flags against the installed git version.

## Branching model
- Default to trunk-based: short-lived branches (hours to a couple of days) merged to the main branch often. Keep at most one or two branches in flight.
- Use one branch per task or issue; do not stack unrelated changes on a branch.
- Hide unfinished work behind a feature flag rather than a long-lived branch.
- Long-lived release branches only when you must patch old versions; backport by cherry-pick.

## Branch naming
- Pattern `<type>/<issue-id>-<kebab-slug>`, lowercase, no spaces: `feat/123-user-export`, `fix/208-null-token`.
- Types match commit types: feat, fix, docs, refactor, test, chore, ci.
- Squad agents use the convention from the repo instructions (for example `squad/<issue>-<slug>`); follow it exactly.

## Small changes
- One logical change per branch or PR; aim for under roughly 400 changed lines excluding generated files and lockfiles.
- Separate refactors and mechanical moves from behaviour changes.
- Change description (PR or commit body): what, why, how tested, risk, rollback. Link the issue.
- A PR is optional solo; use one when you want CI to run before merging or want a durable record. Self-review the diff before merging (code-review in the shared plugin, if installed).

## Rebase, merge, squash
- Rebase your own unpublished branch onto main to stay current: `git fetch && git rebase origin/main`.
- Never rebase commits already pushed to a shared branch.
- Squash-merge by default for a linear, one-commit-per-PR history; the PR title becomes the commit subject.
- Use a merge commit only when preserving a multi-commit history matters.

## Commit messages
- Conventional style: `type(scope): imperative summary`, subject under 72 chars, no trailing period.
- Body explains why, wrapped near 72 columns. Footer: `Closes #123`, trailers.
- Breaking change: `!` after type or a `BREAKING CHANGE:` footer.
```
fix(auth): reject expired refresh tokens

Expired tokens were accepted when clock skew exceeded 30s.

Closes #208
```

## Protected branches and checks
- Protect main with automation, not approvals: require passing status checks, up-to-date branch, no force push, no deletion.
- Do not require a second approver; you are the only reviewer. The merge gate is green CI plus your self-review checklist (and an AI review pass for risky changes).
- If you work with others: require one approval and code-owner review on owned paths.
- Agent-authored changes get the same gate; ask the user before merging anything risky or irreversible.

## Hooks
- Client hooks (pre-commit, commit-msg) give fast feedback: format, lint staged files, validate message. Keep them under a few seconds.
- Manage hooks in the repo (for example a pnpm-installed hook manager) so they install automatically.
- Hooks are bypassable; CI repeats every check and is the authority.

## Force-push safety
- Use `git push --force-with-lease` on your own branch only; never plain `--force`.
- Never force-push protected or shared branches.
- Before rewriting, create a backup ref: `git branch backup/<name>`.

## Recovery
- `git reflog` lists where HEAD has been; restore with `git reset --hard <sha>` or `git branch rescue <sha>`.
- Undo a published commit with `git revert <sha>`, not a rewrite.
- Abort a bad operation: `git rebase --abort`, `git merge --abort`.
- Prefer `git restore` and `git switch` over `checkout` for clarity.

## Worktrees
- One worktree per concurrent task or agent: `git worktree add ../repo-123 -b fix/123-slug origin/main`.
- Never have two agents edit the same working directory. Remove with `git worktree remove` when done.
- A branch can be checked out in only one worktree at a time.

## Hygiene
- Never commit secrets, `.env` files, build output or large binaries; use `.gitignore` and Git LFS for large assets (Unity assets, art).
- If a secret lands in history, rotate it first (see `secrets-management`), then purge history.
- Commit lockfiles; keep `.gitattributes` for line endings and LFS patterns.

## See also

Optional, if installed: code-review (the shared plugin) for the broader discipline this skill applies. This skill stands on its own.
