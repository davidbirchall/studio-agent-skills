---
name: turborepo-workflow
description: Turborepo conventions for monorepos only — task pipeline (lint, typecheck, test, build, storybook build), caching, PR filtering, shared config package, pnpm workspaces. Load when the repo is already a monorepo; never for single-package projects.
---

# Turborepo workflow

**Monorepos only.** A single-package repo is the default. Use workspaces and Turborepo only when the app or library genuinely lives in a monorepo. Do not add Turbo to a single-package repo or convert a repo to a monorepo to use it.

## Workspaces (pnpm)
- Declare `packages: ["apps/*", "packages/*"]` in `pnpm-workspace.yaml` at the root.
- Internal deps use the `workspace:` protocol: `"@acme/ui": "workspace:*"`.
- Inspect with `pnpm -r ls --depth -1`; run in one package with `pnpm --filter <name> <script>`.
- Shared lint/format/TS config: a dedicated config package that apps extend (same pattern as a shared config package such as `@acme/config`; see `frontend-code-quality`). Don't copy configs between packages.

## Pipeline (`turbo.json`)
```json
{
  "$schema": "https://turborepo.com/schema.json",
  "tasks": {
    "lint": { "dependsOn": ["^build"] },
    "typecheck": { "dependsOn": ["^build"] },
    "test": { "dependsOn": ["^build"] },
    "build": { "dependsOn": ["^build"], "outputs": [".output/**", ".nuxt/**", "dist/**"] },
    "build-storybook": { "dependsOn": ["^build"], "outputs": ["storybook-static/**"] }
  }
}
```
- `^build` = build workspace dependencies first. Include it only where a task needs built dependency output.
- Tasks that produce files declare `outputs`; lint/typecheck/test produce none (omit `outputs`; add `coverage/**` to `test` only if coverage is generated).
- Keep `build-storybook` only in packages that have Storybook (see `storybook-workflow`).
- Package scripts must use the same names as the task keys.

## Task graph details
- `dependsOn: ["^build"]` = dependencies' build; `["build"]` (no caret) = this package's own build first; `["//#task"]` = a root task. Prefer the narrowest dependency that is correct: lint and typecheck needing `^build` only matters when packages consume built output rather than source.
- `inputs` narrows what busts the cache (default is all tracked files in the package). Add `"$TURBO_DEFAULT$"` when extending the default: `"inputs": ["$TURBO_DEFAULT$", "!**/*.md"]`.
- `outputs` must list every produced directory, or a cache hit restores nothing and downstream tasks fail. Exclude caches inside outputs (`"!.nuxt/cache/**"`) where relevant.
- Long-running tasks (`dev`, `storybook`): `"cache": false, "persistent": true`. Nothing should `dependsOn` a persistent task.
- Verify key names and syntax against the installed Turbo version (`pnpm turbo --version`, docs for that release).

## Environment variables and hashing
- Env vars that change build output must be declared (`env` per task, `globalEnv` for all) or they are not part of the hash and you get stale cache hits.
- Do not declare secrets or per-run noise (timestamps, CI run ids) as hashed env; that guarantees misses.
- Strict env mode passes only declared vars to tasks; if a build cannot see a variable, declare it (or `passThroughEnv` for values that must not affect the hash).
- Root files that affect everything (`pnpm-lock.yaml`, root tsconfig, shared config package) belong in `globalDependencies` if they are not already picked up.

## Running
- Everything: `pnpm turbo run lint typecheck test build`.
- PRs: affected packages only, `pnpm turbo run lint typecheck test build --filter="...[origin/main]"`. CI must fetch enough git history for `origin/main` to resolve.
- Enable remote caching (`pnpm turbo login` / `pnpm turbo link`, or `TURBO_TOKEN` + `TURBO_TEAM` in CI) so CI and developers share results.
- Debug a task: `pnpm turbo run build --filter=<pkg> --dry=json` shows hashes and inputs; `--summarize` writes a run summary. Compare two summaries to find what changed.
- Force a rerun only to diagnose: `--force`. Do not commit workarounds that disable caching.

## Common cache-miss causes
- Undeclared or unstable env var (see above), or a CI-only var in `globalEnv`.
- `outputs` missing or too narrow, so the restored cache is incomplete.
- Generated files committed or written into the package during the task (they change inputs); write to declared outputs and gitignore them.
- Lockfile change: any dependency bump invalidates dependants; expected.
- Shallow git clone makes `--filter="...[origin/main]"` run everything or fail; fetch history.
- Task script does something outside its package (reads `../../`): declare it in `inputs`.

## Docker pruning
- `pnpm turbo prune <app> --docker` emits `out/json` (manifests + lockfile), `out/full` (sources) and a pruned lockfile.
- Dockerfile order: copy `out/json`, run `pnpm install --frozen-lockfile`, then copy `out/full` and build. This keeps the install layer cached until manifests change.
- Verify the prune output flags against the installed version.

## See also

Optional, if installed: monorepo-management (the platform-engineering plugin) for the broader discipline this skill applies. This skill stands on its own.
