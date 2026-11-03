---
name: storybook-workflow
description: Storybook standards for Vue components - CSF3 stories in TypeScript, story organisation by atomic level, required states, play-function interaction tests, a11y addon with CI failure, visual regression, autodocs, decorators for providers, Nuxt integration caveats, and CI test running. Load when creating or reviewing a component, writing a story, or setting up Storybook.
---

# Storybook workflow

## Rules
- Every atom, molecule and organism gets a story. Pages do not.
- Co-locate: `BaseButton.vue` + `BaseButton.stories.ts` in the same folder.
- CSF3 with TypeScript; type the default export with `satisfies Meta<typeof X>` (not `: Meta`) so story args stay inferred.
- Cover the states the component supports: default, disabled, error, loading, long text (text that wraps/truncates). Skip states the component doesn't have.
- Add a `play` function to any story with interaction (click, type, open/close, validation). Use `storybook/test` (`within`, `userEvent`, `expect`); query by role/label like `frontend-testing`.
- Run the a11y addon (`@storybook/addon-a11y`, axe) on every story. Fix violations; never turn `a11y` off globally. A per-story disable needs a comment saying why. See `frontend-a11y-check`.
- Make axe violations fail CI (Storybook 9+ a11y addon, run through the Vitest addon or test-runner) in `.storybook/preview.ts`; `'todo'` only warns:
```ts
import type { Preview } from '@storybook/vue3-vite'

export default { parameters: { a11y: { test: 'error' } } } satisfies Preview
```
- Stories use props/args and slots only; atoms/molecules never need stores or queries (see `atomic-components-design`). For organisms, pass data via args.
- Targets Storybook 9+: import `Meta`/`StoryObj` from the framework package `@storybook/vue3-vite` and test helpers from `storybook/test` (not the older `@storybook/test`).

## Example
```ts
import type { Meta, StoryObj } from '@storybook/vue3-vite'
import { expect, fn, userEvent, within } from 'storybook/test'
import BaseButton from './BaseButton.vue'

const meta = {
  title: 'Atoms/BaseButton',
  component: BaseButton,
  args: { onClick: fn() },
  render: (args) => ({
    components: { BaseButton },
    setup: () => ({ args }),
    template: '<BaseButton v-bind="args">Save</BaseButton>',
  }),
} satisfies Meta<typeof BaseButton>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  play: async ({ canvasElement, args }) => {
    await userEvent.click(within(canvasElement).getByRole('button', { name: 'Save' }))
    await expect(args.onClick).toHaveBeenCalledTimes(1)
  },
}
export const Disabled: Story = { args: { disabled: true } }
export const Loading: Story = { args: { loading: true } }
```

## Organisation
- Titles mirror atomic levels: `Atoms/BaseButton`, `Molecules/SearchField`, `Organisms/SiteHeader`. Use `Foundations/` for tokens, colour, and type docs (`frontend-design-systems`).
- One stories file per component; shared fixtures in `*.fixtures.ts` beside it. Keep a story's name a state, not a sentence (`Disabled`, `LongText`, `ErrorState`).
- Add `tags: ['autodocs']` on the meta so props, slots, and events tables come from the component types. Write a short description in the component's JSDoc, not in the story.
- Use `argTypes` only to fix controls (`control: 'select'`) or hide internals; do not repeat inferred types.

## Interaction tests
- `play` runs in the browser against the rendered story: use `userEvent`, role queries, and `await expect(...)`. Group steps with `step('opens menu', async () => {...})` when a flow has more than 3 actions.
- Shared setup (router, i18n, Pinia for organisms) goes in a decorator in `.storybook/preview.ts` using `setup((app) => app.use(...))` from `@storybook/vue3-vite`, not in each story.
- Run them in CI with the Vitest addon (`@storybook/addon-vitest`) or the test runner; verify which is current for the installed Storybook version.

## Visual regression
- Use a snapshot service (Chromatic, or Playwright screenshots of the built Storybook). Snapshot stable states only; disable animations (`parameters: { chromatic: { pauseAnimationAtEnd: true } }` or reduced motion) and mock dates and random data.
- Review diffs as a design review; never bulk-accept. Thresholds: zero tolerance on atoms, small tolerance only for antialiasing noise.

## Nuxt caveats
- Storybook runs through Vite, not Nuxt. Auto-imports, `useRoute`, `useFetch`, `NuxtLink`, and `#imports` do not exist unless stubbed. Keep story-targeted components free of Nuxt composables, per `atomic-components-design`; pass data through props (`nuxt-project-patterns`).
- If a component must render `NuxtLink`, register a stub component globally in `preview.ts` that renders `<a :href="to">`.
- Use the `@nuxtjs/storybook` module only if the project accepts its version coupling; verify support for the installed Nuxt and Storybook versions.
- Import the same global CSS and tokens as the app in `preview.ts` so stories match production (`css-styling-standards`).

## Anti-patterns
- Stories that fetch real data or need a store.
- `play` functions that assert implementation details, or use `setTimeout`.
- Disabling a11y checks globally, or accepting visual diffs unreviewed.
- Huge "kitchen sink" stories instead of one story per state.
