---
name: component-library-publishing
description: Rules for publishing shared Vue 3 and TypeScript libraries (the shared component library, shared config package) covering semver, changelogs, pnpm publish workflow, exports map and types, peer dependencies, Storybook docs, deprecation policy, and a breaking-change checklist. Load when releasing, versioning, or changing the public API of a shared library.
---

# Component library publishing

Applies to the shared libraries (the shared component library, a shared config package such as `@acme/config`). Registry URL, scope and auth are project and infrastructure specific: read the repo's existing config (`.npmrc`, CI). Do not invent them.

## Semver
- **Major**: removed or renamed component, prop, emit, slot, CSS custom property, export, or utility; narrowed accepted types; changed default behaviour; raised a peer dependency range minimum; dropped a Node or browser target.
- **Minor**: new component, optional prop, slot, emit, token, or export.
- **Patch**: bug fix with no API or visible contract change.
- Visual changes users could depend on (spacing, tokens, DOM structure, class names) count as breaking when consumers style or test against them. When unsure, bump higher.
- Pre-releases (`-beta.0`, `-rc.0`) for risky changes, published under a non-`latest` dist-tag.

## Changelog
- Keep a `CHANGELOG.md` per published package. One entry per release, grouped: Breaking, Added, Changed, Fixed, Deprecated.
- Every breaking entry includes a migration note with before and after code.
- Commit message linting is not adopted, so do not assume Conventional Commits drive the changelog.

## pnpm workflow
- Install with `pnpm install --frozen-lockfile` in CI. Commit `pnpm-lock.yaml`.
- Verify before publishing: `pnpm build`, `pnpm typecheck`, `pnpm lint`, `pnpm test`, then `pnpm pack --dry-run` and inspect the file list.
- Publish with `pnpm publish` (use `--tag` for pre-releases). Do not use `npm publish`.
- Bump the version via changesets or a manual `package.json` edit, then tag the release and publish from CI where possible.
- A single-package repo is the default: no workspaces, changesets, or Turborepo. **Only if the library lives in a monorepo**: use pnpm workspaces, optionally changesets for versioning, and Turborepo for task orchestration (`turborepo-workflow`).
- Use the `files` field (or `.npmignore`) so only `dist` and docs ship; never source maps with secrets or `.env` files.

## Exports map and types
- Use `"type": "module"` and an explicit `exports` map; consumers cannot deep-import what is not listed.
- Ship ESM, plus CJS only if a consumer needs it. Put the `types` condition first in each entry.
- Components: ship generated declarations via `vue-tsc` (`--declaration --emitDeclarationOnly`), verified against the installed build tool.
- Ship styles as an explicit entry (`./style.css`) and document it. Declare `sideEffects` accurately (CSS files are side effects) so tree-shaking works.
- Export types explicitly (`export type`), props and emits interfaces included.
- Check the output by installing the packed tarball in a scratch consumer, not by trusting the build.
- For shared config packages, reference only export paths that exist in the package's `exports` map.

## Peer dependencies
- `vue` is a `peerDependency`, with a range matching supported 3.x versions, and a `devDependency` for local work. Never a `dependency`.
- Mark integrations consumers may not use (e.g. Pinia, router) as optional peers, or avoid importing them in the library.
- Externalise peers in the build config so they are not bundled.
- Keep runtime `dependencies` minimal; each one is a consumer cost (`frontend-performance`, `frontend-security`).

## Storybook as docs
Every public component has stories covering variants and states, with autodocs and prop descriptions (`storybook-workflow`). Stories are the usage documentation and the a11y check surface (`frontend-a11y-check`). Deploy the built Storybook where the team already hosts docs; do not assume a location.

## Deprecation policy
1. Mark with a JSDoc `@deprecated` tag naming the replacement and the removal version.
2. Add a dev-only console warning where practical.
3. Record under Deprecated in the changelog, with a migration note.
4. Keep deprecated APIs for at least one minor release, and remove them only in the next major. Confirm the exact window with the owner if a project needs another.

## Breaking-change checklist
- [ ] Bump is major; changelog has Breaking entry and migration note
- [ ] Deprecation path considered first and not feasible, or already served
- [ ] Props, emits, slots, tokens, exports, peer ranges reviewed against the previous release
- [ ] Types build clean and the exports map still resolves every documented path
- [ ] Stories and tests updated; a11y behaviour unchanged or improved
- [ ] Packed tarball tested in a consumer app
- [ ] Your apps that use the library upgraded and checked

## See also

Optional, if installed: release-management (the platform-engineering plugin); dependency-management (the shared plugin) for the broader discipline this skill applies. This skill stands on its own.
