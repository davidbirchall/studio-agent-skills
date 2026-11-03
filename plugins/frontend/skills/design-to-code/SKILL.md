---
name: design-to-code
description: Convert provided Figma or visual designs into responsive Nuxt/Vue components by inspecting tokens, reusing existing components, extracting assets, handling missing states, and adding accessibility. Validate at defined breakpoints. Load when implementing from Figma, screenshots, mockups, or visual specifications.
---

# Design to code

Builds on `frontend-design-systems`, `atomic-components-design`, `css-styling-standards`, and `frontend-a11y-check`. Design-tool output is a reference, not final code; never paste generated markup as-is.

## Inspect first
- Before writing code, read the design: structure and layer tree, variables and tokens, component and variant definitions, text styles, spacing, and a reference screenshot of each frame. Use the design tool's MCP or API when available (design context, variable definitions, screenshot, metadata).
- Identify the scope: one frame, one component, or a flow. Note the breakpoints the design provides.
- Record what is unclear before starting (see Asking).

## Tokens
- Build a mapping table design token -> project CSS variable before coding. Prefer an existing variable over a new one.
```
color/brand/primary   -> --color-primary
space/4 (16px)        -> --space-4
radius/md             -> --radius-md
text/body-md          -> --font-body-md
```
- If the design value has no match, check for a near match within tolerance (for example 1-2 px, small colour delta) and flag it; add a new token only after deciding with the user, in the token source file, not inline.
- Never hardcode magic numbers or hex values in components. Every colour, size, space, radius, shadow, z-index, and duration comes from a token.
- Express values in the project's units (rem for type and spacing) per `css-styling-standards`.

## Reuse and structure
- Search the existing component library and design system first. If a matching component exists, use it and extend via props or slots instead of forking.
- Decompose bottom-up: atoms (button, icon, input), molecules, organisms, then the page (`atomic-components-design`). Create a new component only when it appears in 2 or more places or is a clear design component.
- Name components and props from design layers and component names, translated to project conventions (`PascalCase` files, `camelCase` props). Variant properties in the design become typed props.
```ts
defineProps<{ variant?: 'primary' | 'secondary'; size?: 'sm' | 'md'; disabled?: boolean }>();
```
- Keep page markup semantic (`header`, `nav`, `main`, `button`, `ul`), not nested divs mirroring design frames.

## Responsive
- Derive behaviour from constraints and auto-layout: hug, fill, fixed, min/max, wrap, gap. Translate to flex or grid, `min-width`, `max-width`, `clamp()`, and container or media queries.
- Do not reproduce absolute positions or fixed frame widths. Check intermediate widths between provided breakpoints.
- If only desktop (or only mobile) is designed, implement a sensible fluid behaviour and flag the assumption.

## Assets
- Export icons as SVG and register them through the project's icon mechanism (sprite, icon component, or icon module); use `currentColor` so they follow text colour. Do not inline large SVG in templates.
- Export raster images at 1x and 2x in modern formats; use the framework image component with explicit dimensions to avoid layout shift (`frontend-performance`). Compress and store in the assets folder, not hotlinked from the design tool (URLs expire).

## Accessibility the design omits
- Add what designs rarely show: labels and `for`/`id`, accessible names for icon buttons, visible focus styles, keyboard order and operation, error association (`aria-describedby`), landmark roles, heading levels, `alt` text decisions, reduced-motion handling, 4.5:1 contrast checks (`form-handling`, `animation-motion`).
- Verify with `frontend-a11y-check` before calling it done.

## Missing states
- Designs often show only the happy path. Implement and flag: hover, focus, active, disabled, loading, empty, error, long text overflow, very long and very short content, and right-to-left or longer translated strings (`frontend-internationalization`).
- Derive them from existing system patterns; list each invented state in the summary for review.

## Fidelity check
- Render at the design breakpoints (for example 375, 768, 1280 px) and compare side by side with the design screenshot: layout, spacing, type, colour, states.
- Tolerance: spacing within 1-2 px after rounding to tokens, exact colours via tokens, no unexplained differences. Document intentional deviations (token rounding, accessibility fixes).
- Use Storybook stories per variant to review components in isolation (`storybook-workflow`).

## Code-connect notes
- Keep a mapping of design component -> code component with prop correspondence, so future designs reuse it. If the design tool supports code connect, publish the mapping there; otherwise record it in the component's docs or story.

## Asking
- Ask the user, rather than guessing, when: tokens conflict or are missing, the design contradicts the system, behaviour (interaction, validation, data) is unspecified, or breakpoints are absent. Batch questions with your proposed default.

## Checklist
- [ ] Design context and tokens read before coding
- [ ] Token map written; zero hardcoded values
- [ ] Existing components reused; atoms to organisms
- [ ] Responsive from constraints; tested between breakpoints
- [ ] Icons and images exported properly
- [ ] A11y added; missing states handled and flagged
- [ ] Side-by-side check at each breakpoint; deviations documented
