---
name: playwright-e2e
description: Playwright end-to-end testing for Nuxt 3 apps - scoping e2e to critical user journeys, role/label/test-id locators, auto-waiting instead of sleeps, fixtures and storageState auth reuse, API seeding, parallel isolation with per-test data, network mocking versus real backend, controlled streamed responses, visual snapshot policy, traces and screenshots on failure, flake triage and quarantine, CI with pnpm, axe accessibility checks, and headless runs against a built app. Load when adding or fixing Playwright tests, setting up e2e CI, debugging flaky tests, or deciding what to cover end to end.
---

# Playwright e2e

Builds on `frontend-testing`, `frontend-a11y-check`, and `nuxt-project-patterns`. Verify option names against the installed `@playwright/test`.

## Scope
- E2E covers critical user journeys only: sign in, the core create/read/update flow, checkout or equivalent, one streaming flow. Target about 5-15 tests.
- Push logic, edge cases, and validation rules down to unit and component tests (`frontend-testing`). Each e2e test should justify its cost (seconds, flake risk).
- One journey per test; do not chain tests that depend on each other.

## Locators
- Prefer `getByRole` with name, then `getByLabel`, `getByText` for static copy, then `getByTestId` as the explicit fallback.
- Never use CSS or XPath tied to layout or classes. Configure `testIdAttribute` (for example `data-testid`) once.
```ts
await page.getByRole('button', { name: 'Save' }).click();
await expect(page.getByRole('status')).toHaveText('Saved');
```

## Waiting
- Rely on auto-waiting and web-first assertions (`expect(locator).toBeVisible()`). They retry until timeout.
- Never `waitForTimeout` or fixed sleeps. Wait on a user-visible condition, a URL (`expect(page).toHaveURL`), or a specific response (`page.waitForResponse`) registered before the action.
- Nuxt hydration: wait for an element that only works after hydration (or a ready marker) before interacting, to avoid clicks lost before handlers attach.

## Fixtures and auth
- Extend `test` with fixtures for page objects, seeded users, and API clients; keep them small.
- Log in once in a `setup` project, save `storageState` to a gitignored file, and reuse it in dependent projects. Create separate states per role.
```ts
projects: [
  { name: 'setup', testMatch: /auth\.setup\.ts/ },
  { name: 'chromium', use: { storageState: '.auth/user.json' }, dependencies: ['setup'] },
]
```
- Test the login UI itself in a dedicated test with a clean context.

## Data and isolation
- Seed through the backend API or a test-only seed endpoint, not through the UI. Create unique data per test (random suffix) and clean up in fixture teardown.
- Tests must run in parallel and in any order. Never share mutable records. Use `fullyParallel: true`; use workers equal to about half the CPU cores in CI.

## Network
- Default to the real backend against a seeded test database for journeys; this catches contract drift.
- Use `page.route` to mock third parties, force error states (500, timeout), or slow responses. Do not mock your own API in the main journeys.
- Streamed UI (`streaming-client`, `chat-ui-patterns`): fulfil the route with a controlled body, or serve chunks from a test server with deterministic delays; assert partial then final states, and a mid-stream failure and cancel.

## Visual and accessibility
- Visual snapshots: sparingly, for a few stable components or pages; one browser and OS (the CI image); mask dynamic regions; set `maxDiffPixelRatio` low; review diffs, never bulk update.
- Run axe via `@axe-core/playwright` on key pages and states (dialogs open, errors shown); fail on serious and critical violations. Automated checks complement manual review.

## Diagnostics
- `trace: 'on-first-retry'`, `screenshot: 'only-on-failure'`, `video: 'retain-on-failure'`. Upload the report and traces as CI artifacts.
- Debug locally with `pnpm exec playwright test --ui` or `--debug`; read the trace viewer before guessing.

## Flakes
- Retries only in CI (`retries: process.env.CI ? 2 : 0`); locally, flakes must fail loudly.
- A test that needs a retry is flaky: file an issue. Quarantine with `test.fixme` or a tag plus a dated comment and owner; fix or delete within 2 weeks.
- Typical causes: unawaited actions, shared data, animation (disable via `reducedMotion: 'reduce'`), hydration races, time or random dependence (control the clock with `page.clock`).

## CI and build
- Test against a production build (`pnpm build` then preview/start), not the dev server, using `webServer` with `reuseExistingServer: !process.env.CI`.
- Run headless; cache the pnpm store and Playwright browsers; install with `pnpm exec playwright install --with-deps chromium`. Start with chromium only; add other browsers when needed.
- Set explicit `timeout` (30 s per test) and `expect.timeout` (5 s); `forbidOnly` in CI.

## Anti-patterns
- Sleeps; layout-based selectors; UI-driven seeding; tests sharing accounts; snapshot-everything; mocking your own API everywhere; retries hiding flakes locally.

## Checklist
- [ ] Only critical journeys, about 5-15 tests
- [ ] Role/label/test-id locators; no sleeps
- [ ] storageState auth; API seeding; per-test data
- [ ] Traces and screenshots on failure; artifacts uploaded
- [ ] Retries CI-only; quarantines have owner and deadline
- [ ] Runs headless against a build with pnpm in CI
- [ ] axe checks on key pages
