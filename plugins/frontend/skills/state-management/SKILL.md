---
name: state-management
description: rules for deciding where state lives in Vue 3 and Nuxt 3 apps — local ref, composable or provide/inject, Pinia setup stores for global client state, TanStack Query for server state, URL state, VeeValidate form state, and persisted state — plus Pinia rules (storeToRefs, actions, one store per domain), SSR safety and hydration, reset on logout, derived state, avoiding watch-based syncing, and testing stores. Load when adding state, creating or changing a Pinia store, deciding between Pinia and TanStack Query, handling SSR state, or reviewing state flow.
---

# State management

Pick the narrowest home that works. Page-only ownership of stores and queries: `atomic-components-design`. Query keys, hydration and the Pinia/TanStack split: `nuxt-project-patterns`. Fetching and services: `api-client-patterns`. Forms: `form-handling`.

## Where state lives
| State | Home | Notes |
|---|---|---|
| One component | `ref` / `computed` in the component | Default. Do not promote early |
| Shared within a UI subtree | Composable, or `provide`/`inject` with a typed `InjectionKey` | Not for cross-page state |
| Global client state (session, preferences, cross-page UI) | Pinia setup store | Client-owned data only |
| Server data (lists, entities, anything fetched) | TanStack Query | Never copied into Pinia |
| Shareable/navigable state (filters, page, tab, sort) | Route `query` / `params` | Survives reload and links |
| Form values, errors, dirty/touched | VeeValidate | See `form-handling` |
| Persisted (theme, consent) | Cookie or `localStorage` | See Persisted state |

## Global state vs server data
- Pinia = client/UI state. TanStack Query = server data that is cached, refetched or mutated. Never copy query results into a store, or into a local `ref` via `watch`.
- No API calls inside stores to load data the query cache owns. A store may hold the id of the selected item; the query fetches the item.
- After a mutation, invalidate query keys; do not patch a store.

## Pinia rules
- Setup-style stores only, named `useXStore`, one per domain, in `stores/`.
- Change state through actions (functions returned from the store), not from components via `store.x = ...`.
- Read state in components with `storeToRefs`; destructure actions directly from the store.
- Derived values are `computed` (getters), never a second `ref` kept in sync.
- Return only what consumers need; keep helpers private.
```ts
export const useSessionStore = defineStore('session', () => {
  const user = ref<User | null>(null)
  const isSignedIn = computed(() => user.value !== null)

  function signIn(next: User) { user.value = next }
  function reset() { user.value = null }

  return { user, isSignedIn, signIn, reset }
})
```
```ts
const session = useSessionStore()
const { user, isSignedIn } = storeToRefs(session) // destructuring session directly loses reactivity
const { signIn } = session
```

## Shared UI state with provide/inject
```ts
// composables/accordion-context.ts
export const accordionKey: InjectionKey<{ open: Ref<string | null>; toggle: (id: string) => void }> = Symbol('accordion')
```
- Provide in the parent organism, inject in descendants. Guard against a missing provider (throw); never inject by string key.

## SSR safety (Nuxt)
- Never declare mutable state at module scope (`const count = ref(0)` outside a function): it is shared across all server requests and leaks between users. Use `useState('key', () => init)` or a Pinia store.
- `useState` keys must be unique and values serialisable (no class instances, functions, `Map`/`Set`).
- Pinia state set on the server is serialised into the payload and hydrated on the client; initialise it in a plugin, middleware or page setup, not at import time.
- Hydration: server and first client render must match. Do not branch on `window`, `localStorage` or `Date.now()` during setup; read them in `onMounted` or wrap with `<ClientOnly>`.

## Persisted state
- Prefer cookies (`useCookie`) for anything needed in the SSR render (theme, locale). `localStorage` is client-only and causes hydration mismatches if read during setup.
- Never persist tokens in `localStorage` (`frontend-security`). Never persist server data.
- Version persisted keys and tolerate missing or malformed values.

## Reset and lifecycle
- Every store holding user data exposes `reset()`. On logout, call it for each such store and clear the query cache (`queryClient.clear()`), then navigate.
- Do not rely on a page reload to clear state.

## Avoid watch-based syncing
- Do not `watch` one piece of state to write another. Use `computed`, or make the source the single owner.
- Allowed watchers: side effects (persist, analytics, imperative DOM). To reset local state when an id changes, prefer `:key` on the component.

## Testing stores
Wider testing rules: `frontend-testing`.
```ts
import { createPinia, setActivePinia } from 'pinia'

beforeEach(() => setActivePinia(createPinia()))

it('signs in', () => {
  const session = useSessionStore()
  session.signIn(user)
  expect(session.isSignedIn).toBe(true)
})
```
- Component tests: `createTestingPinia({ createSpy: vi.fn })` from `@pinia/testing`; actions are stubbed by default, pass `stubActions: false` to run them. Verify option names against the installed version.
- Test through the public store API, not internals.
