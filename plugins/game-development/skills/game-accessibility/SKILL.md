---
name: game-accessibility
description: Accessibility in games - vision (colour-blind-safe palettes, non-colour cues, text scaling, contrast, high-contrast mode, screen reader and text-to-speech for menus), hearing (subtitles with size and background options, visual cues for audio, per-bus volume), motor (full remapping, hold versus toggle, adjustable timing and QTE alternatives, one-handed schemes, aim assist, input buffering), cognitive (difficulty and assist options, clear objectives, pause anywhere, reduced flashing and motion, photosensitivity limits), settings UX and persistence, designing options into systems early, testing checklist, and established guidelines. Load when designing or reviewing game options, menus, controls, UI, audio, or when auditing a game for accessibility.
---

# Game accessibility

Accessibility options are design features, cheap early and expensive late. Guideline versions and Unity accessibility APIs change; verify against current docs/installed version. Baseline principles for non-game UI are in accessibility-baseline (shared plugin, if installed).

## References
- Game Accessibility Guidelines (gameaccessibilityguidelines.com): basic, intermediate, advanced tiers; use as the audit list. Verify it is current.
- Xbox Accessibility Guidelines (XAG) and platform holder requirements (console and mobile store accessibility checks); verify current.
- Treat the basic tier as mandatory, intermediate as default target.

## Design early
- Every input goes through an action layer (`input-systems`); every UI element is built from scalable, themeable components (`ui-systems`); every sound goes through a bus (`unity-architecture`). Retrofitting these later is the main cost driver.
- Put accessibility acceptance criteria in each feature's design notes before implementation.
- Never rely on one sense or one input type to convey essential information.

## Vision
- Colour: never encode meaning by colour alone; add shape, icon, pattern, label, or position. Check team colours, rarity tiers, health, and enemy/ally markers.
- Palettes: ship a colour-blind-safe default or presets (protanopia, deuteranopia, tritanopia); test with a simulator or filter. Allow custom colours for key gameplay elements (enemies, friends, pickups).
- Contrast: text 4.5:1 against its background (3:1 for large text and UI icons); give text a backing panel or outline over busy scenes.
- Text size: minimum body text readable at target viewing distance (TV: about 28 px at 1080p or larger; handheld/mobile: about 16 pt equivalent); offer scaling to at least 200% without clipping or overlap. Verify against platform guidance.
- High-contrast mode: toggle that swaps to flat, bold-outlined UI and optional enemy/object outlines.
- Screen reader/TTS: menus and settings should speak focus changes, values, and state; Unity has an accessibility module and platform TTS hooks; availability varies, verify against installed version.
- Avoid essential info in small corners; allow HUD scaling and repositioning.

## Hearing
- Subtitles: on by default for all speech, speaker names, and key sound captions.
- Options: size (at least 3 steps, up to large), background (none, semi-opaque, opaque), colour per speaker, and caption toggle for non-speech sounds.
- Keep lines to 2 lines and about 42 characters per line; display at least 1 s per short line.
- Visual cues for audio that matters (off-screen threats, alarms, directional damage): icon, edge indicator, controller haptics.
- Volume: separate sliders for master, music, SFX, dialogue, UI, ambience (mixer buses, `unity-architecture`); optional mono audio.
- Never require audio-only puzzles or cues without an alternative.

## Motor
- Full remapping for every input device, including menus; no hard-coded keys. Allow multiple bindings per action and rebinding of modifiers.
- Hold versus toggle for every held action (sprint, aim, crouch, charge, grab).
- Adjustable timing: no hidden short windows; offer press-instead-of-mash, hold-instead-of-mash, auto-complete, or skip for quick-time events and timed inputs.
- One-handed and reduced-input schemes: avoid chords of more than 2 simultaneous buttons; preset layouts.
- Aim assist and auto-target strength sliders; auto-run, auto-aim, and lock-on options.
- Input buffering: accept inputs about 100-200 ms early for jumps and actions; configurable forgiveness (coyote time) (`character-controller-systems`).
- Stick dead zone, sensitivity, inversion, and camera shake sliders; support adaptive controllers via the platform input system.
- Touch/mobile: target size at least 44 x 44 pt; avoid multi-finger or precise swipe requirements as the only path.

## Cognitive
- Difficulty: named presets plus granular assists (enemy health, damage taken, speed, timers, resource drain); never lock achievements behind or shame an assist.
- Clear objectives: persistent quest/goal reminder and optional waypoint; short, plain-language text; tutorials replayable from a menu.
- Pause anywhere: allow pause and settings in gameplay, and where design prevents it (cutscenes), allow skip or replay.
- Save often or allow save anywhere (`save-load-systems`); no lost progress from missed prompts.
- Reduce load: option to simplify HUD, toggle screen shake, motion blur, camera bob, parallax, and head bob.
- Photosensitivity: no more than 3 flashes in any 1 s (general flash/red flash thresholds in WCAG and ITU guidance; verify current); avoid large-area high-contrast flicker and patterns; provide a flash-reduction option and a warning screen at first launch.

## Settings UX
- One Accessibility menu reachable from the first launch screen and the pause menu; default screen offers a quick start questionnaire or presets.
- Settings apply live with a preview; show the current value; provide "reset to default".
- Persist per profile, and restore before the first frame of the title screen (`save-load-systems`); never reset on update.
- Menus must be navigable with the same input used to open them, by controller, keyboard, and pointer.
- Use plain labels ("Subtitle size"), not jargon.

## Unity specifics (verify against installed version)
- UI Toolkit and uGUI differ in scaling and focus support; test both navigation and text scaling in the chosen UI system (`ui-systems`).
- Input System package supports rebinding and runtime binding overrides; persist overrides as JSON.
- Screen-reader support, if the accessibility module is present, needs labelled UI nodes and a defined focus order.
- Test post-processing options (motion blur, bloom, chromatic aberration) as toggles.

## Testing
- Playthrough with each option on: subtitles only, colour-blind filter, grayscale, 200% text, no audio, one hand, single button, controller only, keyboard only.
- Use a colour simulator and a contrast checker on screenshots; run a flash analyser tool on trailers and key sequences.
- Recruit disabled players for feedback before launch; their findings outrank checklist passes.
- Add regression checks for settings persistence and rebinding (`unity-testing`).

## Anti-patterns
- Colour-only signals; unskippable QTEs; hard-coded input; tiny subtitles without background; options buried in submenus; accessibility as a last-sprint task; resetting settings after patches.

## Checklist
- [ ] Meaning never by colour or sound alone
- [ ] Subtitles on, scalable, with backgrounds; per-bus volume
- [ ] Full remap, hold/toggle, adjustable timing, aim assist
- [ ] Text 200% scaling, contrast met, high-contrast mode
- [ ] Difficulty assists, pause anywhere, objective reminders
- [ ] Flash and motion limits, warning, reduction toggles
- [ ] Settings live, persisted, reachable at first launch
- [ ] Tested with each option and with disabled players
