---
name: nuxt-project-patterns
description: patterns for Nuxt 3 projects — data fetching (useAsyncData vs TanStack Query with axios services), server routes with Zod, runtimeConfig, SEO, routeRules, Pinia. Load when building pages, server/api routes, or configuring a Nuxt 3 app.
---

# Nuxt project patterns

Target **Nuxt 3**. Do not use Nuxt-4-only patterns; Nuxt 4 will be evaluated later. Note the Nuxt roadmap lists Nuxt 3 maintenance (bug fixes, security patches) as ending in July 2026 and Nuxt 4 as the current release, so confirm support status and plan the migration. Avoid, for example:
- The `app/` source directory layout (Nuxt 3 uses root-level `pages/`, `components/`, etc.).
- Relying on `data`/`error` from `useAsyncData` defaulting to `undefined` or shallow reactivity (Nuxt 3: `null` and deep `ref`).

## Data fetching
- Axios is the only standard client for service calls (`api-client-patterns`). Fetch-based clients (`$fetch`, `useFetch`, native `fetch`) are a flagged fallback only. No raw axios calls in components for render data; go through service functions.
- In Nitro `server/api` code, upstream API calls use axios. `event.$fetch` is allowed only for calling internal Nitro routes, not as a general client (`api-client-patterns`).
- Which to use:
  - SSR initial page data: `useAsyncData` with an **explicit key**, calling a service function (hydrates without double fetching).
  - Client-driven, repeated, or mutating data (search, pagination, forms, optimistic updates): TanStack Query.
- Pinia vs TanStack split: see the TanStack Query section.

```ts
const route = useRoute()
const { $api } = useNuxtApp()
const { data: post } = await useAsyncData(`post-${route.params.id}`, () =>
  getPost($api, Number(route.params.id)),
)
```

## TanStack Query (`@tanstack/vue-query`)
Pinia vs TanStack split (single source of truth): **Pinia = client/UI state** (session, preferences, cross-page UI). **TanStack Query = server data** that is cached, refetched, or mutated. Never copy query results into Pinia.

Form submission with mutations (page owns the mutation, organism owns the form): see `form-handling`.

- **Key factories**: one per domain, hierarchical, `as const`.
```ts
export const postKeys = {
  all: ['posts'] as const,
  lists: () => [...postKeys.all, 'list'] as const,
  list: (filters: PostFilters) => [...postKeys.lists(), filters] as const,
  detail: (id: number) => [...postKeys.all, 'detail', id] as const,
}
```
- **Wrap in composables** (`usePosts`, `useUpdatePost`); components/pages never call `useQuery`/`useMutation` with inline keys. Pass reactive inputs (refs/getters) into the key so it refetches on change. Call them in pages only (see `atomic-components-design`).
```ts
export const usePost = (id: MaybeRefOrGetter<number>) => {
  const { $api } = useNuxtApp() // per-request axios instance (api-client-patterns)
  return useQuery({
    queryKey: computed(() => postKeys.detail(toValue(id))),
    queryFn: ({ signal }) => getPost($api, toValue(id), signal),
  })
}

export const useUpdatePost = () => {
  const queryClient = useQueryClient()
  const { $api } = useNuxtApp()
  return useMutation({
    mutationFn: (post: Post) => updatePost($api, post),
    onSuccess: (_data, post) => {
      queryClient.invalidateQueries({ queryKey: postKeys.lists() })
      queryClient.invalidateQueries({ queryKey: postKeys.detail(post.id) })
    },
  })
}
```
- **Server-side cookies**: axios does not forward the incoming request's cookies/headers, so authenticated calls fail during SSR unless the per-request instance sets them (`useRequestHeaders(['cookie'])` in the plugin, see `api-client-patterns`). Get the instance in the composable's setup scope (as in `usePost`). Never share one auth-bearing instance across requests.
- **SSR hydration**: create the `QueryClient` in a Nuxt plugin, dehydrate into `useState` on the server, hydrate on the client.
```ts
// plugins/vue-query.ts
import type { DehydratedState } from '@tanstack/vue-query'
import { QueryClient, VueQueryPlugin, dehydrate, hydrate } from '@tanstack/vue-query'

export default defineNuxtPlugin((nuxtApp) => {
  const state = useState<DehydratedState | null>('vue-query')
  const queryClient = new QueryClient({ defaultOptions: { queries: { staleTime: 60_000 } } })
  nuxtApp.vueApp.use(VueQueryPlugin, { queryClient })

  if (import.meta.server) {
    nuxtApp.hooks.hook('app:rendered', () => {
      state.value = dehydrate(queryClient)
    })
  }
  if (import.meta.client) {
    nuxtApp.hooks.hook('app:created', () => {
      hydrate(queryClient, state.value)
    })
  }
})
```
  To prefetch on the server, `await` the query's `suspense()` in the page's `<script setup>`: `const { data, suspense } = usePost(id); await suspense()`. Only do this for data needed in the SSR HTML; otherwise let it load client-side.
- **staleTime**: set a non-zero default (default `0` refetches on every mount and double-fetches right after hydration). Longer for rarely-changing data, `0` only when it must always be fresh. Keep `gcTime` at its default unless there's a reason.
- **Invalidation**: every mutation invalidates the affected keys in `onSuccess` (via the key factory; invalidate lists and the touched detail). Use `setQueryData` only for optimistic updates, with rollback in `onError`.

## Pinia (`@pinia/nuxt`)
- Add `@pinia/nuxt` to `modules` in `nuxt.config.ts`.
- Name stores `useXStore` (`useSessionStore`), one per domain, in `stores/`, using setup-style (`defineStore('session', () => { ... })`).
- Store only cross-page client state (session, preferences, UI flags). Never server data; that is TanStack Query's or `useAsyncData`'s.
```ts
export const useSessionStore = defineStore('session', () => {
  const user = ref<User | null>(null)
  const isSignedIn = computed(() => user.value !== null)
  return { user, isSignedIn }
})
```

## Server routes
- Live in `server/api/`. Validate all input with Zod; fail with 400. Security rules for routes: see `frontend-security`.
```ts
import { z } from 'zod'

const schema = z.object({ id: z.coerce.number().int().positive() })
export default defineEventHandler(async (event) => {
  const result = await getValidatedRouterParams(event, (p) => schema.safeParse(p))
  if (!result.success) {
    throw createError({ statusCode: 400, statusMessage: 'Invalid id' })
  }
  return getPost(result.data.id)
})
```

## Config
- Secrets only in `runtimeConfig` (private keys at top level, never under `public`). Set via `NUXT_*` env vars. See `frontend-security`.
- Per-page meta with `useSeoMeta({ title, description, ogTitle, ... })`.
- Rendering mode per route in `nuxt.config.ts`:
```ts
routeRules: {
  '/': { prerender: true },        // SSG
  '/blog/**': { isr: 3600 },       // SSR + cache; isr is host-dependent (e.g. Vercel/Netlify)
  '/account/**': { ssr: false },   // SPA
}
```
- Pages own data and routing (see `atomic-components-design`).
- Caching and rendering-mode performance trade-offs: see `frontend-performance`.
