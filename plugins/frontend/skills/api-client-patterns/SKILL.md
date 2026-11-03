---
name: api-client-patterns
description: Patterns for the API layer in Nuxt 3 and Vue 3 apps, with axios as the default HTTP client (shared per-request instance, interceptors, typed service modules, AbortSignal), error normalisation, TanStack Query key and query/mutation organisation, where API code lives, auth headers, retries, and the Pinia boundary. Load when adding or changing API calls, query composables, error handling, or auth on requests.
---

# API client patterns

Builds on `nuxt-project-patterns` (data-fetching split, key factories, SSR hydration) and `frontend-security` (token storage, cookies). Do not repeat those rules here; follow them.

## Where API code lives
- `plugins/api.ts`: creates the axios instance per request and provides it (`$api`). See Typed client.
- `services/`: plain typed functions, one file per domain (`services/posts.ts`). They take the axios instance as an argument, wrap it, and return typed data (not `AxiosResponse`). No Vue state, no `useQuery`.
- `composables/`: TanStack Query wrappers (`usePosts`, `useUpdatePost`) that call services and own keys. Key factories sit beside them (`composables/posts/keys.ts`). Nuxt only auto-imports top-level files and `index.ts` files one level down in `composables/`, so import nested files explicitly (`import { postKeys } from '~/composables/posts/keys'`) or re-export them from `composables/posts/index.ts`.
- `server/api/`: Nuxt server routes (`nuxt-project-patterns`).
- Pages own data: they call these composables and pass results down (`atomic-components-design`). Atoms and molecules stay presentational. Organisms may use UI-local composables only (open state, focus, form state), not data-fetching composables. No component calls axios or services directly.

## Axios is the default
Axios is the default HTTP client for all service calls. Install with `pnpm add axios` and verify option names against the installed axios version. Fetch-based clients are a flagged fallback only (see Fetch-based clients: fallback only).

## Typed client
One axios instance per request, created in a Nuxt plugin from runtime config. Type responses at the service function with generics (`api.get<T>()`), not at the call site.
```ts
// plugins/api.ts
import axios from 'axios'

export default defineNuxtPlugin(() => {
  const config = useRuntimeConfig()
  const headers = import.meta.server ? useRequestHeaders(['cookie']) : {}

  const api = axios.create({
    baseURL: config.public.apiBase,
    timeout: 10_000,
    headers,
    withCredentials: true, // cookie auth only; drop for bearer-token projects
  })

  api.interceptors.request.use((request) => {
    const token = getAuthToken() // project's chosen source (frontend-security)
    if (token) request.headers.Authorization = `Bearer ${token}`
    return request
  })
  api.interceptors.response.use(
    (response) => response,
    (error) => Promise.reject(axios.isCancel(error) ? error : normaliseError(error)),
  )

  return { provide: { api } }
})

// services/posts.ts
import type { AxiosInstance } from 'axios'

export const getPost = async (api: AxiosInstance, id: number, signal?: AbortSignal) => {
  const { data } = await api.get<Post>(`/posts/${id}`, { signal })
  return data
}
```
```ts
// composables/posts/usePost.ts
export const usePost = (id: MaybeRefOrGetter<number>) => {
  const { $api } = useNuxtApp() // call in setup scope
  return useQuery({
    queryKey: computed(() => postKeys.detail(toValue(id))),
    queryFn: ({ signal }) => getPost($api, toValue(id), signal),
  })
}
```
- Set `baseURL` from `useRuntimeConfig()` only. Never hardcode URLs.
- Cancellation: TanStack Query passes `signal` to `queryFn`; forward it to axios (`{ signal }`). Do not use axios `CancelToken` (deprecated).
- Forward cookies explicitly on the server (`useRequestHeaders(['cookie'])`); axios does not inherit the incoming request's cookies. Forward only what the API needs; do not forward all headers.
- Validate untrusted or third-party responses with the project's schema library (Zod preferred for new code, `form-handling`). Trusted first-party types may be asserted.
- Types are compile-time only; `api.get<T>()` does not check the payload.

## Nuxt SSR rules
- Never create the instance at module level and attach per-user auth to it: module state is shared across concurrent SSR requests and leaks one user's token or cookies to another. Create it per request in the plugin (above) or in a composable that reads `useNuxtApp()`.
- A module-level instance is acceptable only for unauthenticated, user-independent calls with no interceptors reading request state.
- Forward cookies/headers on the server explicitly (above). Without that, authenticated calls fail during SSR.
- Interceptors that read request-scoped state (token, cookies) must read it from the per-request context, not from module variables.

## Fetch-based clients: fallback only
Axios is the only standard client. `$fetch`, `ofetch`, `useFetch`, and native `fetch` are not used for service calls. Use one only when axios is not available in that context (for example a runtime or Nuxt server context that cannot run it), and then:
- Record the reason in a code comment or the decision log.
- Wrap it behind the same service-module interface (same function signature, typed return data, errors normalised to `ApiError`) so callers do not change.
- Keep the same rules: no stacked retries, no per-user auth on shared instances, cookies/headers forwarded explicitly on the server.
- Nitro `server/api` code: upstream API calls from server routes use axios. `event.$fetch` is permitted only as the mechanism for calling internal Nitro routes; the flagged exception above is for client-side service calls and is not a general `$fetch` endorsement.

## Error normalisation
Convert every failure to one shape at the client boundary so UI code never inspects raw axios errors.
```ts
// types/api.ts (import as `~/types/api`)
export interface ApiError {
  status: number
  code: string
  message: string
  fieldErrors?: Record<string, string[]>
}

// sketch: map the real backend body before relying on code/fieldErrors
export const normaliseError = (e: unknown): ApiError => {
  if (axios.isAxiosError(e)) {
    return {
      status: e.response?.status ?? 0,
      code: e.code ?? 'UNKNOWN',
      message: e.message,
      fieldErrors: e.response?.data?.fieldErrors,
    }
  }
  return { status: 0, code: 'UNKNOWN', message: e instanceof Error ? e.message : 'Unknown error' }
}
```
- `normaliseError` (called from the axios response interceptor) maps `AxiosError` HTTP status, network failure (`ERR_NETWORK`) and timeout (`ECONNABORTED`/`ETIMEDOUT`) to `ApiError`. Cancellations (`axios.isCancel`) are passed through unchanged, not normalised or swallowed; callers and TanStack Query recognise and ignore them. Backend error body formats vary, so check the actual API before mapping `code` and `fieldErrors`.
- Messages shown to users come from the UI layer, not from raw server text. Never log tokens or request bodies with PII.
- Register the type with TanStack Query (`Register { defaultError: ApiError }`, verify against the installed version) so `error` is typed.
- Field errors feed forms through the mutation's `onError` (`form-handling`).

## TanStack Query organisation
- Keys: one factory per domain, hierarchical, `as const` (see `nuxt-project-patterns`). Include every input that changes the result.
- One composable per query or mutation. Query composables return the `useQuery` result untouched; do not copy `data` into refs or Pinia.
- Mutations invalidate through the key factory in `onSuccess`. Optimistic updates need rollback in `onError`.
- Set defaults once in the QueryClient plugin (`staleTime`, `retry`); override per query only with a reason.
- Mutations do not retry by default; keep it that way unless the endpoint is idempotent.

## Retries
- Retry only network errors, timeouts, 429, and 5xx. Never retry 4xx (except 429), and never retry 401 blindly.
- TanStack Query owns retries: use `retry` as a function of the normalised error with exponential backoff (`retryDelay`). Axios does not retry by default; keep it that way and do not stack retry layers. Add `axios-retry` only with owner approval.
- Honour `Retry-After` on 429 when present.

## Auth headers
Token storage varies per project (`frontend-security`); check the project's recorded decision first.
- Cookie auth: set `withCredentials: true` for cross-origin calls and forward cookies on SSR. Add a CSRF header on state-changing requests if the project requires it.
- Bearer token auth: attach the token in the axios request interceptor, read from the project's chosen source. Never hardcode or put it in `runtimeConfig.public`.
- On 401: refresh once, replay once, then clear session state and redirect. Do the refresh in the response interceptor and single-flight it so parallel requests share it.
- Do not add auth headers to third-party origins.

## Pinia boundary
Pinia holds global client state only (session, preferences, UI flags). Server data stays in TanStack Query or `useAsyncData` (calling a service function). A store may hold the signed-in user, but not cached lists, entities, or loading flags that a query already exposes.

## Testing
Mock at the network layer (MSW, if the project uses it) or mock the service module or the axios instance; test `normaliseError` and retry predicates as pure functions (`frontend-testing`).
