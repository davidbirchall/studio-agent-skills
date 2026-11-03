---
name: css-styling-standards
description: CSS standards for Vue components — native CSS in scoped styles, BEM, global design tokens, modern CSS features, and `:deep()` as last resort. Load when writing or reviewing component styles or design tokens.
---

# CSS styling standards

## Rules
- Native CSS only (no Sass/Less/Tailwind/CSS-in-JS), inside `<style scoped>`.
- BEM class names, one element level only: `.card__title--active`. Never `.card__header__title`. Write BEM selectors flat; native CSS nesting cannot append a suffix to `&`.
- Design tokens are CSS custom properties in ONE global file (e.g. `assets/css/tokens.css`). Components reference tokens; no hard-coded colours/spacing.
- Modern CSS: nesting, `:where()` for low specificity, container queries, logical properties (`margin-inline`, `padding-block`, `inset-inline-start`).
- Mobile-first: base styles for small screens, `min-width` queries to enlarge.
- Units: `rem` for sizing/spacing, `clamp()` for fluid type; avoid `px` except hairlines.

## Tokens and theming
- Components use semantic tokens (`--color-text`, `--space-4`); never primitives and never raw values. Token tiers and naming: `frontend-design-systems`.
- Dark mode is a different value set for the same semantic tokens on a root selector (`:root[data-theme='dark']`); a component has no dark-specific rules. If you need one, a token is missing.
- Z-index comes from the scale (`--z-dropdown`, `--z-modal`, `--z-toast`); no bare numbers. Create a stacking context deliberately (`isolation: isolate`) rather than raising numbers.

## Scoped vs global
- Component styles live in `<style scoped>`. Global CSS is only: the tokens file, reset/base elements, and shared transition classes (`animation-motion`).
- Do not style bare element selectors in scoped blocks as a substitute for a class; add a class.
- Scoped styles do not reach slot content from children or third-party DOM; use a class on your own markup, not `:deep()`.

## Layers and specificity
- Order cascade with `@layer` in the global file, declared once: `@layer reset, tokens, base, components, utilities;`. Verify layer support against your browser targets.
- Unlayered styles beat layered ones; do not leave stray global rules unlayered.
- Keep specificity flat: single class selectors, no IDs, no `element.class`, no selector chain deeper than two classes. Wrap generic defaults in `:where()` so consumers override them without a fight.
- `!important` is banned. The only tolerated use is overriding third-party inline styles, with a comment. If you reach for it, fix order, layer or specificity instead.

## Responsive and logical properties
- Prefer container queries for component layout (the component responds to its slot, not the viewport); use viewport media queries only for page-level layout.
- Logical properties throughout (`margin-inline`, `padding-block`, `inset-inline-start`, `border-start-start-radius`) so right-to-left works (`frontend-internationalization`).
- Define breakpoints once as documented values; custom properties cannot be used inside media queries, so repeat the literal values consistently.

## File organisation
```text
assets/css/
  tokens.css      # custom properties, both themes
  base.css        # reset + element defaults
  transitions.css # shared Vue transition classes
```
Component CSS stays in its `.vue` file. Do not create per-feature global stylesheets.

## Review checklist
- No hard-coded colour, spacing, radius, duration or z-index.
- No `!important`, ID selector, or `:deep()` without a why comment.
- Works at 200% zoom, narrow container, and with dark theme.
- Focus-visible state present (`frontend-a11y-check`).

## `:deep()` — last resort only
Try in order before using it (props, slots, CSS custom properties):
1. A prop or variant class on the child.
2. A slot, so the parent owns the markup and styles it.
3. A CSS custom property the child exposes and consumes.

If you still need it, scope it tightly and comment why:
```css
/* why: third-party widget exposes no slot or custom property for its icon colour */
.panel :deep(.child__icon) { color: var(--color-accent); }
```

## Example
```vue
<style scoped>
.card {
  container-type: inline-size;
  padding-inline: var(--space-4);
  font-size: clamp(1rem, 0.9rem + 0.5vw, 1.25rem);

  &:hover { box-shadow: var(--shadow-2); }
}

.card__title { color: var(--color-text); }
.card__title--active { color: var(--color-accent); }
.card__body { display: block; }

/* .card is the container (container-type above); this responds to its width, not the viewport */
@container (min-width: 30rem) {
  .card__body { display: grid; grid-template-columns: auto 1fr; }
}
</style>
```
Native nesting is for `&:hover`, `& .x` and similar; BEM element/modifier selectors stay flat.
