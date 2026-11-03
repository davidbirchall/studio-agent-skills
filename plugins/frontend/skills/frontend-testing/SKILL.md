---
name: frontend-testing
description: testing standards for Vue/Nuxt frontends - layering of Vitest, Vue Testing Library and Vue Test Utils for unit and component tests with Playwright and axe for e2e, component versus e2e split, testing composables, mocking fetch and streams, MSW usage, Nuxt test utilities, coverage policy, flaky-test rules, and what not to test. Load when writing, reviewing, or planning frontend tests.
---

# Frontend testing

## Tools
- Unit/component: Vitest + `@testing-library/vue` + `@testing-library/user-event`.
- E2E: Playwright + `@axe-core/playwright`, with axe checks run in CI.
- Vitest globals are not enabled; import `describe`, `it`, `expect`, `vi` explicitly from `'vitest'`.
- Because globals are off, `@testing-library/vue` does not auto-register its `afterEach` cleanup. Add a setup file and list it in `setupFiles`:
```ts
// vitest.setup.ts (vitest.config: test: { setupFiles: ['./vitest.setup.ts'] })
import { afterEach } from 'vitest'
import { cleanup } from '@testing-library/vue'

afterEach(cleanup)
```

## Rules
- Test behavior, not implementation: query by role/label/text; never assert on internal state, refs, or class names.
- Atoms: light tests - props render, callbacks fire.
- Molecules/organisms: interaction tests (click, type, assert visible outcome).
- Playwright covers key user flows only, each with an axe scan.

## Layers and split
| Layer | Tool | Scope | Rough share |
|---|---|---|---|
| Unit | Vitest | Pure functions, composables, stores, schemas | about 60% |
| Component | Vitest + Testing Library (Vue Test Utils underneath) | One component or small tree, user-visible behavior | about 30% |
| E2E | Playwright | Critical journeys against a running app | about 10% |
- Reach for `@vue/test-utils` directly only for what Testing Library cannot express: `emitted()` assertions on events, `global.plugins`/`provide` setup, `shallowMount`, or `setProps`. Prefer user-facing queries otherwise.
- Component test when the behavior depends on one component and its props. E2E when it spans routing, real network, auth, or multiple pages. Do not repeat a component test's cases in e2e.
- Keep e2e to about 5-15 journeys (sign in, checkout, core create flow). Each must be worth a CI minute.
- Name files `X.test.ts` beside the source; Playwright specs live in `e2e/*.spec.ts`.

## Composables and stores
- Call composables directly when they use only reactivity (`const { count, inc } = useCounter(); inc(); expect(count.value).toBe(1)`). If they need lifecycle hooks, `inject`, or the router, mount a tiny host component with `render` and assert on its output.
- Pinia stores: `setActivePinia(createPinia())` in `beforeEach`; see `state-management`.

## Mocking network
- Prefer MSW (`msw/node`, `setupServer`) over mocking `fetch` per test: handlers are shared, typed, and exercise the real client code in `api-client-patterns`.
```ts
import { setupServer } from 'msw/node'
import { http, HttpResponse } from 'msw'

export const server = setupServer(
  http.get('/api/items', () => HttpResponse.json([{ id: 1 }])),
)
// vitest.setup.ts: beforeAll(() => server.listen({ onUnhandledRequest: 'error' }))
// afterEach(() => server.resetHandlers()); afterAll(() => server.close())
```
- Override per test with `server.use(...)` for error and empty cases (500, 401, network error, slow response).
- For streams (SSE, chunked responses) return a `ReadableStream` from the handler and assert on each chunk's rendered result. Use `vi.useFakeTimers()` only when time is the subject; otherwise await UI with `findBy*`.
- In Playwright use `page.route` for third-party or hard-to-trigger failures only; keep first-party calls real against a seeded backend.

## Coverage policy
- Gate on about 80% lines for `composables/`, `utils/`, `stores/`; no global gate for components, which are judged by behavior cases. Never chase 100%.
- Use `@vitest/coverage-v8`; exclude stories, types, generated files, and config.
- A bug fix lands with a test that failed before it.

## What not to test
- Framework or library behavior (that `ref` is reactive, that Pinia stores state).
- Private functions, class names, snapshot of whole DOM trees, and exact CSS.
- Third-party components' internals; test your use of them.
- Anything already covered by a type check or schema.

## Flakiness rules
- No fixed `waitForTimeout`; use `findBy*`, `expect.poll`, and Playwright auto-waiting locators (`getByRole`).
- Each test owns its data and does not rely on order. Reset MSW handlers and Pinia between tests.
- Quarantine a flaky test within a day with a ticket; do not retry-mask it. See also `test-discipline`.

## Examples
```ts
import { it, expect, vi } from 'vitest'
import { render, screen } from '@testing-library/vue'
import userEvent from '@testing-library/user-event'
import BaseButton from './BaseButton.vue'

it('calls onClick when pressed', async () => {
  const onClick = vi.fn()
  render(BaseButton, { props: { onClick }, slots: { default: 'Save' } })
  await userEvent.click(screen.getByRole('button', { name: 'Save' }))
  expect(onClick).toHaveBeenCalledTimes(1)
})
```
```ts
import { test, expect } from '@playwright/test'
import AxeBuilder from '@axe-core/playwright'

test('checkout has no a11y violations', async ({ page }) => {
  await page.goto('/checkout')
  const results = await new AxeBuilder({ page }).withTags(['wcag2a', 'wcag2aa', 'wcag22aa']).analyze()
  expect(results.violations).toEqual([])
})
```

Stories with `play` functions complement Vitest/Testing Library unit tests and Playwright e2e; they don't replace them. See `storybook-workflow`. Lint/typecheck setup: see `frontend-code-quality`.

Form testing specifics (error summary, `aria-invalid`, focus): see `form-handling`.

## See also

Optional, if installed: software-testing-strategy (the shared plugin) for the broader discipline this skill applies. This skill stands on its own.
