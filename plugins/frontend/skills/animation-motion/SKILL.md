---
name: animation-motion
description: standards for motion in Vue 3 and Nuxt 3 UIs covering the implementation order (CSS first, then Vue Transition and TransitionGroup, then VueUse), prefers-reduced-motion, duration and easing tokens, transform and opacity performance, flat BEM in scoped styles, Nuxt page transitions, and testing. Load when adding hover, enter/leave, list, loading, or page animations.
---

# Animation and motion

## Implementation hierarchy
Use the lowest-numbered tier that meets the need.
1. **CSS transitions and animations** (primary): `transition`, `@keyframes`, `transform` and `opacity` for standard UI animation.
2. **Vue `<Transition>` / `<TransitionGroup>`**: component lifecycle animations, page transitions, dynamic lists, modals, and conditional rendering (`v-if`, `v-show`, keyed lists).
3. **VueUse** (preferred composable library): reactive animation and DOM-related needs that tiers 1 and 2 cannot express. Verify names against the installed VueUse version.
   - `useTransition`: animated numeric or reactive values (counters, progress).
   - `useIntersectionObserver` / `useElementVisibility`: scroll-triggered reveals (toggle a class, let CSS animate).
   - `usePreferredReducedMotion`: reduced-motion check in JS.
   - `useRafFn`: frame loops.

Do not add other animation libraries (GSAP, `@vueuse/motion`, etc.) without asking the user first. Check bundle cost for any addition (`frontend-performance`).

Motion never carries essential meaning alone, and nothing is hidden until an animation finishes.

### VueUse and reduced motion
JS-driven motion follows the same single reduced-motion approach (tokens, below). Skip or shorten it when reduced motion is preferred.
```vue
<template>
  <span class="total">{{ Math.round(animated) }}</span>
</template>

<script setup lang="ts">
const props = defineProps<{ total: number }>()

const reducedMotion = usePreferredReducedMotion()
const source = ref(props.total) // initial value avoids animating from 0 on mount and keeps SSR HTML correct
const animated = useTransition(source, {
  duration: computed(() => (reducedMotion.value === 'reduce' ? 0 : 300)),
})

watch(() => props.total, (v) => {
  source.value = v
})
</script>
```
- Read durations from the tokens where practical; a hardcoded value above is for illustration.
- VueUse is client-side. Guard browser-only APIs (`window`, `document`, observers) so they run only after mount, and do not render SSR output that depends on animated state. Values like `usePreferredReducedMotion` resolve on the client, so server markup must be valid in the default state.
- If the project uses VueUse in Nuxt 3, `@vueuse/nuxt` auto-imports the composables; otherwise import from `@vueuse/core`.

## Tokens
Define in the global token file (`css-styling-standards`). Values are starting points; adjust to the design system.
```css
:root {
  --motion-duration-fast: 100ms;
  --motion-duration-base: 200ms;
  --motion-duration-slow: 300ms;
  --motion-ease-standard: cubic-bezier(0.2, 0, 0, 1);
  --motion-ease-enter: cubic-bezier(0, 0, 0, 1);
  --motion-ease-exit: cubic-bezier(0.3, 0, 1, 1);
}
```
- Micro-interactions (hover, focus, toggle): fast. Enter/leave and small panels: base. Large surfaces and page changes: slow. Keep UI motion under about 500 ms.
- Exits are faster than entrances. Use enter easing for entering, exit easing for leaving.
- Never hardcode durations or easings in components; use the tokens.

## Performance
- Animate `transform` and `opacity` only. Not `width`, `height`, `top`, `left`, `margin` (layout, causes CLS and jank; see `frontend-performance`).
- Use `will-change` sparingly and only on elements about to animate; remove it afterwards.
- Never `transition: all`. List the properties.
- Exception: expanding height with `grid-template-rows: 0fr` to `1fr` (or a Web Animations API height reveal) animates layout and triggers layout work each frame. Use it only for small, infrequent reveals, and verify against target browsers.

## Reduced motion
WCAG 2.2 AA minimum, AAA aimed for. SC 2.3.3 Animation from Interactions (AAA): users can disable non-essential motion triggered by interaction. Also 2.2.2 Pause, Stop, Hide (AA) for anything moving over 5 seconds, and 2.3.1 Three Flashes (A).
- Honour `prefers-reduced-motion: reduce` globally; remove movement (slides, zooms, parallax, scale) and keep or shorten opacity fades.
```css
@media (prefers-reduced-motion: reduce) {
  :root {
    --motion-duration-fast: 0.01ms;
    --motion-duration-base: 0.01ms;
    --motion-duration-slow: 0.01ms;
  }
}
```
- This token-duration approach is the single global reduced-motion rule. It supersedes the blanket `* { animation: none !important; transition: none !important; }` rule, which also kills opacity fades and essential state feedback.
- Token overrides cover most cases; spots using transforms for large travel need a specific reduced alternative (fade instead of slide).
- Auto-playing or looping motion needs a visible pause control.
- Check state changes still convey the same information with motion off (`frontend-a11y-check`).

## Styling rules
Flat BEM in `<style scoped>`, no Sass-style `&__` nesting. Transition class names are Vue's own, targeted with a named transition.
```vue
<template>
  <Transition name="panel">
    <div v-if="open" class="panel">...</div>
  </Transition>
</template>

<style scoped>
.panel {
  transform-origin: top;
}
.panel-enter-active {
  transition:
    opacity var(--motion-duration-base) var(--motion-ease-enter),
    transform var(--motion-duration-base) var(--motion-ease-enter);
}
.panel-leave-active {
  transition:
    opacity var(--motion-duration-fast) var(--motion-ease-exit),
    transform var(--motion-duration-fast) var(--motion-ease-exit);
}
.panel-enter-from,
.panel-leave-to {
  opacity: 0;
  transform: translateY(-0.5rem);
}
</style>
```
- Scoped styles apply to the child's root element, so the transition classes above work on a single root. Do not reach for `:deep()` unless animating a slotted or child-component internals; last resort.
- `<Transition>` needs a single element child, and a component child must have a single root.
- `<TransitionGroup>` needs unique `key`s; add `.name-move` with a `transform` transition for reorders, and `position: absolute` on `.name-leave-active` so siblings animate into place.
- Use `mode="out-in"` for swapping views; avoid it when it makes UI feel slow.
- Prefer CSS over JS hooks (`@enter`, `@leave`); use hooks only when driving a library.

## Nuxt page transitions
Nuxt 3 uses Vue `<Transition>` on the page wrapper. Set defaults in `nuxt.config.ts`.
```ts
app: {
  pageTransition: { name: 'page', mode: 'out-in' },
}
```
Define the `page-*` classes in a global stylesheet using tokens and the same reduced-motion rule. Override per page with `definePageMeta({ pageTransition: false })`. Pages must have a single root element or transitions silently fail. Keep page transitions subtle: focus moves to new content and scroll behaviour must still work (`frontend-a11y-check`).

## Testing and Storybook
- Vitest and Testing Library: assert end state (element present or absent), not frames. Vue Test Utils stubs `<Transition>` and `<TransitionGroup>` by default, so leave logic completes immediately; leave the default. Opt out with `global: { stubs: { transition: false } }` only when testing transition behaviour itself, so real transitions run.
- Playwright: use `page.emulateMedia({ reducedMotion: 'reduce' })` for the reduced-motion path; wait on state, not timers.
- Storybook: add a story or toolbar toggle showing enter/leave states, and verify the reduced-motion variant (`storybook-workflow`).
- Manual: turn on the OS reduce-motion setting and run the main flows.
