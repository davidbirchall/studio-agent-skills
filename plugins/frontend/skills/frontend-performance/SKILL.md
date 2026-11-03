---
name: frontend-performance
description: performance standards for Vue/Nuxt frontends — Core Web Vitals targets, per-route rendering choice, images (@nuxt/image or plain img), lazy loading, fonts, bundle budgets, reactivity cost, third-party scripts, INP. Load when building pages, adding images/fonts/scripts/dependencies, or reviewing or debugging slow UI.
---

# Frontend performance

## Targets
Google "good" thresholds, measured at the **75th percentile** of real users (mobile and desktop separately):
- LCP ≤ 2.5 s
- INP ≤ 200 ms
- CLS ≤ 0.1

Verify with Lighthouse CI (lab, per PR) and WebPageTest (lab, real devices/networks). Lab scores are a proxy; where real-user data exists (CrUX, RUM), it decides.

## Rendering mode
Not standardised; it varies per project. Choose **per route** with `routeRules` (see `nuxt-project-patterns`) and **record the choice** (and why) in the project's docs or an ADR. Do not default a whole app to one mode without checking each route's data freshness and SEO needs.

## Images
The LCP element is usually an image. Check which approach the project uses before adding images.

**With `@nuxt/image`** (`NuxtImg` / `NuxtPicture`):
- Always set `width` and `height` (or an aspect-ratio via CSS) so space is reserved; this prevents CLS.
- LCP image: `loading="eager"` and `fetchpriority="high"`; never lazy-load it. Everything below the fold uses `loading="lazy"`.
- Set `sizes` for responsive images; use `NuxtPicture` for modern formats (AVIF/WebP) with fallback.
- Provider and format options depend on the module version and configured provider; check the installed version's docs.

**With plain `<img>`:**
- Explicit `width`/`height` attributes (or `aspect-ratio`) on every image.
- Serve modern formats (AVIF/WebP) via `<picture>`, and `srcset` + `sizes` for responsive widths.
- Same `loading`/`fetchpriority` rules for the LCP image vs the rest.

Alt text rules: `frontend-a11y-check`.

## Lazy loading
- Routes are code-split by default; do not import page-level components eagerly elsewhere.
- Prefix a component with `Lazy` in templates (`<LazyHeavyChart />`) to defer its chunk. Pair with `v-if` so it loads only when needed (modal opened, tab selected); a `Lazy` component rendered unconditionally still loads at start.
- Outside Nuxt auto-imports use `defineAsyncComponent(() => import('./HeavyChart.vue'))`.
- Never lazy-load above-the-fold content or the LCP element.

## Fonts
- Self-host; preload only the one or two files used above the fold (`<link rel="preload" as="font" type="font/woff2" crossorigin>`). `crossorigin` is required even for same-origin fonts or the preload is wasted.
- `font-display: swap` (or `optional` when layout stability matters more than the custom face). Use a metrics-matched fallback (`size-adjust`, `ascent-override`) to limit CLS from swap.
- Subset, and prefer WOFF2 variable fonts over many static weights. `@nuxt/fonts` can automate this if the project uses it.

## Bundle budgets and analysis
- Set a budget per project, record it, and enforce it in CI (Lighthouse CI `resource-summary` budgets or a bundle-size check) rather than reviewing sizes by eye.
- Inspect with the project's analyze script (e.g. `pnpm nuxt analyze`) when adding a dependency or a budget fails.
- Review new dependencies for size and tree-shaking (ESM, named imports; no whole-library imports like `import _ from 'lodash'`). Dependency review rules: `frontend-security`.

## Reactivity cost
- Large read-mostly objects/arrays (API payloads, chart data): `shallowRef`, and replace the value rather than mutating deep.
- Class instances and third-party objects (map, chart, editor instances): `markRaw`.
- `v-once` / `v-memo`: only after profiling shows a hotspot; they hide updates and are easy to get wrong.
- Long lists (hundreds of rows+): virtualize or paginate. Do not render everything and hide with CSS.
- Do not copy server data into extra refs or Pinia; see `nuxt-project-patterns`.

## Layout shift from async content
- Skeletons and placeholders must match the final content's dimensions (`min-height`, `aspect-ratio`); a different-sized skeleton causes the shift it was meant to hide.
- Reserve space for embeds, banners and late-injected components; insert new content in response to user input, not above existing content.
- Animate `transform`/`opacity`, not layout properties (`top`, `height`, `width`). Respect `prefers-reduced-motion` (`frontend-a11y-check`).

## Third-party scripts
- Every script needs an owner and a reason; remove unused tags.
- Load with `async`/`defer`, after hydration or on interaction where possible; never as a blocking `<head>` script.
- Measure before and after adding one (LCP, INP, total blocking time). Tag managers count; audit what they inject.

## INP
- Keep event handlers cheap: no heavy sync work, large loops or big JSON parsing in click/input handlers.
- Break up long tasks (>50 ms): do the visual update first, then yield with `scheduler.yield()` falling back to `setTimeout(0)` (`scheduler.yield` is not in all browsers). Move heavy compute to a Web Worker.
- Debounce input-driven work (search, validation) and keep per-keystroke state local to the input's component so large trees don't re-render.
- Hydration cost counts on SSR pages; ship less client JS for static content.

## See also

Optional, if installed: performance-engineering (the shared plugin) for the broader discipline this skill applies. This skill stands on its own.
