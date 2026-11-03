---
name: accessibility-baseline
description: Cross-platform accessibility baseline for any user interface other than a Vue/Nuxt web page - CLIs, documents, native and desktop apps, mobile apps, PDFs, emails, and game menus. Covers the perceivable/operable/understandable/robust checklist, contrast and text sizing, keyboard and alternate input, focus order, labels and alt text, motion and flashing, error messaging, colour independence, plain language, CLI specifics (NO_COLOR, --plain, screen-reader-friendly output), document and email specifics, when to apply WCAG 2.2 criteria, automated plus manual checks, and recording an accessibility statement. Load when building or reviewing a non-web UI, CLI output, document, email template, or any deliverable a person must read or operate.
---

# Accessibility baseline

For web UI in Vue/Nuxt use the frontend accessibility checklist skill (frontend-a11y-check in the frontend plugin). For game-specific options use game-accessibility (game-development plugin, if installed). Standards and platform guidelines change; verify against current docs.

## Applying WCAG
- WCAG 2.2 (W3C Recommendation, 2023) is written for web content, but its success criteria are the best available yardstick for any UI; check for newer versions and verify current.
- Target level AA as the minimum. Treat criteria as a checklist of outcomes, translating "web page" to "screen, document, or terminal".
- Platform guidelines complement it: Apple Human Interface Guidelines, Android accessibility docs, Microsoft accessibility docs, GNOME/KDE docs. Prefer native accessibility APIs over custom drawing.

## Principles checklist
- Perceivable: all information has a text equivalent; nothing relies on colour, sound, or position alone; content is readable at larger sizes.
- Operable: everything works without a pointer; no time limits without an extend or off option; no flashing; clear way back and to cancel.
- Understandable: plain language, consistent patterns, errors say what happened and how to fix it.
- Robust: uses standard controls, semantic structure, and platform accessibility APIs so assistive technology can read it.

## Contrast and size
- Text 4.5:1 against background; large text (about 18 pt, or 14 pt bold) and UI component boundaries 3:1. Target 7:1 where achievable.
- Support user text scaling to 200% without loss of content or function; do not use fixed pixel sizes where the platform offers dynamic type.
- Touch targets at least 44 x 44 pt (iOS) or 48 x 48 dp (Android); desktop pointer targets at least 24 x 24 px (WCAG 2.5.8). Verify per platform.
- Check both light and dark themes and any high-contrast or forced-colour mode.

## Keyboard and alternate input
- Every function reachable and operable by keyboard (or the platform equivalent: switch, voice, D-pad).
- No keyboard traps; Escape or documented key leaves every mode.
- Single-character shortcuts must be remappable or disableable; avoid conflict with assistive technology keys.
- Gestures (swipe, pinch, drag) always have a single-tap or button alternative.

## Focus and order
- Visible focus indicator on every focusable item, at least 3:1 against adjacent colours.
- Reading and focus order matches visual order; focus moves into new dialogs and returns to the trigger on close.
- Do not move focus unexpectedly on input or load.

## Labels and alternatives
- Every control has an accessible name that matches its visible text; every field has a label, not only placeholder text.
- Meaningful images and icons get concise alt text (what it conveys, not "image of"); decorative ones are marked decorative.
- Charts: provide a text summary or data table.
- Video: captions; audio: transcript.

## Motion and flashing
- No more than 3 flashes in any 1 s; avoid large flashing areas.
- Honour system reduce-motion settings; make auto-playing motion over 5 s pausable.
- Avoid parallax and zoom effects unless optional.

## Errors and feedback
- State the problem, the cause, and the fix in text, next to the field or at the point of failure.
- Do not rely on colour or icon alone; do not clear the user's input on error.
- Confirm destructive or irreversible actions and offer undo where possible.

## Colour independence and language
- Pair colour with text, shape, or pattern. Test greyscale and a colour-blindness simulator.
- Aim for lower-secondary reading level; short sentences, active voice, define jargon and abbreviations on first use.
- Same label for the same action everywhere.

## CLI specifics
- Honour `NO_COLOR` (non-empty value disables colour), `--no-color`, and disable colour and animation automatically when stdout is not a TTY or `TERM=dumb`.
- Never convey meaning by colour alone: prefix with `ERROR:`, `WARN:`, `OK:`.
- Provide `--plain` (or `--no-progress`) output: no spinners, box-drawing, or emoji; one record per line, stable and greppable; offer `--json` for machine reading (`scripting-cli-automation`).
- Progress: print discrete lines at intervals rather than redrawing the same line, which screen readers read repeatedly.
- Tables: keep columns simple; avoid ASCII art for essential information.
- Errors go to stderr with a non-zero exit code and the fix; help text is short and structured.

## Documents and email
- Semantic structure: real headings in order, lists, tables with header rows; never fake headings with bold text.
- Alt text for images; descriptive link text ("Download the 2025 report", not "click here"); no bare URLs as the only label.
- PDFs: tagged, document language and title set, reading order checked, scanned pages OCR'd. Prefer an accessible HTML or source version as well.
- Email: HTML with real text (not a single image), plain-text alternative, font at least 14 px, 4.5:1 contrast, one clear call to action, language attribute set.
- Follow `technical-documentation` for structure and wording.

## Checks
- Automated: linters and platform tools (Xcode Accessibility Inspector, Android Accessibility Scanner, Accessibility Insights for Windows, PDF checkers); they find roughly a third of issues.
- Manual: keyboard-only pass; screen reader pass (VoiceOver, TalkBack, NVDA, Narrator, Orca); 200% text; greyscale; reduce motion; forced colours.
- Run before release and after redesigns; add regression cases to the test plan (`software-testing-strategy`).

## Record the outcome
- Save a short accessibility statement in the project notes or docs: standard and level targeted, date, what was tested and with what tools, known gaps with workarounds, contact for feedback.
- Log deliberate exceptions and their reason in the decisions file.

## Anti-patterns
- Colour-only status; placeholder as label; custom controls without accessibility roles; spinners in logs; "click here" links; text baked into images; accessibility added after the visual design is frozen.

## Checklist
- [ ] Contrast, scaling, and target sizes verified
- [ ] Keyboard-only and no traps; focus visible and ordered
- [ ] Names, labels, alt text, captions present
- [ ] No colour-only meaning; plain language
- [ ] No flashing; reduce-motion respected
- [ ] Errors actionable; CLI honours NO_COLOR and `--plain`
- [ ] Automated and manual checks run
- [ ] Accessibility statement recorded
