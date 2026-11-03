---
name: atomic-components-design
description: rules for structuring Vue components by atomic design (atoms, molecules, organisms, pages) and where data and state may live. Load when deciding where a component belongs, splitting or composing components, or reviewing component boundaries.
---

# Atomic component design

## Layers
| Layer | Folder | May do | Must not |
|---|---|---|---|
| Atom | `components/atoms/` | Props in, events out | Fetch data, touch stores/queries |
| Molecule | `components/molecules/` | Compose atoms; props in, events out | Fetch data, touch stores/queries |
| Organism | `components/organisms/` | Compose molecules/atoms; composables for UI-local concerns only (toggle, focus, form state) | Touch Pinia/TanStack Query, own routing |
| Template/Page | `pages/`, layouts | Own Pinia stores, TanStack Query, routing; pass data down as props | — |

## Rules
- Data flows from pages down via props; user actions flow up via events.
- Pinia and TanStack Query are called only in pages/templates; see `nuxt-project-patterns` for the Pinia vs TanStack Query split.
- Prefer slots over adding props for content/variants.
- If a component needs two unrelated props to behave, split it into two components.
- Don't import upward (an atom never imports a molecule).

## Which layer? Decision test
Ask in order:
1. Does it need data, a store, a query or the router? It is a page/template (or receives that via props from one).
2. Does it have its own non-trivial UI state or behaviour (form state, open/close, keyboard handling across parts)? Organism.
3. Does it combine two or more atoms into one reusable unit with a single purpose (label + input + error)? Molecule.
4. Otherwise it is an atom: one element, one job, no knowledge of the domain.

Domain words (`UserCard`, `OrderRow`) are a smell below organism level; atoms and molecules stay generic.

## Contracts per layer
- Atom: typed props, `v-model` via `defineModel` where it holds a value, native attributes pass through (`inheritAttrs`), one default slot. Emits only events the native element would.
- Molecule: props for what it displays, named slots for composition, emits user intent (`select`, `clear`). No domain types in props beyond plain data.
- Organism: props are plain data shaped for display, emits a small set of intent events with typed payloads, owns UI-local state only.
- Declare every prop and emit with TypeScript types; no untyped `$attrs` forwarding as an API.

## Naming and layout
- Atoms prefixed `Base` (`BaseButton.vue`); molecules and organisms named by purpose (`SearchField.vue`, `SignupForm.vue`). Co-locate the story: `BaseButton.vue` + `BaseButton.stories.ts`.
- Feature subfolders inside a layer are fine (`organisms/checkout/`); do not add parallel trees. Full layout in `frontend-architecture`.

## Promotion and demotion
- Promote only on a second real use. First use stays next to its page; extracting early guesses the API wrong.
- Promote atom -> molecule when the same group of atoms repeats with the same wiring.
- Demote or split when a component gains a prop that only matters to one consumer.

## Anti-patterns
- Atom calling `useFetch`, `useQuery` or `useRoute`: move to the page and pass props.
- Molecule owning routing (`useRouter().push`): emit an event, let the page navigate.
- Variant explosion: `type`, `size`, `kind`, `mode` combined into dozens of states. Keep a small closed set (`variant`, `size`) and compose the rest with slots or a wrapper.
- Boolean prop piles (`hasIcon`, `showFooter`): use a slot; presence of the slot is the switch.
- Passing a whole store or API object as a prop: pass only the fields displayed.
- Styling a child through `:deep()` instead of a prop, slot or custom property (`css-styling-standards`).

## Review checklist
- No store, query or router access below page level.
- No upward imports; story exists; props typed; slots documented in the story.
- Component works with only its props (render it in Storybook with no app context).

## Example
Prop sprawl (bad): `<BaseCard title icon footerText footerLink showBadge badgeText />`

Slots (good):
```vue
<BaseCard>
  <template #header><BaseHeading level="2">Title</BaseHeading></template>
  <template #footer><BaseLink href="/more">More</BaseLink></template>
</BaseCard>
```

Worked layering for a signup screen: `pages/signup.vue` owns the mutation and server errors; `SignupForm` (organism) owns form state and validation; `FormField` (molecule) composes `BaseLabel`, `BaseInput` and an error text; `BaseInput` (atom) is a styled input with `v-model`. Data goes down as props (`pending`, `serverErrors`); `submit` goes up as an event. Form specifics: `form-handling`.

Every atom, molecule and organism needs a story: see `storybook-workflow`.
