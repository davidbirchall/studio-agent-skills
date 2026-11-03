---
name: frontend-design-systems
description: guidance for using and evolving a design system in Vue 3 and Nuxt 3 apps covering design tokens as CSS custom properties with primitive, semantic and component layers, theming, token naming and governance, consistent component APIs (variants, sizes, states, slots, a11y props), spacing scale, composition over configuration, Storybook documentation, contribution, versioning, deprecation, migration, visual regression, avoiding one-off overrides, and accessibility built in. Load when adding or changing tokens or shared components, theming, adopting the design system in an app, or reviewing for design consistency.
---

# Frontend design systems

Atoms and molecules live in the design system (the shared component library); apps compose them. See `atomic-components-design` for layer rules and `component-library-publishing` for releases.

## Tokens
- Tokens are CSS custom properties in the one global tokens file; see `css-styling-standards`. Categories: colour, spacing, type (family, size, weight, line-height), radius, shadow, motion (duration, easing), z-index.
- Layer them primitive -> semantic -> component:
  - Primitive: raw values, named by scale (`--color-blue-600`, `--space-4`). Never used in components.
  - Semantic: purpose, named by role (`--color-text`, `--color-surface`, `--color-border-focus`). Components use these.
  - Component: optional overrides scoped to one component (`--button-bg`), defaulting to a semantic token.
- Naming: `--{category}-{role-or-scale}[-{state}]`, kebab-case, no values or brand names in semantic names (`--color-danger`, not `--color-red`).
- No magic numbers: every colour, spacing, radius, shadow, duration and z-index comes from a token. If none fits, propose a token; do not hard-code.
- Use a z-index scale (`--z-dropdown`, `--z-modal`), not ad hoc values.
- Motion tokens feed `animation-motion` (durations, easing, reduced motion).

## Theming
- Light and dark are different values for the same semantic tokens, switched on a root selector or attribute (`:root[data-theme='dark']`) and optionally `prefers-color-scheme`. Components never branch on theme.
- Retheme by redefining semantic tokens only; primitives stay fixed.
- Every theme must keep contrast at or above WCAG AA for text and UI components. Verify per theme, not once.

## Component API consistency
- Same prop names across components: `variant`, `size`, `disabled`, `loading`, `invalid`. Same value vocabulary (`sm | md | lg`, not `small` in one place and `s` in another).
- Type variants and sizes as unions; see `typescript-conventions`.
- Cover the states every interactive component needs: default, hover, focus-visible, active, disabled, loading, error where relevant.
- Composition over configuration: expose slots for content, and add a prop only for a bounded choice. Boolean-prop sprawl means the component needs splitting.
- Accessibility props are first-class: labels, `aria-*` passthrough, `id` linking, keyboard behaviour. See `frontend-a11y-check`.
- Spread unknown attributes to the root element (`inheritAttrs`) so consumers can add `data-*` and `aria-*`.
- Spacing and density come from the scale (`--space-*`); do not add per-component padding values. A density option, if supported, swaps scale tokens.

## Accessibility baked in
- Components ship accessible by default: contrast met by tokens, visible `:focus-visible` style from a focus token, minimum target size (WCAG 2.2 AA: 24x24 CSS px; aim for 44x44 on touch), reduced motion honoured.
- Consumers should not need to add a11y fixes; fix it in the component and release.

## Documentation
- Every component has a Storybook story per `storybook-workflow`, covering all variants, sizes and states, with the a11y addon on.
- Document token tables (name, role, value per theme) and usage guidance next to the stories.

## Using it in apps
- Use the design system component first. If it nearly fits, request or contribute the change rather than overriding.
- No one-off overrides: no `:deep()` into library components, no `!important`, no copied-and-edited components. Use props, slots or exposed custom properties. `:deep()` rules are in `css-styling-standards`.
- Don't redefine tokens in app code except to apply an defined theme.

## Change rules
- Changes to tokens or shared components need: the use case, a story, an a11y check, and a list of your apps that use them (grep before changing).
- Prefer extending an existing component or token over adding a new one. Add a new one only when a second real use exists.
- Renaming or removing a token or prop is a breaking change. Version with semver and changelog per `component-library-publishing`.

## Deprecation and migration
- Deprecate first: keep the old token/prop working, document the replacement, warn in dev (and mark `@deprecated` in types), and remove only in a major release.
- When tokens change, keep the old name as an alias to the new one for one deprecation window: `--color-text-muted: var(--color-text-secondary);`.
- Migrate apps incrementally, one component or screen at a time; do not mix old and new components within one view longer than needed.

## Visual regression
- Run visual regression against Storybook stories on PRs that touch tokens or shared components. Tooling choice is project specific (for example Chromatic or Playwright snapshots); follow what the repo already uses.
- Review diffs intentionally: a token change should show only the expected differences.

## Example
```css
/* primitive */ :root { --color-blue-600: #1d4ed8; --color-blue-300: #93c5fd; }
/* semantic */  :root { --color-action: var(--color-blue-600); }
                :root[data-theme='dark'] { --color-action: var(--color-blue-300); }
/* component */ .button { background: var(--button-bg, var(--color-action)); }
```
