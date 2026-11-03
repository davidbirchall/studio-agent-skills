# squad-skills-frontend

Frontend skills for Vue 3 / Nuxt 3 / TypeScript: architecture, state management, atomic design, design systems, CSS, accessibility, testing, Storybook, tooling (ESLint/Prettier/TypeScript), Turborepo, TanStack Query, forms, performance, security, build tooling, internationalization, API client patterns, component library publishing, and animation and motion.

Version `0.8.0`, 23 skills.

## Install

```
copilot plugin install ./plugins/frontend
```

## Skills

| Skill | Purpose | Load when |
|-------|---------|-----------|
| `animation-motion` | Motion in Vue 3/Nuxt 3 UIs, in tier order: CSS first, then Vue `Transition`/`TransitionGroup`, then VueUse; `prefers-reduced-motion`, duration/easing tokens, transform/opacity performance, Nuxt page transitions | Adding hover, enter/leave, list, loading, or page animations |
| `api-client-patterns` | axios-first API layer: shared per-request instance, interceptors, typed service modules, AbortSignal, error normalisation, TanStack Query keys and query/mutation organisation, auth headers, retries, Pinia boundary | Adding or changing API calls, query composables, error handling, or auth on requests |
| `atomic-components-design` | Structure Vue components by atomic design (atoms, molecules, organisms, pages) and where data and state may live | Deciding where a component belongs, splitting or composing components, reviewing boundaries |
| `chat-ui-patterns` | Opinionated UI patterns for high-quality chat interfaces in Vue 3 and Nuxt 3 - message parts instead of strings, frame-batched streaming render,... | Building or reviewing chat message lists, composers, streaming rendering, or conversation controls |
| `component-library-publishing` | Publishing shared Vue 3/TypeScript libraries: semver, changelogs, pnpm publish workflow, exports map and types, peer dependencies, Storybook docs, deprecation policy, breaking-change checklist | Releasing, versioning, or changing the public API of a shared library |
| `css-styling-standards` | Native CSS in scoped styles, BEM, global design tokens, modern CSS, `:deep()` as last resort | Writing or reviewing component styles or design tokens |
| `design-to-code` | Turning designs (for example Figma frames) into Vue 3 and Nuxt components - inspecting design context and tokens first, mapping tokens to the... | Implementing a screen or component from a design, translating design tokens, reviewing fidelity, or mapping design components to code |
| `form-handling` | VeeValidate with schema validation (Yup in existing code, Zod for new), accessible errors, atom/organism split, TanStack Query mutations, server error mapping | Building, migrating, reviewing, or testing forms |
| `frontend-a11y-check` | Accessibility checklist, WCAG 2.2 AA minimum (AAA where possible) | Building or reviewing UI, forms, interactive components, colours, or motion |
| `frontend-architecture` | Folder layout, module boundaries and dependency direction, naming, auto-imports, barrel policy, Vue 3 component-writing rules (script setup, props/emits/model) | Creating or reviewing any `.vue` file or composable, or deciding where code lives |
| `frontend-build-tooling` | Nuxt/Vite config, env variables, build modes, bundle analysis, caching, Node and pnpm pinning, upgrades, script naming | Configuring or debugging builds, upgrading Nuxt/Vue, or setting up CI builds |
| `frontend-code-quality` | ESLint, Prettier, TypeScript (strict), Husky + lint-staged, pnpm, shared config package | Setting up or changing lint/format/typecheck config, git hooks, CI checks, or package management |
| `frontend-design-systems` | Design tokens (primitive, semantic, component), theming, component API consistency, governance, deprecation and adoption | Adding or changing tokens, theming, or shared components in a design system |
| `frontend-internationalization` | `@nuxtjs/i18n` setup, locale file structure, pluralisation, locale routing and SEO, Intl formatting, RTL, testing and translation workflow | Adding or changing translations, locales, or locale-aware formatting |
| `frontend-performance` | Core Web Vitals targets, per-route rendering, images, lazy loading, fonts, bundle budgets, reactivity cost, third-party scripts, INP | Building pages, adding images/fonts/scripts/dependencies, or debugging slow UI |
| `frontend-security` | Auth token storage, XSS (`v-html`, dynamic URLs), CSP and security headers, env/secrets, dependency hygiene, server-route input validation | Handling auth/tokens, rendering user content, configuring headers or env, adding dependencies, writing server routes |
| `frontend-testing` | Vitest with Vue Testing Library for unit/component tests; Playwright with axe for e2e | Writing, reviewing, or planning frontend tests |
| `nuxt-project-patterns` | Nuxt 3 data fetching, server routes with Zod, runtimeConfig, SEO, routeRules, Pinia | Building pages, `server/api` routes, or configuring a Nuxt 3 app |
| `playwright-e2e` | Playwright end-to-end testing for Nuxt 3 apps - scoping e2e to critical user journeys, role/label/test-id locators, auto-waiting instead of sleeps,... | Adding or fixing Playwright tests, setting up e2e CI, debugging flaky tests, or deciding what to cover end to end |
| `state-management` | Where state lives (local, composable, Pinia, TanStack Query, URL, form, persisted), SSR-safe stores, reset on logout, testing stores | Adding shared state, a Pinia store, or deciding between client and server state |
| `storybook-workflow` | CSF3 TypeScript stories for every atom/molecule/organism, required states, play-function interaction tests, axe a11y addon | Creating or reviewing a component, writing a story, or setting up Storybook |
| `streaming-client` | Rules for consuming server-sent token streams in the browser with Vue 3 and Nuxt 3 - fetch plus ReadableStream versus EventSource, robust SSE frame... | Implementing or debugging a streaming chat client, SSE parsing, stop or resume behaviour, or stream error handling |
| `turborepo-workflow` | Monorepo-only Turborepo task pipeline, caching, PR filtering, shared config package, pnpm workspaces | Only when the repo is already a monorepo; never for single-package projects |

## Conventions

pnpm is the package manager, axios is the default HTTP client, and lint, format and TypeScript configs come from a shared config package that projects extend. `frontend-architecture` and `frontend-design-systems` refer to `typescript-conventions` from the shared plugin, so install shared alongside this plugin.

## Related plugins

Works well with: shared (typescript-conventions, architecture, testing, security), platform-engineering (build, CI, monorepo), backend. Skills may mention skills from other plugins in a short "See also" note; each skill stands on its own if those plugins are not installed.
