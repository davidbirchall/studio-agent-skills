---
name: frontend-architecture
description: rules for structuring Vue 3 and Nuxt 3 apps — folder layout (feature vs layer), where components, composables, services, utils, types, layouts, pages, plugins, middleware and server code live, module boundaries and dependency direction, naming, auto-import limits, shared vs feature-local code, barrel-file policy, when to extract a composable, layer or module, and the rules for writing Vue 3 components (script setup, SFC order, props/emits/defineModel, v-for, ref vs reactive, computed vs watch, template refs, generics), plus Vue and Nuxt typing (refs, provide/inject, props/emits/slots, generated types, vue-tsc). Load when creating or reorganising folders, deciding where code belongs, or writing or reviewing any .vue file or composable.
---

# Frontend architecture

Target Nuxt 3 (see `nuxt-project-patterns`). Layer rules for components: `atomic-components-design`. State placement: `state-management`. API code: `api-client-patterns`. TypeScript rules: `typescript-conventions`. Styling: `css-styling-standards`.

## Folder layout
Organise by layer (Nuxt convention) with feature subfolders inside the layers. Do not invent a parallel `features/` tree unless the app is large enough to justify a Nuxt layer (see Extraction).
```
components/{atoms,molecules,organisms}/   # organisms may have feature subfolders: organisms/checkout/
composables/                              # useX, one concern each; feature subfolders allowed
services/                                 # plain typed API functions, no Vue state (api-client-patterns)
stores/                                   # Pinia setup stores (state-management)
utils/                                    # pure functions, no Vue/Nuxt imports
types/                                    # shared types; feature-only types sit beside the feature
layouts/  pages/  middleware/  plugins/   # Nuxt-owned; keep thin
server/{api,middleware,utils}/            # Nitro only; never imported by client code
```
- `pages/` and `layouts/` own routing, data and stores. They stay thin: wire composables to organisms.
- `middleware/` is for route guards only; no data rendering logic.
- `plugins/` provide instances (`$api`, query client). No business logic.
- `utils/` stay framework-free so they unit test without Nuxt.

## Dependency direction
- One way only: `pages -> organisms -> molecules -> atoms`. Never import upward or sideways across a layer boundary.
- `composables`, `services`, `stores`, `utils` never import components.
- `services` and `utils` never import composables or stores. Composables may import services and utils.
- `server/` never imports from client folders; share only via `types/` (type-only imports).
- Feature-local code imports shared code, never another feature's internals. If two features need it, move it to shared.

## Shared vs feature-local
- Start local: put code next to its only consumer. Promote to shared on the second real consumer, not before.
- Shared code has no knowledge of any feature (no feature names, routes or copy).

## Naming
- Components: PascalCase files, multi-word (`BaseButton.vue`, `CheckoutSummary.vue`). With Nuxt's default path-prefixed auto-import, folder + file name form the tag, so avoid stutter (`organisms/checkout/Summary.vue` becomes `<OrganismsCheckoutSummary>`); configure `components.dirs` / `pathPrefix` deliberately.
- Composables: `useX.ts`, exported function matches the file name. Stores: `useXStore`. Services: `services/posts.ts` with verb functions (`getPost`).
- Types: PascalCase, no `I` prefix. Folders and non-component files: kebab-case or camelCase, one choice per repo.

## Auto-imports
- Nuxt auto-imports Vue/Nuxt APIs, `components/`, top-level `composables/` and `utils/` (plus `index.ts` one level down). Nested files are not scanned: import explicitly or re-export from `index.ts`.
- Do not rely on auto-import in plain `.ts` outside Nuxt's scan (tests, shared packages): import explicitly there.
- Import types explicitly (`import type`).
- Name collisions silently shadow: keep composable and util names unique.

## Barrel files
- No barrels (`index.ts` re-exporting a folder) by default; they hurt tree-shaking, create import cycles and slow tooling.
- Allowed: a composable feature folder re-exporting its public API purely for Nuxt auto-import, and published packages (`component-library-publishing`).
- Never import through a barrel from inside the same folder.

## Extraction
- Composable: logic with reactive state reused by two components, or a component's script grows past one concern. Data-fetching composables are called from pages only.
- Plain util: logic with no reactivity.
- Nuxt layer or module: only when several apps share it or a feature needs its own routes/plugins/config. Monorepo specifics: `turborepo-workflow`.

## Writing components
- Vue 3, Composition API, `<script setup lang="ts">`. TypeScript for all Vue work.
- SFC block order: `<template>`, `<script setup>`, `<style scoped>`.
- Component names: PascalCase, multi-word (`BaseButton`, not `Button`).
- Props down, events up. Never mutate a prop; emit, or use `defineModel`.
- Type-based `defineProps<T>()` / `defineEmits<T>()` only; no runtime array/object declarations.
- Reactive props destructure (`const { label } = defineProps<...>()`) needs Vue >=3.5; on older versions use `props.label`.
- `v-for` always gets a stable, unique `:key` (never the index for mutable lists).
- Never `v-if` and `v-for` on one element; filter with a `computed` or wrap in `<template v-for>`.
- Prefer `ref` over `reactive`. Prefer `computed` over `watch`; watchers only for side effects.
- Type refs when the initial value is ambiguous: `ref<User | null>(null)`. Template refs: `useTemplateRef<HTMLInputElement>('input')` (Vue >=3.5) or `ref<HTMLInputElement | null>(null)`.
- Generic components need Vue >=3.3: `<script setup lang="ts" generic="T extends { id: string }">`, then `defineProps<{ items: T[] }>()`.
- Composables: `useX`, one concern each, return refs/computed/functions.

```vue
<template>
  <label class="text-field">
    <span class="text-field__label">{{ label }}</span>
    <input v-model="model" class="text-field__input" :disabled="disabled" @blur="emit('blur', $event)" />
  </label>
</template>

<script setup lang="ts">
const { label, disabled = false } = defineProps<{ label: string; disabled?: boolean }>()
const emit = defineEmits<{ blur: [event: FocusEvent] }>()
const model = defineModel<string>({ required: true })
</script>

<style scoped>
.text-field { display: grid; gap: 0.25rem; }
</style>
```

## Vue and Nuxt typing
General TypeScript rules are in `typescript-conventions`; this section covers Vue and Nuxt specifics.
- Typecheck with `vue-tsc --noEmit` (plain `tsc` skips `.vue` files) using the project's typecheck script. Run it in CI; see `frontend-code-quality`.
- Type refs explicitly when the initial value does not show the type: `ref<User | null>(null)`.
- Template refs: `useTemplateRef<HTMLInputElement>('input')` (Vue >=3.5) or `ref<HTMLInputElement | null>(null)`. Handle `null` before use.
- Props, emits and slots use type-based declarations only: `defineProps<T>()`, `defineEmits<{ change: [value: string] }>()`, `defineSlots<{ default(props: { item: T }): unknown }>()` (`defineSlots` needs Vue >=3.3).
- Extract shared prop shapes as exported types and reuse them; do not copy-paste prop lists.
- Generic components (Vue >=3.3): `<script setup lang="ts" generic="T extends { id: string }">`, then use `T` in props and emits.
- `provide`/`inject`: share a typed `InjectionKey<T>` (`const key: InjectionKey<Theme> = Symbol('theme')`); never inject by string. Handle the `undefined` case of `inject` explicitly, not with `!`.
- Nuxt generates types in `.nuxt/` (gitignored): auto-imports, typed `useRuntimeConfig()`, `definePageMeta`, and typed routes where enabled (experimental; check the Nuxt version). Run `nuxi prepare` before typechecking in CI.
- Nuxt projects extend the generated `.nuxt/tsconfig.json` on top of the shared base tsconfig; do not loosen options locally.
- Extend runtime config by augmenting, not casting:
```ts
declare module 'nuxt/schema' {
  interface RuntimeConfig { apiBase: string }
}
export {}
```
- Other augmentation points (Vue `ComponentCustomProperties`, `vue-router` `RouteMeta`, `nuxt/app` `PageMeta`) use `interface` merging in a `.d.ts` or a file with a top-level `export`; one `types/` file per augmented module.
- Types shared by 2+ features go in `types/` or the feature's `types.ts`; do not create one global dumping file.

## See also

Optional, if installed: software-architecture (the shared plugin) for the broader discipline this skill applies. This skill stands on its own.
