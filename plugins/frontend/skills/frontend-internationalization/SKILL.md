---
name: frontend-internationalization
description: i18n standards for Vue 3 and Nuxt 3 using @nuxtjs/i18n (vue-i18n) — when to add i18n, locale file structure and key naming, message format and pluralisation, lazy-loaded locales, routing strategy and SEO alternates, locale detection and cookie persistence, Intl formatting, RTL and text expansion, translated validation/alt/aria text, lang/dir attributes, testing and translation workflow. Load when adding or changing translations, locales, localized routing, formatting of dates/numbers/currency, or reviewing user-facing strings.
---

# Frontend internationalization

Use `@nuxtjs/i18n` (wraps vue-i18n). Verify module option names and behaviour against the installed `@nuxtjs/i18n` version; they changed between majors.

## When to add
- Add i18n at project start if more than one locale is plausible. Retrofitting means touching every string.
- Single-locale apps still route user-facing text through `t()` once i18n is installed; do not mix.

## No hard-coded strings
- No user-facing text literals in templates or scripts: labels, buttons, errors, titles, `placeholder`, `alt`, `aria-label`, `title`, meta tags. Use `t('key')` / `$t`.
- Never concatenate sentence fragments. Translate whole sentences with placeholders; word order differs per language.
- Do not translate: ids, route names, enum values or codes sent to or received from an API, CSS classes, test ids. Translate the display label, keyed by the enum value.

## Locale files and keys
- One JSON file per locale (`locales/en.json`, `locales/fr.json`), or split per feature if large. Same key set in every locale.
- Keys: lowercase dot-path, feature-scoped, describing purpose not text: `checkout.summary.total`, `common.actions.save`. Shared words live under `common`.
- Do not use the English text as the key. Do not reuse one key for different meanings.
- Keep a base/fallback locale complete; others may lag and fall back.

## Message format
- Named interpolation, not positional: `"greeting": "Hello, {name}"` and `t('greeting', { name })`.
- Pluralisation with pipes, and pass the count: `"items": "no items | one item | {count} items"` with `t('items', count)` (or `{ count }`). Languages with more plural forms need more branches; confirm vue-i18n's plural rule support for the version.
- Rich text with embedded components: use the `<i18n-t>` component with slots, not `v-html` (`frontend-security`).
- Do not put HTML in messages.

## Module config and lazy loading
```ts
export default defineNuxtConfig({
  modules: ['@nuxtjs/i18n'],
  i18n: {
    defaultLocale: 'en',
    strategy: 'prefix_except_default',
    locales: [
      { code: 'en', language: 'en-CA', file: 'en.json', name: 'English' },
      { code: 'fr', language: 'fr-CA', file: 'fr.json', name: 'Francais' },
    ],
    detectBrowserLanguage: { useCookie: true, cookieKey: 'i18n_locale', redirectOn: 'root' },
  },
})
```
- Load locale messages lazily (per-locale `file` entries) so users download only their locale. Verify the lazy-loading and `langDir` options for the installed version.
- Keep eagerly bundled messages to the default locale only if needed for fallback.

## Routing and SEO
- Pick one strategy deliberately (`prefix`, `prefix_except_default`, `no_prefix`) and document it. Use prefixed URLs when pages must be indexable per language.
- Navigate with `useLocalePath()` / `<NuxtLinkLocale>`, never hand-built locale paths.
- Emit `hreflang` alternates, canonical URLs and `og:locale` with `useLocaleHead()` (verify the helper and `baseUrl` requirement for the version). Every localized page links to all its alternates.
- Language switcher: lists locales by their own names, uses `switchLocalePath(code)`, is a real link, and sets `lang` on each option's text when it differs from the page.

## Detection and persistence
- Detection order: URL prefix, then cookie, then `Accept-Language`/browser. Persist the choice in a cookie so SSR and client agree; do not use `localStorage` (not readable on the server, causes hydration mismatch).
- Never decide locale in `onMounted`; resolve before render.
- Cookie is a preference cookie; follow privacy requirements for the app.

## Formatting
- Use vue-i18n number and datetime formats, which wrap `Intl`: `n(value, 'currency')`, `d(date, 'short')`, defined once in `numberFormats` / `datetimeFormats` per locale. Verify the config key names for the version.
- Currency is per data (the amount's currency), not per locale. Pass the currency explicitly.
- Relative time: `Intl.RelativeTimeFormat` with the active locale. Lists: `Intl.ListFormat`.
- Never format with manual string building or `toLocaleString()` without the active locale. Store and transmit dates as ISO 8601/UTC; format only at display.
- Sorting and comparing user-visible strings: `Intl.Collator` with the locale.

## Layout: text expansion, RTL
- Translated text can be 30-50% longer (German, French) or shorter (CJK). Do not fix widths on text containers; allow wrapping; test with the longest locale.
- Set `<html lang>` from the active locale's `language` and `dir` (`rtl`/`ltr`). Configure through `useLocaleHead()` or `useHead`; verify output in the rendered HTML.
- Use CSS logical properties (`margin-inline-start`, `padding-inline`, `inset-inline-end`, `text-align: start`) instead of left/right. Standards: `css-styling-standards`.
- Mirror directional icons (arrows, chevrons); do not mirror logos, media controls or numerals.

## Accessibility
- Translate `alt`, `aria-label`, `aria-describedby` text, page `<title>` and live-region messages. Checks: `frontend-a11y-check`.
- Mark inline foreign-language phrases with a `lang` attribute.

## Validation messages
- Schemas return message keys (or key + params), and the form layer translates them with `t()` at render time so errors update on locale change. Do not bake translated strings into a module-level schema. Form rules: `form-handling`.
- Map server error codes to keys; do not display raw server text.

## Testing
- CI fails on missing keys: a script compares all locale key sets to the base locale, and the app runs with missing-key warnings treated as errors in tests. Unused-key detection is optional.
- Unit tests mount with the real i18n plugin and the base locale; assert on rendered text or roles per `frontend-testing`.
- Use a pseudo-locale (accented, padded text such as `[!! Ĥéļļö ûśéŕ !!]`) in dev/Storybook to expose hard-coded strings and overflow. Generate it; do not hand-write it.
- Test at least one RTL locale visually if RTL is supported.

## Translation workflow
- Developers add keys to the base locale only, with a short description in the key file for context (screen, placeholder meaning).
- Export/import the locale files through a translation tool or translator; never machine-translate into production without human review.
- Treat locale files as code: linted in CI for valid JSON, same key set, no trailing whitespace.
- Remove keys when the feature is removed.
