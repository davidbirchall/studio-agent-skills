---
name: frontend-code-quality
description: Tooling standards for Vue/Nuxt projects — ESLint, Prettier, TypeScript (strict), Husky + lint-staged, pnpm, with a shared config package such as @acme/config. Load when setting up or changing lint/format/typecheck config, git hooks, CI checks, or package management.
---

# Frontend code quality

## Shared configs
- ESLint, Prettier and TypeScript configs come from a shared config package (for example `@acme/config`). Projects **import and extend** them; do not define a standalone config.
- Follow the package's README for exact import paths and export names. Do not guess them.
- Local overrides only when needed, each with a comment explaining why.

## ESLint and Prettier
- Prettier owns formatting; ESLint owns correctness. Don't add ESLint formatting rules, and keep any ESLint/Prettier overlap disabled so they never conflict.
- Don't hand-format to fight Prettier; run it.
- Rule philosophy: lint for bugs and agreed conventions (unused vars, floating promises, Vue template errors, a11y), not taste. A rule nobody can explain in one sentence gets removed, not tuned.
- Prefer `error` or `off`. Warnings accumulate and are ignored; if it matters, fail the build.

## ESLint flat config shape
Use the flat config (`eslint.config.js` or `.ts`); extend the shared package and append local overrides last, because later entries win. Verify the shape against the installed ESLint major and the shared package README.
```js
import base from '@acme/config/eslint'

export default [
  ...base,
  { ignores: ['.nuxt/**', '.output/**', 'dist/**', 'coverage/**'] },
  {
    files: ['**/*.test.ts'],
    // why: tests legitimately use non-null assertions on fixtures
    rules: { '@typescript-eslint/no-non-null-assertion': 'off' },
  },
]
```
- Scope overrides with `files`; never loosen a rule globally for one file.
- Import ordering: enforce with one tool (an ESLint import-order rule or a Prettier plugin, not both). Group built-ins, packages, then relative imports; keep it autofixable.
- Type-aware rules (those needing `parserOptions.project` or project service) are slower and run whole-program. Enable them in CI and the editor, keep the pre-commit hook on fast rules if it becomes slow, and limit type-aware rules to `.ts`/`.vue` source with `files`.

## Disable comments and disagreements
- Prefer fixing the code. A disable needs the narrowest scope (`eslint-disable-next-line rule-name`) and a reason after `--`: `// eslint-disable-next-line vue/no-v-html -- sanitized CMS content, see frontend-security`.
- No file-wide or bare `eslint-disable`. Do not use `@ts-ignore`; use `@ts-expect-error` with a reason so it fails when stale.
- Enable `reportUnusedDisableDirectives` so dead disables are flagged.
- If a rule keeps being disabled, raise it in the shared config package (change or drop it there) instead of each repo overriding it.

## TypeScript
- `strict` on (inherited from the shared config).
- Typecheck with `pnpm vue-tsc --noEmit` (plain `tsc` doesn't check `.vue` files).
- No `any` without a comment justifying it. Prefer `unknown` and narrow.

## Git hooks
- Husky + lint-staged. Pre-commit runs ESLint and Prettier on **staged files only**.
- Typecheck runs in CI, not in the hook (too slow, whole-project).
- No commit-message linting yet; it may be explored later. Don't configure commitlint.

```json
{
  "lint-staged": {
    "*.{ts,vue,js}": ["eslint --fix", "prettier --write"],
    "*.{css,json,md}": "prettier --write"
  }
}
```

## pnpm
- pnpm is the only package manager. Use `pnpm` commands; never `npm` or `yarn`.
- Commit `pnpm-lock.yaml`. Pin the version via the `packageManager` field (Corepack).
- Run one-off tools with `pnpm dlx`, never `npx`.
- Add deps with `pnpm add` / `pnpm add -D`; run scripts with `pnpm <script>`.

## lint-staged scope
- Match only file types the tools handle; use the staged-files list, never a whole-repo glob.
- Keep the hook under a few seconds. If it is slow, the cause is usually type-aware rules or running the full test suite; move those to CI.
- Never bypass with `--no-verify` to land work; fix or ask.

## CI
- CI runs `pnpm vue-tsc --noEmit` (typecheck), ESLint, Prettier check and the test suites; test tooling is in `frontend-testing`.
- Order cheap and fast first so failures surface quickly: `pnpm install --frozen-lockfile`, Prettier check, ESLint, typecheck, unit tests, build, e2e.
- Use the same commands locally and in CI (package scripts such as `pnpm lint`, `pnpm typecheck`); no CI-only flags that change what is checked.
- In a monorepo, run them through `turborepo-workflow`.

## See also

Optional, if installed: code-review (the shared plugin); ci-cd-workflows (the platform-engineering plugin) for the broader discipline this skill applies. This skill stands on its own.
