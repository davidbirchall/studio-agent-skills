---
name: frontend-a11y-check
description: accessibility checklist for frontend work targeting WCAG 2.2 AA minimum (AAA where possible). Load when building or reviewing UI, forms, interactive components, colours, or motion.
---

# Frontend accessibility checklist

**WCAG 2.2 AA is a hard minimum. Aim for AAA where possible.**

## Checklist
- Semantic HTML first (`button`, `a`, `nav`, `main`, headings in order). ARIA only when no native element fits.
- Everything interactive is keyboard reachable and operable; tab order follows visual order; never `tabindex` > 0.
- Focus is always visible (never `outline: none` without a replacement).
- Contrast (AA, required): 4.5:1 text, 3:1 large text and UI components.
- Contrast (AAA, target): 7:1 text, 4.5:1 large text.
- Target size: 24×24 CSS px is the AA minimum (2.5.8); 44×44 px is the AAA target (2.5.5).
- Never convey state by colour alone (add icon, text, or pattern).
- Every input has a programmatic label (`<label for>` or wrapping); errors are associated via `aria-describedby`. Form patterns: see `form-handling`.
- Images: meaningful `alt`; decorative `alt=""`.
- Respect `prefers-reduced-motion`. Use the single global token-duration approach in `animation-motion` (reduced-motion overrides of the `--motion-duration-*` tokens in the global stylesheet), not a blanket `* { animation: none; transition: none }` rule and not per-component styles.

## Landmarks and headings
- One `main` per page, plus `header`, `nav`, `footer` as needed. Label repeated landmarks (`<nav aria-label="Breadcrumb">`).
- One `h1` per page; do not skip levels. Pick the heading level for structure, then style it with a class.
- Provide a "skip to main content" link as the first focusable element.

## Keyboard and focus
- Use `button` for actions and `a` for navigation. A clickable `div` is a bug.
- After a route change, move focus to the new page heading or `main` (`tabindex="-1"`) so screen-reader and keyboard users are not stranded.
- Dialogs: use native `<dialog>` with `showModal()` where possible (focus trap, Esc and inert background come free). Otherwise trap focus, close on Esc, and **return focus to the opener** on close.
- Do not move focus on hover or on input. Never auto-focus something that scrolls the user away.
- Use `:focus-visible` for the focus style from a token; ensure it has 3:1 contrast against its surroundings.

## Forms
- Placeholder is not a label. Required state is stated in text, not only `*` or colour.
- Error wiring (`aria-invalid`, `aria-describedby`, error summary) is defined in `form-handling`; do not reinvent it per component.

## ARIA only when needed
- First rule: no ARIA beats bad ARIA. Reach for it only for patterns HTML lacks (tabs, combobox, disclosure state).
- If you add a role, you own its keyboard behaviour and required attributes.
- `aria-label` on a non-interactive `div`/`span` is usually ignored; icon-only buttons need an accessible name (`aria-label` or visually hidden text).
- Never `aria-hidden="true"` on a focusable element.

## Live regions
- Announce async results (saved, N results, errors not tied to a field) with a persistent container: `<div role="status" aria-live="polite">`. The container must exist in the DOM before its text changes.
- Use `role="alert"` only for urgent, rare messages. Do not announce on every keystroke.

## Colour and non-colour cues
- Check tokens for both themes (`css-styling-standards`); dark mode needs its own contrast check.
- State (error, selected, link in text) gets a second cue: icon, text, underline or weight.

## Common mistakes
- `outline: none` on focus, or `:hover`-only reveal of controls.
- Custom select/checkbox built from `div`s with no keyboard handling.
- Toasts that vanish before they can be read, with no live region.
- Link text such as "click here"; use text that makes sense out of context.

## Verification
- Automated: axe (`@axe-core/playwright` in e2e; see frontend-testing). In-editor, `eslint-plugin-vuejs-accessibility` catches static template issues (verify rule names against the installed version).
- Manual: a keyboard-only pass (Tab, Shift+Tab, Enter, Space, Esc) on every new interactive feature. Axe catches only part of WCAG.
- Screen-reader smoke test (VoiceOver on macOS, or NVDA on Windows): navigate by landmarks and headings, tab through the controls and confirm each is announced with name and role, trigger an error and a status message and confirm they are read.
- Zoom to 200% and 400% width-reflow; confirm no content is lost or needs two-axis scrolling.

## Pre-merge checklist
- [ ] Keyboard pass done, focus visible and ordered
- [ ] Dialogs/menus return focus; Esc closes
- [ ] Every control has an accessible name; errors associated
- [ ] Contrast checked in light and dark; no colour-only state
- [ ] Reduced motion honoured; axe clean in e2e/Storybook

The Storybook a11y addon runs axe on every story: see `storybook-workflow`.
