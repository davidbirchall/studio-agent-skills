---
name: game-localisation
description: Localisation engineering for Unity and C# games - string tables and keys with no hardcoded text, Unity Localization package basics, locale-aware formatting of numbers, dates, plurals and gender, fonts and glyph coverage (CJK, Arabic, Cyrillic), text expansion budgets and UI layout, right-to-left support, localising audio, images and voice, pseudo-localisation testing, translator and machine-translation context notes, fallback locale, locale persistence, build size impact, QA checklist, and scripts to extract and validate strings. Load when adding text to a game, preparing for translation, adding a language, or debugging missing glyphs, overflow, or wrong formatting.
---

# Game localisation

Package names, APIs, and settings are version sensitive; verify against the installed version of the Unity Localization package and its documentation. UI layout: `ui-systems`. Size impact: `unity-asset-management`. Persistence of the chosen locale: `save-load-systems`. Release steps: `game-store-release`.

## Plan from day one
- Retrofitting is expensive. Route all player-visible text through a localisation layer from the first prototype, even if only one language ships.
- Decide target languages early; they drive fonts, layout, and testing effort. Add languages by data, never by code changes.

## Strings and keys
- No player-visible literal in code, prefabs, or scenes. This includes tooltips, errors, button labels, achievement names, and store-page text.
- Keys are stable, lowercase, dotted ids by feature: `menu.start`, `quest.intro.title`. Never use the English text as the key. Never rename a key without migrating translations.
- One string table per domain (UI, dialogue, items). Keep tables small enough to review.
- Never concatenate sentences; use placeholders so translators can reorder: `"Collected {count} of {total}"`.
```csharp
var s = new LocalizedString("UI", "quest.progress");
s.Arguments = new object[] { new { count, total } };   // verify smart string argument syntax
label.text = s.GetLocalizedString();
```
- Subscribe to the string-changed event so text updates on locale change; unsubscribe on disable.

## Unity Localization package
- Provides locales, string tables, asset tables, smart strings, and a locale selector (verify current API).
- Set a project default and a fallback locale. Configure startup locale selectors in order: saved player choice, system language, default.
- Use Addressables-backed tables (the package depends on it) so locales load on demand; see `unity-asset-management`.
- Prefer the package's editor import/export (CSV, XLIFF, or sheet integration; verify supported formats) over hand-edited tables.

## Locale-aware formatting
- Use the culture of the selected game locale, not the OS, when formatting: `value.ToString("N0", culture)`. Do not parse or store data using the display culture; use `CultureInfo.InvariantCulture` for saves and logic.
- Dates, times, currency, and units vary; avoid hardcoded formats.
- Plurals: languages have 1 to 6 plural forms (Russian and Arabic have several). Use plural rules (smart strings or ICU style), never `count == 1 ? "item" : "items"`.
- Gender and grammatical case: provide variants per context when the language needs them; pass gender as an argument where characters are referenced.

## Fonts and glyphs
- Every shipped language needs a font with full glyph coverage: Latin extended, Cyrillic, Greek, CJK (thousands of glyphs), Arabic (with shaping), Thai, Devanagari.
- Use fallback fonts or per-locale font assets switched with the locale. For large CJK sets use dynamic font atlases or subsetted fonts; for fixed sets, generate static atlases from the actual used characters (verify TextMeshPro and font asset behaviour in the installed version).
- Check font licence permits embedding and the languages. Record fonts in the licence register.
- Missing glyph boxes (tofu) are a bug class: log missing glyphs in development builds.

## Layout and text expansion
- Budget 30-40 percent expansion over English for most European languages (more for short strings, German compounds); CJK is shorter in width but taller per line.
- Use auto-sizing, flexible layouts, and wrapping; never fixed-width text boxes. Allow min and max font sizes with truncation as a last resort.
- Do not bake text into images. Provide line-height room for diacritics and tall scripts.

## Right-to-left
- Arabic and Hebrew need RTL text shaping, right-to-left reading order, and mirrored layouts (alignment, anchors, progress bars, back arrows).
- Numbers and embedded Latin remain left-to-right inside RTL text (bidi). Verify RTL support in the text package or add a tested plugin.
- Do not mirror icons that have fixed meaning (play, clocks, logos).

## Audio, images, and voice
- Localised assets (voice, signage textures, videos) go in asset tables keyed like strings with a fallback to the default locale.
- Voice: match subtitle timing to localised audio length; load per locale only.
- Avoid text in textures; if unavoidable, make a per-locale variant.
- Culturally sensitive content (symbols, gestures, colours) is flagged for review, not auto-changed.

## Pseudo-localisation
- Generate a pseudo locale from source strings: accent characters, pad 40 percent, wrap in brackets, e.g. `[!!! S-t-a-r-t G-a-m-e !!!]` with accented characters substituted. Brackets expose truncation; accents expose font gaps; unwrapped strings reveal hardcoded text.
- Run the pseudo locale through every screen before real translation. Use a long-text variant and an RTL variant.

## Translator context
- Each key carries a note: where it appears, character limit, placeholder meanings, tone, and speaker. Include a screenshot path where helpful.
- Machine translation: send notes and glossary (character names, terms kept in English) with the batch; protect placeholders and rich-text tags; require human review for shipped text.
- Keep a glossary table versioned in the repo.

## Fallback and persistence
- Missing key falls back to the default locale, never an empty string or the raw key in release builds. Log missing keys in development.
- Persist the player's chosen locale as a setting; first launch uses the system language if supported.
- Provide a language selector that shows each language in its own name.

## Build size
- Locales are data: ship only the languages needed. Load fonts and audio per locale on demand. Measure each language's added size with the build report (see `unity-build-release`).

## Automation
- Editor scripts: extract keys used in code and prefabs, report unused and missing keys, validate placeholders match across languages, detect duplicate keys, and fail CI on missing default-language text.
- Lint source for string literals in UI assignments.

## QA checklist
- [ ] No hardcoded text (pseudo locale shows none)
- [ ] All screens fit at +40 percent length and the longest language
- [ ] Glyphs render in every locale; no tofu
- [ ] Plurals, numbers, dates correct per locale
- [ ] RTL layout and bidi checked if shipped
- [ ] Locale persists across restarts; fallback works
- [ ] Localised audio and images load and fallback
- [ ] Store page and age-rating text localised (see `game-store-release`)

## Anti-patterns
- English text as keys; string concatenation; baked-in text images; locale-dependent saves; shipping machine translation unreviewed.
