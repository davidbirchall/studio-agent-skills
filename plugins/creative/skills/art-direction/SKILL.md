---
name: art-direction
description: Establishing and maintaining a coherent visual language - mood boards, style guide, shape language, colour palette and value structure, lighting, texture, typography, composition rules, and do/don't examples - across games, film, animation, books, and brands. Load when translating a creative brief into a visual style, writing a style guide, reviewing assets for consistency, or briefing artists.
---

# Art direction

Chain: `creative-direction` -> `art-direction` -> `visual-development`. Story-side input comes from `worldbuilding` and `character-design`.

## Purpose
Define how the work looks and keep it consistent, so every session and every asset produce one visual identity that expresses the pillars.

## Inputs
- Approved creative brief and pillars (`creative-direction`).
- Setting facts such as climate, culture, technology level (`worldbuilding`).
- Production limits: medium, resolution, budget, tooling, and the single person's time.

## Framework
1. **Translate pillars to visual principles**: each pillar becomes one or two visual rules.
2. **Mood board**: curated images grouped by theme (colour, light, texture, shape, composition). Annotate why each is there; cut anything without a reason.
3. **Shape language**: dominant primitives - circles read friendly and safe, squares stable and solid, triangles dynamic or dangerous. Decide per faction, character type, or environment.
4. **Silhouette and readability**: key subjects must read at small size and in solid black.
5. **Colour and value**: palette with roles (dominant, secondary, accent), saturation and contrast limits, value structure (squint test). Reserve the accent for what matters.
6. **Light and texture**: light direction and quality, level of detail, materials, rendering approach (painterly, flat, photoreal, etc.).
7. **Typography and graphic design**: type families, hierarchy, iconography, layout grid where relevant.
8. **Style guide with do/don't pairs**: visual examples of on-style and off-style.
9. **Review loop**: self-critique each asset against the guide and pillars with the review criteria below, not personal taste; record the verdict.

## Output
```
STYLE GUIDE
Visual principles (from pillars):
Mood board summary (+ annotations):
Shape language:
Silhouette rules:
Palette (roles, values, saturation limits):
Lighting and texture:
Typography / iconography:
Do / Don't examples:
Asset review criteria:
```

## Quality checklist
- Every rule traces back to a pillar.
- Guide works in greyscale; values carry the image before colour does.
- A fresh session or contractor could produce on-style work from the guide alone.
- Do/Don't examples exist, not only prose.
- The style is achievable within production limits.

## Anti-patterns
- Mood board as a pretty collage with no stated takeaways.
- Style by reference imitation: copying another work's look wholesale.
- Over-specifying until nobody can create; leave room inside the rules.
- Too many accent colours, so nothing stands out.
- Guide written once and never updated after decisions change.

## Handoff
- Style guide -> `visual-development` for exploration, colour scripts, and key art.
- Feed shape language and palette rules to `character-design`; ask `worldbuilding` for cultural or environmental facts the visuals must respect.
- Escalate pillar conflicts to `creative-direction`.

## See also

Optional, if installed: 3d-asset-pipeline (the creative-technology plugin); 2d-asset-pipeline (the creative-technology plugin) for the broader discipline this skill applies. This skill stands on its own.
