---
name: frontend-build-tooling
description: build standards for Vue 3 and Nuxt 3 (Vite-based) projects — nuxt.config.ts structure, shared Vite/Vitest config and aliases, environment variables and prefixes, build modes and Nitro presets, source maps, caching, dependency upgrades with pnpm, Node pinning via Corepack, reproducible CI builds, build failure triage, browserslist, script naming. Load when configuring or debugging builds, env vars, upgrades, CI install/build steps, or package scripts.
---

# Frontend build tooling

Lint/format/TypeScript config and pnpm basics: `frontend-code-quality`. Monorepo task pipeline: `turborepo-workflow`. Do not repeat them here.

## Nuxt config (`nuxt.config.ts`)
- Keep it declarative and ordered: `modules`, `runtimeConfig`, `routeRules`, `css`, `app`, `vite`, `nitro`. No logic beyond reading `process.env` for build-time switches.
- Add features through Nuxt modules in `modules`; do not hand-wire a Vite plugin when a maintained module exists.
- Rendering rules per route (`routeRules`): `nuxt-project-patterns`.
- Customise Vite only under `vite:` (e.g. `vite.plugins`, `vite.resolve`); do not add a separate `vite.config.ts` to a Nuxt app.
- Aliases: Nuxt generates `~`, `@` and others into `.nuxt/tsconfig.json`. Extend that tsconfig; never declare an alias in only one of tsconfig or the bundler. Run `pnpm nuxi prepare` (or `pnpm dlx nuxi prepare`; verify the command name for the installed Nuxt version) after a fresh install so types resolve.

## Vite config (libraries, Vitest)
- Library packages use a `vite.config.ts` in library mode; publishing rules: `component-library-publishing`. Externalise peer deps (`vue`).
- Vitest reuses the app's Vite config through `mergeConfig` or `defineVitestConfig` (from `@nuxt/test-utils/config`) so plugins and aliases match production. Test rules: `frontend-testing`.
- If a shared Vite config exists in a shared config package (e.g. `@acme/config`), extend it; follow its README for export names. Do not guess them.
- Keep aliases identical to tsconfig `paths`. A mismatch typechecks but fails at build, or the reverse.

## Environment variables
- Read env only through `runtimeConfig`, never `process.env` in app code.
- `runtimeConfig` top-level keys are server-only; `runtimeConfig.public` is shipped to the browser. Override at runtime with `NUXT_` / `NUXT_PUBLIC_` variables whose names mirror the key path (`NUXT_PUBLIC_API_BASE` for `public.apiBase`). Declare every key with a default in `nuxt.config.ts`, or the env override is ignored.
- In plain Vite apps only `VITE_`-prefixed variables reach client code via `import.meta.env`. Treat every one as public.
- Never put secrets in `public`, `VITE_*` or `NUXT_PUBLIC_*`. Rules: `frontend-security`.
- Build-time values are inlined into the bundle; runtime config can change per deploy without a rebuild. Prefer runtime config for anything that differs per environment, so one artifact is promoted through environments.
- Commit a `.env.example` with names only. Never commit `.env`.

## Build modes and output
- SSR: `pnpm build` (`nuxt build`), run `.output/server/index.mjs` with Node.
- Static: `pnpm generate` (`nuxt generate`) when every route is prerenderable; output in `.output/public`.
- Hybrid per route: `routeRules` (`nuxt-project-patterns`).
- Hosting target is set by the Nitro preset (`nitro.preset` or `NITRO_PRESET`). Presets and their feature support (ISR, edge) vary by host and version; verify against the Nitro docs for the installed version and the deploy target.
- `pnpm preview` serves the built output locally; verify production behaviour there, not only in `pnpm dev`.

## Analysis and budgets
- Analyse a build with `pnpm nuxi analyze` (verify per version) or a Vite visualizer plugin run on demand, not in default builds.
- Budgets, lazy loading and dependency cost: `frontend-performance`. Fail CI on budget breach only where a budget is defined there.

## Source maps
- Generate source maps in CI builds and upload them to the error-tracking tool if one is used.
- Do not serve them publicly in production unless the user has decided to; never ship `.map` files in published libraries unless intended (`component-library-publishing`).
- Option names for Nuxt (`sourcemap`) differ between client and server; verify against the installed version.

## Caching
- Turbo `outputs`/`inputs` and remote cache: `turborepo-workflow`. Declare env vars that change output (`env`/`globalEnv`) so cache hits stay correct.
- CI: cache the pnpm store (path from `pnpm store path`), keyed on `pnpm-lock.yaml`. Do not cache `node_modules` unless the install mode is verified.
- Do not cache `.nuxt` or `.output` across unrelated commits except through Turbo.

## Dependency upgrades
- Upgrade in a dedicated PR, one major at a time (Nuxt, Vue, Vite, Vitest separately). Read the release notes first; Nuxt upgrades usually bump Vue, Nitro and Vite transitively.
- Interactive: `pnpm update --interactive` (verify against the installed version). Check why a version resolves with `pnpm why <pkg>`.
- Fix peer dependency warnings by aligning versions, not by silencing them. Use `resolutions` in the root `package.json` only to force a patched transitive dep; add a comment-bearing note in the PR and remove it once upstream fixes it.
- Lockfile hygiene: commit `pnpm-lock.yaml`; never hand-edit it; one lockfile per repo; review lockfile diffs for unexpected packages. Dependency security: `frontend-security`.
- After upgrading: `pnpm install`, typecheck, lint, test, build, and `pnpm preview` smoke test.

## Node and package manager pinning
- Pin Node in `.nvmrc` (LTS) and `engines.node` in `package.json`; CI reads `.nvmrc`.
- Pin pnpm with the `packageManager` field and run `corepack enable`. Never install pnpm globally in CI.

## Reproducible CI builds
- Install with `pnpm install --frozen-lockfile` so a drifting lockfile fails the build.
- Same Node version as `.nvmrc`; same commands as local scripts.
- Build once per commit and promote the artifact; do not rebuild per environment.

## Failure triage
1. Reproduce locally with the CI Node version and `pnpm install --frozen-lockfile`.
2. Clear generated state: delete `.nuxt`, `.output`, `node_modules/.vite`, then `pnpm nuxi prepare` and rebuild.
3. Typecheck errors: `pnpm vue-tsc --noEmit`. Out-of-memory: raise `NODE_OPTIONS=--max-old-space-size`.
4. Works in dev, fails in build: look for browser-only code on the server (`import.meta.client`), alias mismatches, and missing env defaults.
5. Bisect recent dependency or lockfile changes before changing config.

## Browser targets and polyfills
- Declare `browserslist` once (shared config or `package.json`) and let the toolchain transpile to it. Do not add polyfills for features the targets already support.
- Add a polyfill only for a documented target gap, loaded conditionally. Nuxt/Vite `build.target` defaults depend on version; verify before overriding.

## Script names
Use the same names everywhere (they also match Turbo task keys):
```json
{
  "scripts": {
    "dev": "nuxt dev",
    "build": "nuxt build",
    "preview": "nuxt preview",
    "typecheck": "vue-tsc --noEmit",
    "lint": "eslint .",
    "test": "vitest run"
  }
}
```
- Add `generate` only for static targets. Do not rename or alias these per project.

## See also

Optional, if installed: build-systems (the platform-engineering plugin); dependency-management (the shared plugin) for the broader discipline this skill applies. This skill stands on its own.
